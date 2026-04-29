#pragma once

struct SceneGPU
{
	struct SceneObjectGPU* objects;
	int numObjects;

	struct MaterialGPU* materials;
	int numMaterials;

	vec3 skyBottom;
	vec3 skyTop;
};