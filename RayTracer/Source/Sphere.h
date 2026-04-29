#pragma once
#include "SceneObject.h"

class Sphere : public SceneObject
{
public:
	Sphere() = default;
	Sphere(const Transform& transform, float radius, std::shared_ptr<MaterialGPU> material) :
		SceneObject{ transform, material },
		m_radius{ radius }
	{}

	float GetRadius() const { return m_radius; }

private:
	float m_radius{ 0 };
};