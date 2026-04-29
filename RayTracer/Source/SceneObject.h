#pragma once
#include "MaterialGPU.h"
#include "Transform.h"
#include <memory>

class SceneObject
{
public:
	SceneObject(std::shared_ptr<MaterialGPU> material) : m_material{ material } {}
	SceneObject(const Transform& transform, std::shared_ptr<MaterialGPU> material) : m_transform{ transform }, m_material{ material } {}

	virtual void Update() {}
	
	MaterialGPU* GetMaterial() { return m_material.get(); }

	Transform& GetTransform() { return m_transform; }
	const Transform& GetTransform() const { return m_transform; }

protected:
	std::shared_ptr<MaterialGPU> m_material;
	Transform m_transform;
};