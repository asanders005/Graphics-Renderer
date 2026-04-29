#pragma once
#include "SceneObject.h"

class Plane : public SceneObject
{
public:
	Plane() = default;
	Plane(const Transform& transform, std::shared_ptr<MaterialGPU> material) :
		SceneObject{ transform, material }
	{}

	vec3 GetNormal() const { return m_transform.GetForward(); }
};