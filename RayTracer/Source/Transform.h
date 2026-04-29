#pragma once
#include "vec3.cuh"

#define GLM_ENABLE_EXPERIMENTAL
#include <glm/gtx/transform.hpp>
#include <glm/gtx/euler_angles.hpp>
#include <glm/glm.hpp>

struct Transform
{
	glm::vec3 position{ 0 };
	glm::vec3 rotation{ 0 };
	glm::vec3 scale{ 1 };
	
	Transform() = default;
	Transform(const glm::vec3& position, 
		const glm::vec3& rotation = glm::vec3{ 0 }, 
		const glm::vec3& scale = glm::vec3{1}) : 
		position{position}, 
		rotation{rotation}, 
		scale{scale} 
	{}
	Transform(const vec3& position, 
		const vec3& rotation = vec3{ 0 },
		const vec3& scale = vec3{ 1 }) :
		position{ glm::vec3{ position.x, position.y, position.z } },
		rotation{ glm::vec3{ rotation.x, rotation.y, rotation.z } },
		scale{ glm::vec3{ scale.x, scale.y, scale.z } }
	{}

	glm::mat4 GetMatrix() const
	{
		glm::mat4 mxs = glm::scale(scale);
		glm::mat4 mxt = glm::translate(position);
		glm::mat4 mxr = glm::eulerAngleYXZ(glm::radians(rotation.y), glm::radians(rotation.x), glm::radians(rotation.z));

		return mxt * mxs * mxr;
	}

	glm::vec3 GetForward() const
	{
		glm::mat4 mxr = glm::eulerAngleYXZ(glm::radians(rotation.y), glm::radians(rotation.x), glm::radians(rotation.z));
		return mxr * glm::vec4{ 0, 0, 1, 0 };
	}

	glm::vec3 GetUp() const
	{
		glm::mat4 mxr = glm::eulerAngleYXZ(glm::radians(rotation.y), glm::radians(rotation.x), glm::radians(rotation.z));

		return mxr * glm::vec4{ 0, 1, 0, 0 };
	}

	glm::vec3 GetRight() const
	{
		glm::mat4 mxr = glm::eulerAngleYXZ(glm::radians(rotation.y), glm::radians(rotation.x), glm::radians(rotation.z));

		return mxr * glm::vec4{ 1, 0, 0, 0 };
	}

	glm::vec4 operator * (const glm::vec4& v)
	{
		return GetMatrix() * v;
	}
};