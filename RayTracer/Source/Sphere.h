#pragma once
#include "SceneObject.h"
#include <glm/glm.hpp>

class Sphere : public SceneObject
{
public:
	Sphere() = default;
	Sphere(const Transform& transform, float radius, std::shared_ptr<MaterialGPU> material) :
		SceneObject{ transform, material },
		m_radius{ radius }
	{}

	bool Hit(const ray_t& ray, rayCastHit_t& rayCastHit, float minDistance, float maxDistance) override;
	static bool Raycast(const ray_t& ray, const glm::vec3& center, float radius, float minDistance, float maxDistance, float& t);

	float GetRadius() const { return m_radius; }

private:
	float m_radius{ 0 };
};