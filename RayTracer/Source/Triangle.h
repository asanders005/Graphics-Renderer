#pragma once
#include "SceneObject.h"

class Triangle : public SceneObject
{
public:
	Triangle(const vec3& v1, const vec3& v2, const vec3& v3, std::shared_ptr<MaterialGPU> material) :
		SceneObject{ material },
		m_local_v1{ v1 },
		m_local_v2{ v2 },
		m_local_v3{ v3 }
	{}
	Triangle(const vec3& v1, const vec3& v2, const vec3& v3, const Transform& transform, std::shared_ptr<MaterialGPU> material) :
		SceneObject{ transform, material },
		m_local_v1{ v1 },
		m_local_v2{ v2 },
		m_local_v3{ v3 }
	{}

	void Update() override;

	vec3 GetV0() const { return m_v1; }
	vec3 GetV1() const { return m_v2; }
	vec3 GetV2() const { return m_v3; }

private:
	vec3 m_v1{ 0 };
	vec3 m_v2{ 0 };
	vec3 m_v3{ 0 };

	vec3 m_local_v1{ 0 };
	vec3 m_local_v2{ 0 };
	vec3 m_local_v3{ 0 };
};