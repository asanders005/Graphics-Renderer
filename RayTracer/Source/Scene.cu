#include "Scene.h"
#include "SceneGPU.h"

#include "Camera.h"
#include "CudaErrors.h"
#include "ETime.h"
#include "Framebuffer.h"
#include "Random.cuh"
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
void RenderKernel(SceneGPU* scene, color_t* framebuffer, int width, int height, Camera camera, int numSamples, int depth)
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
		glm::vec2 pixel{ x, y };
		pixel += glm::vec2{ deviceRandomf(&randstate), deviceRandomf(&randstate) };
		glm::vec2 point = pixel / glm::vec2{ width, height };
		point.y = 1 - point.y;
		ray_t ray = camera.GetRay(point);
		color += Trace(*scene, ray, 0.001f, 100.0f, depth
#ifdef __CUDA_ARCH__
			, &randstate
#endif
		);
	}
	color.r /= (float)numSamples;
	color.g /= (float)numSamples;
	color.b /= (float)numSamples;
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
	checkCudaErrors(cudaMallocManaged((void **)&deviceBuffer, bufferSize));

	int tx = 16;
	int ty = 16;
	
	dim3 blocks((framebuffer.m_width + tx - 1) / tx, (framebuffer.m_height + ty - 1) / ty);
	dim3 threads(tx, ty);

	SceneGPU sceneGPU = this->ToGPU();
	RenderKernel<<<blocks, threads>>>(&sceneGPU, deviceBuffer, framebuffer.m_width, framebuffer.m_height, camera, numSamples, depth);

	checkCudaErrors(cudaDeviceSynchronize());
	std::cout << "frame time: " << frameTimer.GetElapsedTime() << std::endl;
}

SceneGPU Scene::ToGPU() const
{
	SceneGPU sceneGPU;

	sceneGPU.numObjects = (int)m_objects.size();
	sceneGPU.objects = new SceneObjectGPU[sceneGPU.numObjects];

	for (int i = 0; i < sceneGPU.numObjects; i++)
	{
		SceneObject* object = m_objects[i].get();
		SceneObjectGPU& objectGPU = sceneGPU.objects[i];
		if (dynamic_cast<Sphere*>(object))
		{
			objectGPU.type = ObjectType::SPHERE;
			Sphere* sphere = static_cast<Sphere*>(object);
			objectGPU.position = sphere->GetTransform().position;
			objectGPU.rotation = sphere->GetTransform().rotation;
			objectGPU.scale = sphere->GetTransform().scale;
			objectGPU.sphere.radius = sphere->GetRadius();
		}
		else if (dynamic_cast<Plane*>(object))
		{
			objectGPU.type = ObjectType::PLANE;
			Plane* plane = static_cast<Plane*>(object);
			objectGPU.position = plane->GetTransform().position;
			objectGPU.rotation = plane->GetTransform().rotation;
			objectGPU.scale = plane->GetTransform().scale;
			objectGPU.plane.normal = plane->GetNormal();
		}
		else if (dynamic_cast<Triangle*>(object))
		{
			objectGPU.type = ObjectType::TRIANGLE;
			Triangle* triangle = static_cast<Triangle*>(object);
			objectGPU.position = triangle->GetTransform().position;
			objectGPU.rotation = triangle->GetTransform().rotation;
			objectGPU.scale = triangle->GetTransform().scale;
			objectGPU.triangle.v0 = triangle->GetV0();
			objectGPU.triangle.v1 = triangle->GetV1();
			objectGPU.triangle.v2 = triangle->GetV2();
		}
		else if (dynamic_cast<Model*>(object))
		{
			objectGPU.type = ObjectType::MODEL;
			Model* model = static_cast<Model*>(object);
			objectGPU.position = model->GetTransform().position;
			objectGPU.rotation = model->GetTransform().rotation;
			objectGPU.scale = model->GetTransform().scale;
			objectGPU.model.vertexCount = model->GetVertexCount();
			objectGPU.model.vertexBuffer = new glm::vec3[objectGPU.model.vertexCount];
			for (int v = 0; v < objectGPU.model.vertexCount; v++)
			{
				objectGPU.model.vertexBuffer[v] = model->GetVertex(v);
			}
			objectGPU.model.center = model->GetCenter();
			objectGPU.model.radius = model->GetBoundingSphereRadius();
		}
		else
		{
			std::cerr << "Unsupported object type in Scene::ToGPU()" << std::endl;
		}

		if (auto materialPtr = object->GetMaterial())
		{
			int materialIndex = -1;
			MaterialGPU* materialPtrGPU = std::find(sceneGPU.materials, sceneGPU.materials + sceneGPU.numMaterials, *materialPtr);
			if (materialPtrGPU == sceneGPU.materials + sceneGPU.numMaterials)
			{
				// Material not found in GPU array, add it
				sceneGPU.materials[sceneGPU.numMaterials] = *materialPtr;
				sceneGPU.numMaterials++;
				materialIndex = sceneGPU.numMaterials - 1;
			}
			else
			{
				// Material already exists in GPU array, find its index
				materialIndex = (int)(materialPtrGPU - sceneGPU.materials);
			}

			objectGPU.materialIndex = materialIndex;
		}
		else
		{
			std::cerr << "Object without material in Scene::ToGPU()" << std::endl;
			objectGPU.materialIndex = -1; // Invalid index
		}
	}

	return sceneGPU;
}