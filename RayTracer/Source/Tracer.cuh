#pragma once
#include "CudaCompat.h"
#include "Color.cuh"
#include "GPURaycasting.cuh"
#include "Material.cuh"

HOSTDEVICE inline color3_t Trace(
	struct SceneGPU* scene, 
	const struct ray_t* ray, 
	float minDistance, 
	float maxDistance, 
	int depth
#ifdef __CUDA_ARCH__
	, curandState* state
#endif 
)
{
	if (depth == 0) return color3_t{ 1 };

	rayCastHit_t closestHit;
	closestHit.distance = maxDistance;
	bool isHit = false;

	//Check for object hit
	for (int i = 0; i < scene->numObjects; ++i)
	{
		rayCastHit_t tempHit;
		/*if (scene->objects[i].materialIndex != 0)
		{
			printf("Testing hit for object %d of type %d with material index %d\n", i, (int)scene->objects[i].type, scene->objects[i].materialIndex);
		}*/

		if (SceneObjectGPU_Hit(&scene->objects[i], scene, ray, &tempHit, minDistance, closestHit.distance))
		{
			if (!isnan(tempHit.distance) && tempHit.distance < closestHit.distance)
			{
				closestHit = tempHit;
				isHit = true;
			}
		}
	}

	if (isHit)
	{
		if (isnan(closestHit.distance))
		{
			printf("NaN distance hit\n");
			return color3_t{ 0 };
		}

		//printf("Hit object at distance %f\n", closestHit.distance);
		color3_t attenuation;
		ray_t scatter;
		if (Material::Scatter(ray, &closestHit, &attenuation, &scatter
#ifdef __CUDA_ARCH__
			, state
#endif
		))
		{
			//if (attenuation != vec3 { 1 }) printf("Hit non-emissive material with color (%f, %f, %f)\n", attenuation.x, attenuation.y, attenuation.z);
			return attenuation * Trace(scene, &scatter, minDistance, maxDistance, depth - 1
#ifdef __CUDA_ARCH__
				, state
#endif
			);
		}
		else
		{
			color3_t emissiveColor = Material::GetEmissive(*closestHit.material);
			//printf("Hit emissive material with color (%f, %f, %f)\n", emissiveColor.x, emissiveColor.y, emissiveColor.z);
			return emissiveColor;
		}
	}

	vec3 direction = Math::Normalize(ray->direction);

	float t = (direction.y + 1) * 0.5f;
	color3_t color = Math::Lerp(scene->skyBottom, scene->skyTop, t);

	return color;
}
