#include "Scene.h"
#include "CudaCompat.h"
#include "GPURaycasting.cuh"

#include "Camera.cuh"
#include "CudaErrors.h"
#include "ETime.h"
#include "Framebuffer.h"
#include "DeviceRandom.cuh"
#include "Tracer.cuh"

#ifdef __CUDACC__
#pragma nv_diag_suppress 20012
#endif
#include <curand_kernel.h>
#ifdef __CUDACC__
#pragma nv_diag_default 20012
#endif

#include <device_launch_parameters.h>
#include <iostream>

__device__
float deviceRandomf(curandState* state)
{
	return curand_uniform(state);
}

__global__
void RenderKernel(SceneGPU* scene, color_t* framebuffer, int width, int height, CameraGPU* camera, int numSamples, int depth)
{
	int x = blockIdx.x * blockDim.x + threadIdx.x;
	int y = blockIdx.y * blockDim.y + threadIdx.y;
	if (x >= width || y >= height)
		return;

	curandState randstate;
	curand_init(42, y * width + x, 0, &randstate);

	color3_t color{ 0 };
	for (int i = 0; i < numSamples; i++)
	{
		vec2 pixel{ (float)x, (float)y };
		pixel += vec2{ deviceRandomf(&randstate), deviceRandomf(&randstate) };
		vec2 point = pixel / vec2{ (float)width, (float)height };
		point.y = 1 - point.y;
		ray_t ray = GetCameraRay(point, camera);
		color3_t traceColor = Trace(scene, &ray, 0.001f, 100.0f, depth
#ifdef __CUDA_ARCH__
			, &randstate
#endif
		);
		color += traceColor;
	}
	color.r /= (float)numSamples;
	color.g /= (float)numSamples;
	color.b /= (float)numSamples;
	//printf("Pixel (%d, %d) color: (%f, %f, %f)\n", x, y, color.r, color.g, color.b);
	framebuffer[y * width + x] = Color::ColorConvert(color);
}

void Scene::Update()
{
	for (auto& object : m_objects)
	{
		object->Update();
	}
}

void Scene::Render(Framebuffer& framebuffer, const Camera& camera, int numSamples, int depth)
{
	Time frameTimer;
	Time scanlineTimer;

	// Allocate CUDA memory for framebuffer
	int numPixels = framebuffer.m_width * framebuffer.m_height;
	size_t bufferSize = numPixels * sizeof(color_t);

	color_t* deviceBuffer;
	checkCudaErrors(cudaMallocManaged((void**)&deviceBuffer, bufferSize));
	CameraGPU* deviceCamera;
	checkCudaErrors(cudaMallocManaged((void**)&deviceCamera, sizeof(CameraGPU)));
	deviceCamera->eye = camera.m_eye;
	deviceCamera->lowerLeft = camera.m_lowerLeft;
	deviceCamera->horizontal = camera.m_horizontal;
	deviceCamera->vertical = camera.m_vertical;

	int tx = 16;
	int ty = 16;

	dim3 blocks((framebuffer.m_width + tx - 1) / tx, (framebuffer.m_height + ty - 1) / ty);
	dim3 threads(tx, ty);

	SceneGPU* sceneGPU = this->ToGPU();

	checkCudaErrors(cudaDeviceSetLimit(cudaLimitStackSize, 16384)); // Increase stack size for deep recursion in ray tracing
	RenderKernel<<<blocks, threads>>>(sceneGPU, deviceBuffer, framebuffer.m_width, framebuffer.m_height, deviceCamera, numSamples, depth);

	checkCudaErrors(cudaDeviceSynchronize());
	std::cout << "frame time: " << frameTimer.GetElapsedTime() << std::endl;

	framebuffer.m_buffer = std::vector<color_t>(deviceBuffer, deviceBuffer + numPixels);

	checkCudaErrors(cudaFree(deviceBuffer));
	for (int i = 0; i < sceneGPU->numObjects; ++i)
	{
		if (sceneGPU->objects[i].sphere)
		{
			checkCudaErrors(cudaFree(sceneGPU->objects[i].sphere));
		}
		if (sceneGPU->objects[i].plane)
		{
			checkCudaErrors(cudaFree(sceneGPU->objects[i].plane));
		}
		if (sceneGPU->objects[i].triangle)
		{
			checkCudaErrors(cudaFree(sceneGPU->objects[i].triangle));
		}
		if (sceneGPU->objects[i].model)
		{
			checkCudaErrors(cudaFree(sceneGPU->objects[i].model->vertexBuffer));
			checkCudaErrors(cudaFree(sceneGPU->objects[i].model));
		}
	}
	checkCudaErrors(cudaFree(sceneGPU->objects));
	checkCudaErrors(cudaFree(sceneGPU->materials));

	checkCudaErrors(cudaFree(sceneGPU));
}

SceneGPU* Scene::ToGPU() const
{
	SceneGPU* sceneGPU;
	cudaMallocManaged(&sceneGPU, sizeof(SceneGPU));

	sceneGPU->skyBottom = m_skyBottom;
	sceneGPU->skyTop = m_skyTop;

	sceneGPU->numObjects = (int)m_objects.size();
	cudaMallocManaged(&sceneGPU->objects, sizeof(SceneObjectGPU) * sceneGPU->numObjects);

	std::vector<MaterialGPU> uniqueMaterials;
	for (auto& object : m_objects)
	{
		if (auto materialPtr = object->GetMaterial())
		{
			if (std::find(uniqueMaterials.begin(), uniqueMaterials.end(), *materialPtr) == uniqueMaterials.end())
			{
				uniqueMaterials.push_back(*materialPtr);
			}
		}
	}
	sceneGPU->numMaterials = (int)uniqueMaterials.size();
	cudaMallocManaged(&sceneGPU->materials, sizeof(MaterialGPU) * sceneGPU->numMaterials);
	for (int i = 0; i < sceneGPU->numMaterials; i++)
	{
		sceneGPU->materials[i] = uniqueMaterials[i];
	}

	for (int i = 0; i < sceneGPU->numObjects; i++)
	{
		SceneObject* object = m_objects[i].get();
		SceneObjectGPU& objectGPU = sceneGPU->objects[i];
		if (dynamic_cast<Sphere*>(object))
		{
			objectGPU.type = ObjectType::SPHERE;
			Sphere* sphere = static_cast<Sphere*>(object);
			objectGPU.position = sphere->GetTransform().position;
			objectGPU.rotation = sphere->GetTransform().rotation;
			objectGPU.scale = sphere->GetTransform().scale;

			SphereGPU* sphereGPU;
			cudaMallocManaged(&sphereGPU, sizeof(SphereGPU));
			objectGPU.sphere = sphereGPU;
			objectGPU.sphere->radius = sphere->GetRadius();
		}
		else if (dynamic_cast<Plane*>(object))
		{
			objectGPU.type = ObjectType::PLANE;
			Plane* plane = static_cast<Plane*>(object);
			objectGPU.position = plane->GetTransform().position;
			objectGPU.rotation = plane->GetTransform().rotation;
			objectGPU.scale = plane->GetTransform().scale;

			PlaneGPU* planeGPU;
			cudaMallocManaged(&planeGPU, sizeof(PlaneGPU));
			objectGPU.plane = planeGPU;
			objectGPU.plane->normal = plane->GetNormal();
		}
		else if (dynamic_cast<Triangle*>(object))
		{
			objectGPU.type = ObjectType::TRIANGLE;
			Triangle* triangle = static_cast<Triangle*>(object);
			objectGPU.position = triangle->GetTransform().position;
			objectGPU.rotation = triangle->GetTransform().rotation;
			objectGPU.scale = triangle->GetTransform().scale;

			TriangleGPU* triangleGPU;
			cudaMallocManaged(&triangleGPU, sizeof(TriangleGPU));
			objectGPU.triangle = triangleGPU;
			objectGPU.triangle->v0 = triangle->GetV0();
			objectGPU.triangle->v1 = triangle->GetV1();
			objectGPU.triangle->v2 = triangle->GetV2();
		}
		else if (dynamic_cast<Model*>(object))
		{
			objectGPU.type = ObjectType::MODEL;
			Model* model = static_cast<Model*>(object);
			objectGPU.position = model->GetTransform().position;
			objectGPU.rotation = model->GetTransform().rotation;
			objectGPU.scale = model->GetTransform().scale;

			ModelGPU* modelGPU;
			cudaMallocManaged(&modelGPU, sizeof(ModelGPU));
			objectGPU.model = modelGPU;
			objectGPU.model->vertexCount = model->GetVertexCount();
			cudaMallocManaged(&objectGPU.model->vertexBuffer, sizeof(vec3) * objectGPU.model->vertexCount);
			for (int v = 0; v < objectGPU.model->vertexCount; v++)
			{
				objectGPU.model->vertexBuffer[v] = model->GetVertex(v);
			}
			objectGPU.model->center = model->GetCenter();
			objectGPU.model->radius = model->GetBoundingSphereRadius();
		}
		else
		{
			std::cerr << "Unsupported object type in Scene::ToGPU()" << std::endl;
		}

		if (auto materialPtr = object->GetMaterial())
		{
			int materialIndex = -1;
			MaterialGPU* materialPtrGPU = std::find(sceneGPU->materials, sceneGPU->materials + sceneGPU->numMaterials, *materialPtr);
			if (materialPtrGPU != sceneGPU->materials + sceneGPU->numMaterials)
			{
				materialIndex = (int)(materialPtrGPU - sceneGPU->materials);
			}

			objectGPU.materialIndex = materialIndex;
			/*std::cout << "Object " << i << " material index: " << objectGPU.materialIndex << " material albedo: (" 
				<< sceneGPU->materials[objectGPU.materialIndex].albedo.x << ", " << sceneGPU->materials[objectGPU.materialIndex].albedo.y 
				<< ", " << sceneGPU->materials[objectGPU.materialIndex].albedo.z << ")" << std::endl;*/
		}
		else
		{
			std::cerr << "Object without material in Scene::ToGPU()" << std::endl;
			objectGPU.materialIndex = -1; // Invalid index
		}
	}

	return sceneGPU;
}