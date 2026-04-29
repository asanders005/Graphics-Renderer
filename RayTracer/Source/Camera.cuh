#pragma once
#include "Ray.cuh"
#include "CudaCompat.h"
#include "MathUtils.cuh"

#include <iostream>

class Camera
{
public:
	Camera() = default;
	Camera(float fov, float aspectRatio) : m_fov{ fov }, m_aspectRatio{ aspectRatio } {}

	inline void SetView(const vec3& eye, const vec3& target, const vec3& up = { 0, 1, 0 })
	{
		m_eye = eye;

		m_forward = Math::Normalize(target - eye);
		m_right = Math::Normalize(Math::Cross(up, m_forward));
		m_up = Math::Normalize(Math::Cross(m_forward, m_right));

		CalculateViewPlane();
	}


	void SetFOV(float fov) { m_fov = fov; }

private:
	inline void CalculateViewPlane()
	{
		float theta = Math::Radians(m_fov);

		float halfHeight = tan(theta * 0.5f);
		float height = halfHeight * 2;
		float width = height * m_aspectRatio;

		m_horizontal = m_right * width;
		m_vertical = m_up * height;

		m_lowerLeft = m_eye - (m_horizontal * 0.5f) - (m_vertical * 0.5f) + m_forward;
	}

public:
	float m_fov{ 60 }; // fov in degrees
	float m_aspectRatio{ 1 }; // screen width / screen height

	vec3 m_eye;

	// camera axis
	vec3 m_forward;
	vec3 m_right;
	vec3 m_up;

	// view plane origin and horizontal and vertical direction vectors
	vec3 m_lowerLeft;
	vec3 m_horizontal;
	vec3 m_vertical;
};

struct CameraGPU
{
	vec3 eye;

	// view plane origin and horizontal and vertical direction vectors
	vec3 lowerLeft;
	vec3 horizontal;
	vec3 vertical;
};

HOSTDEVICE inline ray_t GetCameraRay(vec2 point, CameraGPU* camera)
{
	ray_t ray;

	ray.origin = camera->eye;
	ray.direction = Math::Normalize((camera->lowerLeft + (camera->horizontal * point.x) + (camera->vertical * point.y)) - camera->eye);

	return ray;
}
