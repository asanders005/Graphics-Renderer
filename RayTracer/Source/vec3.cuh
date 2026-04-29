#pragma once
#include "CudaCompat.h"
#include <glm/glm.hpp>

struct vec3
{
	union {
		struct { float x, y, z; };
		struct { float r, g, b; };
	};

	HOSTDEVICE vec3() : x(0), y(0), z(0) {}
	HOSTDEVICE vec3(float value) : x(value), y(value), z(value) {}
	HOSTDEVICE vec3(float x, float y, float z) : x(x), y(y), z(z) {}
	vec3(const glm::vec3& v) : x(v.x), y(v.y), z(v.z) {}

	HOSTDEVICE inline vec3 operator-() const
	{
		return vec3(-x, -y, -z);
	}

	HOSTDEVICE inline vec3 operator+(const vec3& other) const
	{
		return vec3(x + other.x, y + other.y, z + other.z);
	}

	HOSTDEVICE inline vec3 operator-(const vec3& other) const
	{
		return vec3(x - other.x, y - other.y, z - other.z);
	}

	HOSTDEVICE inline vec3 operator*(const vec3& other) const
	{
		return vec3(x * other.x, y * other.y, z * other.z);
	}

	HOSTDEVICE inline vec3 operator*(float scalar) const
	{
		return vec3(x * scalar, y * scalar, z * scalar);
	}

	HOSTDEVICE inline vec3 operator/(const vec3& other) const
	{
		return vec3(
			other.x != 0 ? x / other.x : 0,
			other.y != 0 ? y / other.y : 0,
			other.z != 0 ? z / other.z : 0
		);
	}

	HOSTDEVICE inline vec3 operator/(float scalar) const
	{
		if (scalar == 0) return vec3(0, 0, 0); // Avoid division by zero
		return vec3(x / scalar, y / scalar, z / scalar);
	}

	HOSTDEVICE inline vec3& operator+=(const vec3& other)
	{
		x += other.x;
		y += other.y;
		z += other.z;
		return *this;
	}

	HOSTDEVICE inline vec3& operator-=(const vec3& other)
	{
		x -= other.x;
		y -= other.y;
		z -= other.z;
		return *this;
	}

	HOSTDEVICE inline vec3& operator*=(const vec3& other)
	{
		x *= other.x;
		y *= other.y;
		z *= other.z;
		return *this;
	}

	HOSTDEVICE inline vec3& operator*=(float scalar)
	{
		x *= scalar;
		y *= scalar;
		z *= scalar;
		return *this;
	}

	HOSTDEVICE inline vec3& operator/=(const vec3& other)
	{
		x = other.x != 0 ? x / other.x : 0;
		y = other.y != 0 ? y / other.y : 0;
		z = other.z != 0 ? z / other.z : 0;
		return *this;
	}

	HOSTDEVICE inline vec3& operator/=(float scalar)
	{
		if (scalar == 0) {
			x = y = z = 0; // Avoid division by zero
		} else {
			x /= scalar;
			y /= scalar;
			z /= scalar;
		}
		return *this;
	}

	HOSTDEVICE inline bool operator==(const vec3& other) const
	{
		return x == other.x && y == other.y && z == other.z;
	}

	HOSTDEVICE inline bool operator!=(const vec3& other) const
	{
		return !(*this == other);
	}
};

HOSTDEVICE inline vec3 operator*(float scalar, const vec3& v)
{
	return v * scalar;
}