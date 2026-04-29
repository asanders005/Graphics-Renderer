#pragma once
#include "MathUtils.cuh"

inline int random(int min, int max) {
	return min + rand() % (max - min);
}

inline int random(int max) {
	return rand() % max;
}

inline int random() {
	return rand();
}

inline float randomf(float min, float max) {
	return min + (rand() / (float)RAND_MAX) * (max - min);
}

inline float randomf(float max) {
	return (rand() / (float)RAND_MAX) * max;
}

inline float randomf() {
	return rand() / (float)RAND_MAX;
}

inline vec3 random(const vec3& minVec, const vec3& maxVec) {
	return vec3{
		randomf(minVec.x, maxVec.x),
		randomf(minVec.y, maxVec.y),
		randomf(minVec.z, maxVec.z)
	};
}

inline vec3 random(const vec3& maxVec) {
	return random(vec3(0.0f), maxVec);
}

inline vec2 randomOnUnitCircle() {
	float angle = randomf(0.0f, 360.0f);
	return { cosf(Math::Radians(angle)), sinf(Math::Radians(angle)) };
}

inline vec3 randomInUnitSphere() {
	vec3 v;
	do {
		v = random(vec3(-1.0f), vec3(1.0f));
	} while (Math::Length(v) > 1.0f);
	return v;
}

inline vec3 randomOnUnitSphere() {
	return Math::Normalize(randomInUnitSphere());
}