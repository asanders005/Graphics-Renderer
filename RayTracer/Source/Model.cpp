#include "Model.h"
#include "MathUtils.cuh"
#include <glm/glm.hpp>
#include <iostream>
#include <fstream>
#include <sstream>

void Model::Update()
{
	for (size_t i = 0; i < m_local_vertices.size(); i++)
	{
		auto temp = m_transform * glm::vec4{ m_local_vertices[i].x, m_local_vertices[i].y, m_local_vertices[i].z, 1 };
		m_vb[i] = vertex_t{ temp.x, temp.y, temp.z };
	}

	m_center = vec3{ 0 };
	for (auto& vertex : m_vb)
	{
		m_center += vertex;
	}
	m_center /= (float)m_vb.size();

	m_radius = 0;
	for (auto& vertex : m_vb)
	{
		float radius = Math::Length(vertex - m_center);
		m_radius = Math::Max(radius, m_radius);
	}
}

bool Model::Load(const std::string& filename)
{
	std::ifstream input(filename);

	if (!input.is_open())
	{
		std::cerr << "Error opening " << filename << std::endl;
		return false;
	}

	vertexbuffer_t vertices;
	std::string line;

	while (std::getline(input, line))
	{
		if (line.substr(0, 2) == "v ")
		{
			std::istringstream sstream{ line.substr(2) };
			vec3 position;
			sstream >> position.x;
			sstream >> position.y;
			sstream >> position.z;
			
			vertices.push_back(position);
		}
		else if (line.substr(0, 2) == "f ")
		{
			std::istringstream sstream{ line.substr(2) };
			std::string str;
			while (std::getline(sstream, str, ' '))
			{
				std::istringstream sstream(str);
				std::string indexString;

				size_t i = 0;
				unsigned int index[3] = { 0, 0, 0 };

				while (std::getline(sstream, indexString, '/'))
				{
					if (!indexString.empty())
					{
						std::istringstream indexStream{ indexString };
						indexStream >> index[i];
					}
					i++;
				}
				if (index[0])
				{
					vec3 position = vertices[index[0] - 1];
					m_local_vertices.push_back(position);
				}
			}
		}
	}

	m_vb.resize(m_local_vertices.size());
	input.close();
	return true;
}