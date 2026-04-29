#pragma once
#include "MathUtils.cuh"

#ifdef __CUDA_ARCH__
#include "CudaCompat.h"
#include <curand_kernel.h>

HOSTDEVICE inline int random(int min, int max, curandState* state) {
	return min + int(curand_uniform(state) * (max - min));
}

HOSTDEVICE inline int random(int max, curandState* state) {
	return int(curand_uniform(state) * max);
}

HOSTDEVICE inline float randomf(float min, float max, curandState* state) {
	return min + curand_uniform(state) * (max - min);
}

HOSTDEVICE inline float randomf(float max, curandState* state) {
	return curand_uniform(state) * max;
}

HOSTDEVICE inline float randomf(curandState* state) {
	return curand_uniform(state);
}

HOSTDEVICE inline vec3 random(const vec3& minVec, const vec3& maxVec, curandState* state) {
	return vec3{
		randomf(minVec.x, maxVec.x, state),
		randomf(minVec.y, maxVec.y, state),
		randomf(minVec.z, maxVec.z, state)
	};
}

HOSTDEVICE inline vec3 random(const vec3& maxVec, curandState* state) {
	return random(vec3(0.0f), maxVec, state);
}

HOSTDEVICE inline vec2 randomOnUnitCircle(curandState* state) {
	float angle = randomf(0.0f, 360.0f, state);
	return { cosf(Math::Radians(angle)), sinf(Math::Radians(angle)) };
}

HOSTDEVICE inline vec3 randomInUnitSphere(curandState* state) {
	vec3 v;
	do {
		v = random(vec3(-1.0f), vec3(1.0f), state);
	} while (Math::Length(v) > 1.0f);
	return v;
}

HOSTDEVICE inline vec3 randomOnUnitSphere(curandState* state) {
	return Math::Normalize(randomInUnitSphere(state));
}
#endif