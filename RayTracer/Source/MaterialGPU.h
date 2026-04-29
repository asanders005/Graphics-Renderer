#pragma once
#include "vec3.cuh"

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
	vec3 albedo;
	float fuzz;				// for metal
	float refractiveIndex;	// for dielectric
	float intensity;		// for emissive

	bool operator==(const MaterialGPU& other) const
	{
		bool typeCompare = false;
		switch (type)
		{
		case MaterialType::LAMBERTIAN:
			typeCompare = true;
			break;
		case MaterialType::METAL:
			typeCompare = fuzz == other.fuzz;
			break;
		case MaterialType::DIELECTRIC:
			typeCompare = refractiveIndex == other.refractiveIndex;
			break;
		case MaterialType::EMISSIVE:
			typeCompare = intensity == other.intensity;
			break;
		}

		return type == other.type &&
			albedo == other.albedo &&
			typeCompare;
	}
};