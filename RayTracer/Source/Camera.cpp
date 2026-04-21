#include "Camera.h"
#include "MathUtils.cuh"
#include <glm/gtc/matrix_transform.hpp>

void Camera::SetView(const glm::vec3& eye, const glm::vec3& target, const glm::vec3& up)
{
	m_eye = eye;

	m_forward = glm::normalize(target - eye);
	m_right = glm::normalize(Math::Cross(up, m_forward));
	m_up = Math::Cross(m_forward, m_right);

	CalculateViewPlane();
}

void Camera::CalculateViewPlane()
{
	float theta = glm::radians(m_fov);

	float halfHeight = glm::tan(theta * 0.5f);
	float height = halfHeight * 2;
	float width = height * m_aspectRatio;

	m_horizontal = m_right * width;
	m_vertical = m_up * height;

	m_lowerLeft = m_eye - (m_horizontal * 0.5f) - (m_vertical * 0.5f) + m_forward;
}
