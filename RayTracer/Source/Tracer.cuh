#pragma once
#include "Color.h"
#include "CudaCompat.h"
#include "SceneObjectGPU.cuh"
#include "SceneGPU.h"
#include "Material.cuh"

HOSTDEVICE inline color3_t Trace(
	struct SceneGPU& scene, 
	const struct ray_t& ray, 
	float minDistance, 
	float maxDistance, 
	int depth
#ifdef __CUDA_ARCH__
	, curandState* state
#endif 
)
{
	if (depth == 0) return color3_t{ 0 };

	rayCastHit_t rayCastHit;
	float closestDistance = maxDistance;
	bool isHit = false;

	//Check for object hit
	for (int i = 0; scene.numObjects; ++i)
	{
		if (SceneObjectGPU_Hit(scene.objects[i], scene, ray, rayCastHit, minDistance, closestDistance))
		{
			isHit = true;
			closestDistance = rayCastHit.distance;
		}
	}

	if (isHit)
	{
		color3_t attenuation;
		ray_t scatter;
		if (Material::Scatter(ray, rayCastHit, attenuation, scatter
#ifdef __CUDA_ARCH__
			, state
#endif
		))
		{
			return attenuation * Trace(scene, scatter, minDistance, maxDistance, depth - 1
#ifdef __CUDA_ARCH__
				, state
#endif
			);
		}
		else
		{
			return Material::GetEmissive(*rayCastHit.material);
		}
	}

	glm::vec3 direction = glm::normalize(ray.direction);

	float t = (direction.y + 1) * 0.5f;
	color3_t color = Math::Lerp(scene.skyBottom, scene.skyTop, t);

	return color;
}
