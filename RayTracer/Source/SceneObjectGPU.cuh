#pragma once
#include "SceneGPU.h"
#include "CudaCompat.h"
#include "Ray.cuh"
#include <glm/glm.hpp>

enum class ObjectType : int
{
	SPHERE,
	PLANE,
	TRIANGLE,
	MODEL
};

struct SceneObjectGPU
{
	ObjectType type;

	glm::vec3 position;
	glm::vec3 rotation;
	glm::vec3 scale;

	union
	{
		struct { float radius; } sphere;
		struct { glm::vec3 normal; } plane;
		struct { glm::vec3 v0, v1, v2; } triangle;
		struct 
		{ 
			glm::vec3* vertexBuffer;
			int vertexCount; 
			glm::vec3 center;
			float radius;
		} model;
	};
	int materialIndex;
};

HOSTDEVICE inline bool RaycastSphere(const ray_t& ray, const glm::vec3& center, float radius, float minDistance, float maxDistance, float& t)
{
	// Vector from the ray origin to the center of the sphere
	glm::vec3 oc = ray.origin - center;

	// Coefficients for the quadratic equation
	// a = dot(ray direction, ray direction), which is the square of the length of the ray direction
	float a = glm::dot(ray.direction, ray.direction);

	// b = 2 * dot(ray direction, oc), where oc is the vector from the ray origin to the sphere center
	float b = 2 * glm::dot(ray.direction, oc);

	// c = dot(oc, oc) - radius^2, which accounts for the distance from the origin to the center minus the radius of the sphere
	float c = glm::dot(oc, oc) - (radius * radius);

	// Discriminant of the quadratic equation: b^2 - 4ac
	// This tells us how many real solutions (hits) exist:
	// If discriminant < 0, no real solutions (no intersection)
	// If discriminant = 0, one solution (the ray grazes the sphere)
	// If discriminant > 0, two solutions (the ray hits the sphere twice)
	float discriminant = (b * b) - (4 * a * c);

	if (discriminant >= 0)
	{
		t = (-b - sqrtf(discriminant)) / (2 * a);
		if (t >= minDistance && t <= maxDistance)
		{
			return true;
		}

		t = (-b + sqrtf(discriminant)) / (2 * a);
		if (t >= minDistance && t <= maxDistance)
		{
			return true;
		}
	}

	return false;
}

HOSTDEVICE inline bool HitSphere(const SceneObjectGPU& object, const SceneGPU& scene, const ray_t& ray, rayCastHit_t& rayCastHit, float minDistance, float maxDistance)
{
	float t;
	if (!RaycastSphere(ray, object.position, object.sphere.radius * object.scale.x, minDistance, maxDistance, t)) return false;

	rayCastHit.distance = t;
	rayCastHit.point = ray.At(t);
	rayCastHit.normal = glm::normalize(rayCastHit.point - object.position);
	rayCastHit.material = &scene.materials[object.materialIndex];

	return true;
}

HOSTDEVICE inline bool RaycastPlane(const ray_t& ray, const glm::vec3& point, const glm::vec3& normal, float minDistance, float maxDistance, float& t)
{
	float denominator = glm::dot(ray.direction, normal);

	if (Math::approximately(denominator, 0)) return false;

	t = glm::dot((point - ray.origin), normal) / denominator;
	if (t < 0) return false;

	if (t <= minDistance || t >= maxDistance) return false;

	return true;
}

HOSTDEVICE inline bool HitPlane(const SceneObjectGPU& object, const SceneGPU& scene, const ray_t& ray, rayCastHit_t& rayCastHit, float minDistance, float maxDistance)
{
	float t;

	if (!RaycastPlane(ray, object.position, object.plane.normal, minDistance, maxDistance, t)) return false;

	rayCastHit.distance = t;
	rayCastHit.normal = glm::normalize(object.plane.normal);
	rayCastHit.point = ray.At(t);
	rayCastHit.material = &scene.materials[object.materialIndex];

	return true;
}

HOSTDEVICE inline bool RaycastTriangle(const ray_t& ray, const glm::vec3& v0, const glm::vec3& v1, const glm::vec3& v2, float minDistance, float maxDistance, float& t)
{
	glm::vec3 edge1 = v1 - v0;
	glm::vec3 edge2 = v2 - v0;

	glm::vec3 pvec = glm::cross(ray.direction, edge2);
	float determinant = glm::dot(pvec, edge1);

	if (determinant < 0 || Math::approximately(determinant, 0))
	{
		return false;
	}

	float invDet = 1 / determinant;

	glm::vec3 tvec = ray.origin - v1;
	float u = glm::dot(tvec, pvec) * invDet;

	if (u < 0 || u > 1)
	{
		return false;
	}

	glm::vec3 qvec = glm::cross(tvec, edge1);
	float v = glm::dot(qvec, ray.direction) * invDet;

	if (v < 0 || u + v > 1)
	{
		return false;
	}

	t = glm::dot(edge2, qvec) * invDet;
	if (t >= minDistance && t <= maxDistance)
	{
		return true;
	}

	return false;
}

HOSTDEVICE inline bool HitTriangle(const SceneObjectGPU& object, const SceneGPU& scene, const ray_t& ray, rayCastHit_t& rayCastHit, float minDistance, float maxDistance)
{
	float t;
	if (!RaycastTriangle(ray, object.triangle.v0, object.triangle.v1, object.triangle.v2, minDistance, maxDistance, t)) return false;

	rayCastHit.distance = t;
	rayCastHit.point = ray.At(t);
	glm::vec3 edge1 = object.triangle.v1 - object.triangle.v0;
	glm::vec3 edge2 = object.triangle.v2 - object.triangle.v0;
	rayCastHit.normal = glm::normalize(glm::cross(edge1, edge2));
	rayCastHit.material = &scene.materials[object.materialIndex];

	return true;
}

HOSTDEVICE inline bool HitModel(const SceneObjectGPU& object, const SceneGPU& scene, const ray_t& ray, rayCastHit_t& rayCastHit, float minDistance, float maxDistance)
{
	//check for bounding sphere raycast

	// check cast ray with mesh triangles
	for (int i = 0; i < object.model.vertexCount; i += 3)
	{
		float t;
		if (RaycastSphere(ray, object.model.center, object.model.radius, minDistance, maxDistance, t)) return false;
		if (RaycastTriangle(ray, object.model.vertexBuffer[i], object.model.vertexBuffer[i + 1], object.model.vertexBuffer[i + 2], minDistance, maxDistance, t))
		{
			rayCastHit.distance = t;
			rayCastHit.point = ray.At(t);
			glm::vec3 edge1 = object.model.vertexBuffer[i + 1] - object.model.vertexBuffer[i];
			glm::vec3 edge2 = object.model.vertexBuffer[i + 2] - object.model.vertexBuffer[i];
			rayCastHit.normal = glm::normalize(glm::cross(edge1, edge2));
			rayCastHit.material = &scene.materials[object.materialIndex];
			return true;
		}
	}

	return false;
}

HOSTDEVICE inline bool SceneObjectGPU_Hit(const SceneObjectGPU& object, const SceneGPU& scene, const ray_t& ray, rayCastHit_t& rayCastHit, float minDistance, float maxDistance)
{
	switch (object.type)
	{
	case ObjectType::SPHERE:
		return HitSphere(object, scene, ray, rayCastHit, minDistance, maxDistance);
	case ObjectType::PLANE:
		return HitPlane(object, scene, ray, rayCastHit, minDistance, maxDistance);
	case ObjectType::TRIANGLE:
		return HitTriangle(object, scene, ray, rayCastHit, minDistance, maxDistance);
	case ObjectType::MODEL:
		return HitModel(object, scene, ray, rayCastHit, minDistance, maxDistance);
	}
	return false;
}