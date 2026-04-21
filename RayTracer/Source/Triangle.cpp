#include "Triangle.h"
#include "MathUtils.cuh"

void Triangle::Update()
{
	m_v1 = m_transform * glm::vec4{ m_local_v1, 1 };
	m_v2 = m_transform * glm::vec4{ m_local_v2, 1 };
	m_v3 = m_transform * glm::vec4{ m_local_v3, 1 };
}

bool Triangle::Hit(const ray_t& ray, rayCastHit_t& rayCastHit, float minDistance, float maxDistance)
{
	float t;
	if (!Raycast(ray, m_v1, m_v2, m_v3, minDistance, maxDistance, t)) return false;
	
	rayCastHit.distance = t;
	rayCastHit.point = ray.At(t);
	glm::vec3 edge1 = m_v2 - m_v1;
	glm::vec3 edge2 = m_v3 - m_v1;
	rayCastHit.normal = glm::normalize(glm::cross(edge1, edge2));
	rayCastHit.material = GetMaterial();

	return true;
}

bool Triangle::Raycast(const ray_t& ray, const glm::vec3& v1, const glm::vec3& v2, const glm::vec3& v3, float minDistance, float maxDistance, float& t)
{
	glm::vec3 edge1 = v2 - v1;
	glm::vec3 edge2 = v3 - v1;

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
