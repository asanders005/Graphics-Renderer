#pragma once
#include "CudaCompat.h"

struct vec4
{
	union
	{
		struct { float x, y, z, w; };
		struct { float r, g, b, a; };
	};

	vec4() = default;
	HOSTDEVICE vec4(float value) : x{ value }, y{ value }, z{ value }, w{ value } {}
	HOSTDEVICE vec4(float x, float y, float z, float w) : x{ x }, y{ y }, z{ z }, w{ w } {}
};