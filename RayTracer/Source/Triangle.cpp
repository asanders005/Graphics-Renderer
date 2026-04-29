#include "Triangle.h"
#include <glm/glm.hpp>

void Triangle::Update()
{
	auto v1 = m_transform * glm::vec4{ m_local_v1.x, m_local_v1.y, m_local_v1.z, 1 };
	auto v2 = m_transform * glm::vec4{ m_local_v2.x, m_local_v2.y, m_local_v2.z, 1 };
	auto v3 = m_transform * glm::vec4{ m_local_v3.x, m_local_v3.y, m_local_v3.z, 1 };

	m_v1 = vec3{ v1.x, v1.y, v1.z };
	m_v2 = vec3{ v2.x, v2.y, v2.z };
	m_v3 = vec3{ v3.x, v3.y, v3.z };
}