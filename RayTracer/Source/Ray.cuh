#pragma once
#include "CudaCompat.h"
#include "vec3.cuh"
#include <memory>

struct ray_t
{
	vec3 origin;
	vec3 direction;
	
	ray_t() = default;
	HOSTDEVICE inline ray_t(const vec3& origin, const vec3& direction) : origin{ origin }, direction{ direction } {}
};
HOSTDEVICE inline vec3 RayAt(const ray_t* ray, float t) { return ray->origin + ray->direction * t; }

struct rayCastHit_t
{
	float distance{ 0 };
	
	vec3 point;
	vec3 normal;

	struct MaterialGPU* material{ nullptr };
};