#include "CudaCompat.h"
#include "Color.cuh"
#include <cassert>

namespace Color
{
	color_t(*blend_func)(const color_t& src, const color_t& dst);

	void SetBlendMode(BlendMode blendMode)
	{
		switch (blendMode)
		{
		case BlendMode::NORMAL:
			blend_func = NormalBlend;
			break;
		case BlendMode::ALPHA:
			blend_func = AlphaBlend;
			break;
		case BlendMode::ADDITIVE:
			blend_func = AdditiveBlend;
			break;
		case BlendMode::MULTIPLY:
			blend_func = MultiplyBlend;
			break;
		default:
			break;
		}
	}

	color_t ColorBlend(const color_t& src, const color_t& dst)
	{
		assert(blend_func);

		return blend_func(src, dst);
	}

	color_t NormalBlend(const color_t& src, const color_t& dst)
	{
		return src;
	}

	color_t AlphaBlend(const color_t& src, const color_t& dst)
	{
		uint8_t alpha = src.a;
		uint8_t inv_alpha = 255 - src.a;

		color_t color;
		color.r = (alpha * src.r + inv_alpha * dst.r) >> 8;
		color.g = (alpha * src.g + inv_alpha * dst.g) >> 8;
		color.b = (alpha * src.b + inv_alpha * dst.b) >> 8;
		color.a = src.a;

		return color;
	}

	color_t AdditiveBlend(const color_t& src, const color_t& dst)
	{
		color_t color;
		color.r = std::min(src.r + dst.r, 255);
		color.g = std::min(src.g + dst.g, 255);
		color.b = std::min(src.b + dst.b, 255);
		color.a = src.a;

		return color;
	}

	color_t MultiplyBlend(const color_t& src, const color_t& dst)
	{
		color_t color;

		color.r = (src.r * dst.r) >> 8;
		color.g = (src.g * dst.g) >> 8;
		color.b = (src.b * dst.b) >> 8;
		color.a = src.a;

		return color;
	}
}