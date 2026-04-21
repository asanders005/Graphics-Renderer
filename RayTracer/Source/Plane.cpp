#include "Plane.h"
#include "MathUtils.cuh"

bool Plane::Hit(const ray_t& ray, rayCastHit_t& rayCastHit, float minDistance, float maxDistance)
{
	float t;
	
	if (!Raycast(ray, m_transform.position, m_transform.GetUp(), minDistance, maxDistance, t)) return false;

	rayCastHit.distance = t;
	rayCastHit.normal = glm::normalize(m_transform.GetUp());
	rayCastHit.point = ray.At(t);
	rayCastHit.material = GetMaterial();

    return true;
}

bool Plane::Raycast(const ray_t& ray, const glm::vec3& point, const glm::vec3& normal, float minDistance, float maxDistance, float& t)
{
	float denominator = glm::dot(ray.direction, normal);

	if (Math::approximately(denominator, 0)) return false;

	t = glm::dot((point - ray.origin), normal) / denominator;
	if (t < 0) return false;

	if (t <= minDistance || t >= maxDistance) return false;

	return true;
}
