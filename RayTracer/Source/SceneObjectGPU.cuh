#pragma once
#include "CudaCompat.h"
#include "CudaErrors.h"
#include "Ray.cuh"

enum class ObjectType : int
{
	SPHERE,
	PLANE,
	TRIANGLE,
	MODEL
};

struct SphereGPU
{
	float radius;
};

struct PlaneGPU
{
	vec3 normal;
};

struct TriangleGPU
{
	vec3 v0, v1, v2;
};

struct ModelGPU
{
	vec3* vertexBuffer;
	int vertexCount;
	vec3 center;
	float radius;
};

struct SceneObjectGPU
{
	ObjectType type;
	int materialIndex;

	vec3 position;
	vec3 rotation;
	vec3 scale;

	SphereGPU* sphere{ nullptr };
	PlaneGPU* plane{ nullptr };
	TriangleGPU* triangle{ nullptr };
	ModelGPU* model{ nullptr };
};