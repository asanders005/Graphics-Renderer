#pragma once
#define FLT_EPSILON 1.192092896e-07F
#include "CudaCompat.h"
#include "vec2.cuh"
#include "vec3.cuh"

namespace Math
{
	HOSTDEVICE inline float Max(float a, float b)
	{
		return (a > b) ? a : b;
	}

	HOSTDEVICE inline float Min(float a, float b)
	{
		return (a < b) ? a : b;
	}

	HOSTDEVICE inline float Sqrtf(float value)
	{
		return sqrtf(value);
	}

	HOSTDEVICE inline float Length(const vec2& v)
	{
		return sqrtf(v.x * v.x + v.y * v.y);
	}

	HOSTDEVICE inline float Length(const vec3& v)
	{
		return sqrtf(v.x * v.x + v.y * v.y + v.z * v.z);
	}

	HOSTDEVICE inline float Degrees(float radians)
	{
		return radians * (180.0f / 3.14159265358979323846f);
	}

	HOSTDEVICE inline float Radians(float degrees)
	{
		return degrees * (3.14159265358979323846f / 180.0f);
	}

	HOSTDEVICE inline float Dot(const vec3& v1, const vec3& v2)
	{
		return (v1.x * v2.x) + (v1.y * v2.y) + (v1.z * v2.z);
	}

	HOSTDEVICE inline vec3 Normalize(const vec3& v)
	{
		float length = Dot(v, v);
		if (length > 0)
		{
			float invLength = 1.0f / sqrtf(length);
			return v * invLength;
		}
		return v; // Return the original vector if its length is zero to avoid division by zero
	}

	HOSTDEVICE inline float Angle(const vec3& v1, const vec3& v2)
	{
		return acosf(Dot(Normalize(v1), Normalize(v2)));
	}

	HOSTDEVICE inline vec3 Cross(const vec3& v1, const vec3& v2)
	{
		vec3 result;

		result.x = (v1.y * v2.z) - (v2.y * v1.z);
		result.y = (v1.z * v2.x) - (v2.z * v1.x);
		result.z = (v1.x * v2.y) - (v2.x * v1.y);

		return result;
	}

	template<typename T>
	HOSTDEVICE inline T Clamp(const T& value, const T& min, const T& max)
	{
		return (value < min) ? min : (value > max) ? max : value;
	}

	HOSTDEVICE inline bool approximately(float value1, float value2)
	{
		// check if the difference between the values is less than epsilon
#ifdef __CUDA_ARCH__
		return fabsf(value1 - value2) < FLT_EPSILON;
#else
		return (std::fabs(value1 - value2) < FLT_EPSILON);
#endif
	}

	template<typename T>
	HOSTDEVICE inline T Lerp(const T& a, const T& b, float t)
	{
		return static_cast<T>(a + (t * (b - a)));
	}

	HOSTDEVICE inline vec3 Reflect(const vec3& incident, const vec3& normal)
	{
		return incident - (normal * Dot(normal, incident)) * 2.0f;
	}

	HOSTDEVICE inline bool Refract(const vec3& incident, const vec3& normal, float refractiveIndex, vec3& refracted)
	{
		vec3 normalIncident = Normalize(incident);
		float cosine = Dot(normalIncident, normal);

		float discriminant = 1 - (refractiveIndex * refractiveIndex) * (1 - cosine * cosine);
		if (discriminant > 0)
		{
			refracted = (normalIncident - (normal * cosine)) - (normal * sqrtf(discriminant)) * refractiveIndex;
			return true;
		}

		return false;
	}

	HOSTDEVICE inline float Schlick(float cosine, float index)
	{
		// Step 1: Calculate the base reflectance at zero incidence (angle = 0)
		// This is the reflection coefficient when the light hits the surface straight on
		float r0 = (1.0f - index) / (1.0f + index);
		r0 = r0 * r0;

		// Step 2: Use Schlick's approximation to adjust reflectance based on angle
		// Schlick’s approximation gives the probability of reflection at an angle `cosine`
		// It interpolates between `r0` and 1, with stronger reflection at glancing angles
#ifdef __CUDA_ARCH__
		return r0 + (1.0f - r0) * powf((1.0f - cosine), 5);
#else
		return r0 + (1.0f - r0) * (float)std::pow((1.0f - cosine), 5);
#endif
	}



	HOSTDEVICE inline void QuadraticPoint(int x1, int y1, int x2, int y2, int x3, int y3, float t, int& x, int& y)
	{
		float omt = 1 - t;

		float a = omt * omt;
		float b = 2 * omt * t;
		float c = t * t;

		x = (int)((a * x1) + (b * x2) + (c * x3));
		y = (int)((a * y1) + (b * y2) + (c * y3));
	}

	HOSTDEVICE inline void CubicPoint(int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4, float t, int& x, int& y)
	{
		float omt = 1 - t;

		float a = omt * omt * omt;
		float b = 3 * (omt * omt) * t;
		float c = 3 * omt * (t * t);
		float d = t * t * t;

		x = (int)((a * x1) + (b * x2) + (c * x3) + (d * x4));
		y = (int)((a * y1) + (b * y2) + (c * y3) + (d * y4));
	}
}