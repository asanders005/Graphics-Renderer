#pragma once
#include <glm/glm.hpp>

enum class MaterialType : int
{
	LAMBERTIAN,
	METAL,
	DIELECTRIC,
	EMISSIVE
};

struct MaterialGPU
{
	MaterialType type;
	glm::vec3 albedo;
	float fuzz;				// for metal
	float refractiveIndex;	// for dielectric
	float intensity;		// for emissive

	bool operator==(const MaterialGPU& other) const
	{
		return type == other.type &&
			albedo == other.albedo &&
			fuzz == other.fuzz &&
			refractiveIndex == other.refractiveIndex &&
			intensity == other.intensity;
	}
};