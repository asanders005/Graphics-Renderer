#pragma once
#include "SceneGPU.cuh"
#include "SceneObjectGPU.cuh"
#include "Ray.cuh"
#include "MathUtils.cuh"

HOSTDEVICE inline bool RaycastSphere(const ray_t* ray, const vec3* center, float radius, float minDistance, float maxDistance, float* t)
{
	//printf("Raycasting sphere at {%f, %f, %f} with radius %f\n", center->x, center->y, center->z, radius);

	// Vector from the ray origin to the center of the sphere
	vec3 oc = ray->origin - *center;

	// Coefficients for the quadratic equation
	// a = dot(ray direction, ray direction), which is the square of the length of the ray direction
	float a = Math::Dot(ray->direction, ray->direction);

	// b = 2 * dot(ray direction, oc), where oc is the vector from the ray origin to the sphere center
	float b = 2 * Math::Dot(ray->direction, oc);

	// c = dot(oc, oc) - radius^2, which accounts for the distance from the origin to the center minus the radius of the sphere
	float c = Math::Dot(oc, oc) - (radius * radius);

	// Discriminant of the quadratic equation: b^2 - 4ac
	// This tells us how many real solutions (hits) exist:
	// If discriminant < 0, no real solutions (no intersection)
	// If discriminant = 0, one solution (the ray grazes the sphere)
	// If discriminant > 0, two solutions (the ray hits the sphere twice)
	float discriminant = (b * b) - (4 * a * c);

	if (discriminant >= 0 && a != 0)
	{
		*t = (-b - sqrtf(discriminant)) / (2 * a);
		if (*t >= minDistance && *t <= maxDistance)
		{
			return true;
		}

		*t = (-b + sqrtf(discriminant)) / (2 * a);
		if (*t >= minDistance && *t <= maxDistance)
		{
			return true;
		}
	}

	return false;
}

HOSTDEVICE inline bool HitSphere(const SceneObjectGPU* object, const SceneGPU* scene, const ray_t* ray, rayCastHit_t* rayCastHit, float minDistance, float maxDistance)
{
	float t = -1;
	if (!RaycastSphere(ray, &object->position, object->sphere->radius * object->scale.x, minDistance, maxDistance, &t)) return false;
	
	rayCastHit->distance = t;
	rayCastHit->point = RayAt(ray, t);
	rayCastHit->normal = Math::Normalize(rayCastHit->point - object->position);
	rayCastHit->material = &scene->materials[object->materialIndex];

	return true;
}

HOSTDEVICE inline bool RaycastPlane(const ray_t* ray, const vec3& point, const vec3& normal, float minDistance, float maxDistance, float* t)
{
	//printf("Raycasting plane at {%f, %f, %f} with normal {%f, %f, %f}\n", point.x, point.y, point.z, normal.x, normal.y, normal.z);
	//printf("Ray origin: {%f, %f, %f}, direction: {%f, %f, %f}\n", ray->origin.x, ray->origin.y, ray->origin.z, ray->direction.x, ray->direction.y, ray->direction.z);

	float denominator = Math::Dot(ray->direction, normal);
	//printf("Denominator (dot product of ray direction {%f, %f, %f} and plane normal {%f, %f, %f}): %f\n", ray->direction.x, ray->direction.y, ray->direction.z, normal.x, normal.y, normal.z, denominator);

	if (Math::approximately(denominator, 0)) return false;

	*t = Math::Dot((point - ray->origin), normal) / denominator;
	if (*t < 0) return false;

	if (*t <= minDistance || *t >= maxDistance) return false;

	return true;
}

HOSTDEVICE inline bool HitPlane(const SceneObjectGPU* object, const SceneGPU* scene, const ray_t* ray, rayCastHit_t* rayCastHit, float minDistance, float maxDistance)
{

	/*printf("HitPlane called for plane with material %d at position {%f, %f, %f}, rotation {%f, %f, %f}, and scale {%f, %f, %f} with normal {%f, %f, %f}\n",
		object->materialIndex, object->position.x, object->position.y, object->position.z,
		object->rotation.x, object->rotation.y, object->rotation.z,
		object->scale.x, object->scale.y, object->scale.z,
		object->plane->normal.x, object->plane->normal.y, object->plane->normal.z);*/

	float t = -1;

	if (!RaycastPlane(ray, object->position, object->plane->normal, minDistance, maxDistance, &t)) return false;

	//printf("Hit plane at distance %f with normal {%f, %f, %f}\n", t, object->plane.normal.x, object->plane.normal.y, object->plane.normal.z);
	rayCastHit->distance = t;
	rayCastHit->normal = Math::Normalize(object->plane->normal);
	rayCastHit->point = RayAt(ray, t);

	if (object->materialIndex < 0 || object->materialIndex >= scene->numMaterials) {
		printf("Invalid material index: %d for plane object\n", object->materialIndex);
		return false;
	}
	if (object->materialIndex != 0)
	{
		printf("Plane material index: %d; color: (%f, %f, %f)\n", object->materialIndex, scene->materials[object->materialIndex].albedo.x, scene->materials[object->materialIndex].albedo.y, scene->materials[object->materialIndex].albedo.z);
	}
	rayCastHit->material = &scene->materials[object->materialIndex];

	return true;
}

HOSTDEVICE inline bool RaycastTriangle(const ray_t* ray, const  vec3* v0, const  vec3* v1, const  vec3* v2, float minDistance, float maxDistance, float* t)
{
	//printf("Raycasting triangle with vertices {%f, %f, %f}, {%f, %f, %f}, {%f, %f, %f}\n", v0->x, v0->y, v0->z, v1->x, v1->y, v1->z, v2->x, v2->y, v2->z);

	 vec3 edge1 = *v1 - *v0;
	 vec3 edge2 = *v2 - *v0;

	 vec3 pvec = Math::Cross(ray->direction, edge2);
	float determinant = Math::Dot(pvec, edge1);

	if (determinant < 0 || Math::approximately(determinant, 0))
	{
		return false;
	}

	float invDet = 1 / determinant;

	 vec3 tvec = ray->origin - *v0;
	float u = Math::Dot(tvec, pvec) * invDet;

	if (u < 0 || u > 1)
	{
		return false;
	}

	 vec3 qvec = Math::Cross(tvec, edge1);
	float v = Math::Dot(qvec, ray->direction) * invDet;

	if (v < 0 || u + v > 1)
	{
		return false;
	}

	*t = Math::Dot(edge2, qvec) * invDet;
	if (*t >= minDistance && *t <= maxDistance)
	{
		return true;
	}

	return false;
}

HOSTDEVICE inline bool HitTriangle(const SceneObjectGPU* object, const SceneGPU* scene, const ray_t* ray, rayCastHit_t* rayCastHit, float minDistance, float maxDistance)
{
	float t = -1;
	if (!RaycastTriangle(ray, &object->triangle->v0, &object->triangle->v1, &object->triangle->v2, minDistance, maxDistance, &t)) return false;

	rayCastHit->distance = t;
	rayCastHit->point = RayAt(ray, t);
	 vec3 edge1 = object->triangle->v1 - object->triangle->v0;
	 vec3 edge2 = object->triangle->v2 - object->triangle->v0;
	rayCastHit->normal = Math::Normalize(Math::Cross(edge1, edge2));
	rayCastHit->material = &scene->materials[object->materialIndex];

	return true;
}

HOSTDEVICE inline bool HitModel(const SceneObjectGPU* object, const SceneGPU* scene, const ray_t* ray, rayCastHit_t* rayCastHit, float minDistance, float maxDistance)
{
	//check for bounding sphere raycast
	if (!object->model || !object->model->vertexBuffer || object->model->vertexCount % 3 != 0)
	{
		if (object->model)
			printf("[HitModel] ERROR: VertexCount not a multiple of 3: %d\n", object->model->vertexCount);
		else
			printf("[HitModel] ERROR: Model data is null\n");
		return false;
	}

	float t;
	if (!RaycastSphere(ray, &object->model->center, object->model->radius, minDistance, maxDistance, &t)) return false;
	// check cast ray with mesh triangles
	for (int i = 0; i < object->model->vertexCount; i += 3)
	{
		/*printf("Testing triangle %d with vertices {%f, %f, %f}, {%f, %f, %f}, {%f, %f, %f}\n", i / 3,
			object->model->vertexBuffer[i].x, object->model->vertexBuffer[i].y, object->model->vertexBuffer[i].z,
			object->model->vertexBuffer[i + 1].x, object->model->vertexBuffer[i + 1].y, object->model->vertexBuffer[i + 1].z,
			object->model->vertexBuffer[i + 2].x, object->model->vertexBuffer[i + 2].y, object->model->vertexBuffer[i + 2].z);*/
		if (RaycastTriangle(ray, &object->model->vertexBuffer[i], &object->model->vertexBuffer[i + 1], &object->model->vertexBuffer[i + 2], minDistance, maxDistance, &t))
		{
			rayCastHit->distance = t;
			rayCastHit->point = RayAt(ray, t);
			 vec3 edge1 = object->model->vertexBuffer[i + 1] - object->model->vertexBuffer[i];
			 vec3 edge2 = object->model->vertexBuffer[i + 2] - object->model->vertexBuffer[i];
			rayCastHit->normal = Math::Normalize(Math::Cross(edge1, edge2));
			rayCastHit->material = &scene->materials[object->materialIndex];
			return true;
		}
	}

	return false;
}

HOSTDEVICE inline bool SceneObjectGPU_Hit(const SceneObjectGPU* object, const SceneGPU* scene, const ray_t* ray, rayCastHit_t* rayCastHit, float minDistance, float maxDistance)
{
	if (!object || !scene) return false;

	if (!scene->materials || object->materialIndex < 0 || object->materialIndex >= scene->numMaterials) {
		printf("Invalid material index: %d for object type %d\n", object->materialIndex, object->type);
		return false;
	}
	/*if (object->materialIndex != 0)
	{
		printf("Object type: %d; material index: %d; color: (%f, %f, %f)\n", (int)object->type, object->materialIndex, scene->materials[object->materialIndex].albedo.x, scene->materials[object->materialIndex].albedo.y, scene->materials[object->materialIndex].albedo.z);
	}*/

	switch (object->type)
	{
	case ObjectType::SPHERE:
		return HitSphere(object, scene, ray, rayCastHit, minDistance, maxDistance);
	case ObjectType::PLANE:
		return HitPlane(object, scene, ray, rayCastHit, minDistance, maxDistance);
	case ObjectType::TRIANGLE:
		return HitTriangle(object, scene, ray, rayCastHit, minDistance, maxDistance);
	case ObjectType::MODEL:
		return HitModel(object, scene, ray, rayCastHit, minDistance, maxDistance);
	default:
		printf("Unknown object type: %d\n", (int)object->type);
		return false;
	}
}