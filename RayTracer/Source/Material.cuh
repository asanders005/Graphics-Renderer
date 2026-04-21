#pragma once
#include "CudaCompat.h"
#include "Color.h"
#include "MaterialGPU.h"
#include "Ray.cuh"
#include "Random.cuh"

#include <curand_kernel.h>

class Material
{
public:
	HOSTDEVICE inline static bool Scatter(
		const ray_t& ray,
		const rayCastHit_t& rayCastHit,
		color3_t& attenuation,
		ray_t& scatter
#ifdef __CUDA_ARCH__
		, curandState* state
#endif
	)
	{
		auto mat = *rayCastHit.material;

		switch (mat.type)
		{
		case MaterialType::LAMBERTIAN:
		{
			scatter.origin = rayCastHit.point;
			scatter.direction = rayCastHit.normal + randomOnUnitSphere(
#ifdef __CUDA_ARCH__
				state
#endif
			);

			attenuation = mat.albedo;

			return true;
		}
		case MaterialType::METAL:
		{
			glm::vec3 reflected = Math::Reflect(ray.direction, rayCastHit.normal);

			scatter = ray_t{ rayCastHit.point, reflected + (randomOnUnitSphere(
#ifdef __CUDA_ARCH__
				state
#endif
			) * mat.fuzz) };
			attenuation = mat.albedo;

			return glm::dot(scatter.direction, rayCastHit.normal) > 0;
		}
		case MaterialType::DIELECTRIC:
		{
			glm::vec3 outNormal;
			float ni_over_nt;
			float cosine;

			//Check if hitting from outside
			if (glm::dot(ray.direction, rayCastHit.normal) < 0)
			{
				outNormal = rayCastHit.normal;
				ni_over_nt = 1.0f / mat.refractiveIndex;
				cosine = -glm::dot(ray.direction, rayCastHit.normal) / glm::length(ray.direction);
			}
			else
			{
				//Hitting from inside
				outNormal = -rayCastHit.normal;
				ni_over_nt = mat.refractiveIndex;
				cosine = mat.refractiveIndex * glm::dot(ray.direction, rayCastHit.normal) / glm::length(ray.direction);
			}

			glm::vec3 refracted;
			float reflectProbability = 1.0f;

			if (Math::Refract(ray.direction, outNormal, ni_over_nt, refracted))
			{
				reflectProbability = Math::Schlick(cosine, mat.refractiveIndex);
			}

			glm::vec3 reflected = Math::Reflect(ray.direction, rayCastHit.normal);

			scatter = (randomf(
#ifdef __CUDA_ARCH__
				state
#endif
				) < reflectProbability) ? ray_t{ rayCastHit.point, reflected } : ray_t{ rayCastHit.point, refracted };

			attenuation = mat.albedo;

			return true;
		}
		case MaterialType::EMISSIVE:
			return false;
		default:
			return false;
		}
	}

	HOSTDEVICE inline static glm::vec3 GetColor(const MaterialGPU& mat) { return mat.albedo; }
	HOSTDEVICE inline static color3_t GetEmissive(const MaterialGPU& mat) { return mat.albedo * mat.intensity; }
};
