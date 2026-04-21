#pragma once
#include "SceneObject.h"

class Plane : public SceneObject
{
public:
	Plane() = default;
	Plane(const Transform& transform, std::shared_ptr<MaterialGPU> material) :
		SceneObject{ transform, material }
	{}

	bool Hit(const ray_t& ray, rayCastHit_t& rayCastHit, float minDistance, float maxDistance) override;
	static bool Raycast(const ray_t& ray, const glm::vec3& point, const glm::vec3& normal, float minDistance, float maxDistance, float& t);

	glm::vec3 GetNormal() const { return m_transform.GetForward(); }
};