#pragma once
#include "Color.h"
#include "SceneObject.h"

#include <glm/glm.hpp>
#include <vector>
#include <string>

using vertex_t = glm::vec3;
using vertexbuffer_t = std::vector<vertex_t>;

class Model : public SceneObject
{
public:
	Model(std::shared_ptr<MaterialGPU> material) : SceneObject{ material } {}
	Model(const Transform& transform, std::shared_ptr<MaterialGPU> material) : SceneObject{ transform, material } {}
	Model(const vertexbuffer_t& vertices, const Transform& transform, std::shared_ptr<MaterialGPU> material) : SceneObject{ transform, material }, m_local_vertices { vertices } {}

	void Update() override;

	bool Load(const std::string& filename);
	bool Hit(const ray_t& ray, rayCastHit_t& rayCastHit, float minDistance, float maxDistance) override;

	int GetVertexCount() const { return (int)m_vb.size(); }
	vertex_t GetVertex(int index) const { return m_vb[index]; }
	glm::vec3 GetCenter() const { return m_center; }
	float GetBoundingSphereRadius() const { return m_radius; }

private:
	vertexbuffer_t m_vb;
	vertexbuffer_t m_local_vertices;
	glm::vec3 m_center{ 0, 0, 0 };
	float m_radius = 0;
};