#pragma once
#include "CudaCompat.h"

struct vec2
{
	float x, y;

	HOSTDEVICE vec2() : x(0), y(0) {}
	HOSTDEVICE vec2(float value) : x(value), y(value) {}
	HOSTDEVICE vec2(float x, float y) : x(x), y(y) {}

	HOSTDEVICE inline vec2 operator-() const
	{
		return vec2(-x, -y);
	}

	HOSTDEVICE inline vec2 operator+(const vec2& other) const
	{
		return vec2(x + other.x, y + other.y);
	}

	HOSTDEVICE inline vec2 operator-(const vec2& other) const
	{
		return vec2(x - other.x, y - other.y);
	}

	HOSTDEVICE inline vec2 operator*(const vec2& other) const
	{
		return vec2(x * other.x, y * other.y);
	}

	HOSTDEVICE inline vec2 operator*(float scalar) const
	{
		return vec2(x * scalar, y * scalar);
	}

	HOSTDEVICE inline vec2 operator/(const vec2& other) const
	{
		return vec2(other.x != 0 ? x / other.x : 0, other.y != 0 ? y / other.y : 0); // Avoid division by zero
	}

	HOSTDEVICE inline vec2 operator/(float scalar) const
	{
		if (scalar == 0) return vec2(0, 0); // Avoid division by zero
		return vec2(x / scalar, y / scalar);
	}

	HOSTDEVICE inline bool operator==(const vec2& other) const
	{
		return x == other.x && y == other.y;
	}

	HOSTDEVICE inline bool operator!=(const vec2& other) const
	{
		return !(*this == other);
	}

	HOSTDEVICE inline vec2& operator+=(const vec2& other)
	{
		x += other.x;
		y += other.y;
		return *this;
	}

	HOSTDEVICE inline vec2& operator-=(const vec2& other)
	{
		x -= other.x;
		y -= other.y;
		return *this;
	}

	HOSTDEVICE inline vec2& operator*=(float scalar)
	{
		x *= scalar;
		y *= scalar;
		return *this;
	}

	HOSTDEVICE inline vec2& operator/=(float scalar)
	{
		if (scalar == 0) return *this; // Avoid division by zero
		x /= scalar;
		y /= scalar;
		return *this;
	}
};