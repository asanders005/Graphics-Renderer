#pragma once
#include "MathUtils.cuh"
#include "CudaCompat.h"
#include <glm/glm.hpp>
#define GLM_ENABLE_EXPERIMENTAL
#include <glm/gtx/color_space.hpp>
#include <SDL.h>
#include <algorithm>

using color_t = SDL_Color;
using color3_t = glm::vec3;
using color4_t = glm::vec4;


//blending
enum class BlendMode
{
	NORMAL,
	ALPHA,
	ADDITIVE,
	MULTIPLY
};

namespace Color {
	inline color3_t HSVtoRGB(const glm::vec3& hsv)
	{
		return glm::rgbColor(hsv);
	}

	inline color3_t HSVtoRGB(float hue, float saturation, float value)
	{
		return glm::rgbColor(glm::vec3{ hue, saturation, value });
	}

	inline float LinearToGamma(float linear)
	{
		if (linear > 0) return std::sqrt(linear);
		return 0;
	}

	HOSTDEVICE color_t ColorConvert(const color4_t& color4);
	

	HOSTDEVICE inline color_t ColorConvert(const color3_t& color3)
	{
		color_t color;

		color.r = (uint8_t)(Math::Clamp(LinearToGamma(color3.r), 0.0f, 1.0f) * 255);
		color.g = (uint8_t)(Math::Clamp(LinearToGamma(color3.g), 0.0f, 1.0f) * 255);
		color.b = (uint8_t)(Math::Clamp(LinearToGamma(color3.b), 0.0f, 1.0f) * 255);
		color.a = 255;

		return color;
	}

	HOSTDEVICE inline color4_t ColorConvert(const color_t& color)
	{
		color4_t color4;

		color4.r = (Math::Clamp(color.r, (uint8_t)0, (uint8_t)255) / 255.0f);
		color4.g = (Math::Clamp(color.g, (uint8_t)0, (uint8_t)255) / 255.0f);
		color4.b = (Math::Clamp(color.b, (uint8_t)0, (uint8_t)255) / 255.0f);
		color4.a = (Math::Clamp(color.a, (uint8_t)0, (uint8_t)255) / 255.0f);

		return color4;
	}

	color_t NormalBlend(const color_t& src, const color_t& dst);
	color_t AlphaBlend(const color_t& src, const color_t& dst);
	color_t AdditiveBlend(const color_t& src, const color_t& dst);
	color_t MultiplyBlend(const color_t& src, const color_t& dst);

	void SetBlendMode(BlendMode blendMode);
	color_t ColorBlend(const color_t& src, const color_t& dst);
}