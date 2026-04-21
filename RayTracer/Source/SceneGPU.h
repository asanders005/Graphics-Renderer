#pragma once
#include "MaterialGPU.h"

struct SceneGPU
{
	struct SceneObjectGPU* objects;
	int numObjects;

	MaterialGPU* materials;
	int numMaterials;

	glm::vec3 skyBottom;
	glm::vec3 skyTop;
};