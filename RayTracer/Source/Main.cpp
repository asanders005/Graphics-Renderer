#include "Renderer.h"
#include "Framebuffer.h"
#include "MathUtils.cuh"
#include "Image.h"
#include "PostProcess.h"
#include "Model.h"
#include "ETime.h"
#include "Transform.h"
#include "Input.h"
#include "Camera.cuh"
#include "Scene.h"
#include "HostRandom.h"

#include <iostream>
#include <memory>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

//void InitScene(Scene& scene);
//void InitScene01(Scene& scene, Camera& camera);
void InitCornellBox(Scene& scene);
//void InitFinalScene(Scene& scene);
//void InitECScene(Scene& scene, Camera& camera);

int main(int argc, char* argv[])
{
	srand((unsigned int)time(0));

	Time time;

	Renderer renderer;
	renderer.Initialize();
	renderer.CreateWindow("Ray Tracer", 800, 600);

	Framebuffer framebuffer{ renderer, renderer.GetWidth(), renderer.GetHeight() };

	Camera camera{ 70.0f, (float)renderer.GetWidth() / renderer.GetHeight() };
	camera.SetView({ 0, 0, -10}, { 0, 0, 0 });

	Scene scene;
	//InitScene(scene);
	//InitScene01(scene, camera);
	InitCornellBox(scene);
	//InitFinalScene(scene);
	//InitECScene(scene, camera);

	scene.Update();
	scene.Render(framebuffer, camera, 50, 4);

	bool quit = false;
	while (!quit)
	{
		time.Tick();

		SDL_Event event;
		while (SDL_PollEvent(&event))
		{
			if (event.type == SDL_QUIT)
			{
				quit = true;
			}
			if (event.type == SDL_KEYDOWN && event.key.keysym.sym == SDLK_ESCAPE)
			{
				quit = true;
			}
		}

		//renderer->BeginFrame();

		framebuffer.Update();

		renderer.CopyFramebuffer(framebuffer);

		renderer.EndFrame();
	}

	return 0;
}

//void InitScene(Scene& scene)
//{
//	scene.SetSky(Color::HSVtoRGB(240, 0.75f, 0.1f), Color::HSVtoRGB(290, 0.5f, 0.5f));
//#pragma region MaterialCreation
//	std::shared_ptr<Material> dark = std::make_shared<Metal>(Color::HSVtoRGB(290, 0.85f, 0.025f), 0.0f);
//	std::shared_ptr<Material> red = std::make_shared<Lambertian>(color3_t{ 1.0f, 0.0f, 0.0f });
//	std::shared_ptr<Material> orange = std::make_shared<Lambertian>(color3_t{ 1.0f, 0.5f, 0.0f });
//	std::shared_ptr<Material> yellow = std::make_shared<Lambertian>(color3_t{ 0.85f, 1.0f, 0.0f });
//	std::shared_ptr<Material> green = std::make_shared<Lambertian>(color3_t{ 0.0f, 1.0f, 0.0f });
//	std::shared_ptr<Material> turqoise = std::make_shared<Lambertian>(color3_t{ 0.0f, 0.75f, 0.75f });
//	std::shared_ptr<Material> blue = std::make_shared<Lambertian>(color3_t{ 0.0f, 0.0f, 1.0f });
//	std::shared_ptr<Material> purple = std::make_shared<Lambertian>(color3_t{ 0.35f, 0.0f, 0.75f });
//	std::shared_ptr<Material> grey = std::make_shared<Lambertian>(color3_t{ 0.5f, 0.5f, 0.5f });
//	std::shared_ptr<Material> Metalred = std::make_shared<Metal>(color3_t{ 1.0f, 0.0f, 0.0f }, 0.3f);
//	std::shared_ptr<Material> Metalorange = std::make_shared<Metal>(color3_t{ 1.0f, 0.5f, 0.0f }, 0.1f);
//	std::shared_ptr<Material> Metalyellow = std::make_shared<Metal>(color3_t{ 0.85f, 1.0f, 0.0f }, 0.3f);
//	std::shared_ptr<Material> Metalgreen = std::make_shared<Metal>(color3_t{ 0.0f, 1.0f, 0.0f }, 0.1f);
//	std::shared_ptr<Material> Metalturqoise = std::make_shared<Metal>(color3_t{ 0.0f, 0.75f, 0.75f }, 0.1f);
//	std::shared_ptr<Material> Metalblue = std::make_shared<Metal>(color3_t{ 0.0f, 0.0f, 1.0f }, 0.3f);
//	std::shared_ptr<Material> Metalpurple = std::make_shared<Metal>(color3_t{ 0.35f, 0.0f, 0.75f }, 0.1f);
//	std::shared_ptr<Material> Metalgrey = std::make_shared<Metal>(color3_t{ 0.5f, 0.5f, 0.5f }, 0.5f);
//	std::shared_ptr<Material> Emissivered = std::make_shared<Emissive>(color3_t{ 1.0f, 0.0f, 0.0f }, 10.0f);
//	std::shared_ptr<Material> Emissiveorange = std::make_shared<Emissive>(color3_t{ 1.0f, 0.5f, 0.0f }, 7.5f);
//	std::shared_ptr<Material> Emissiveyellow = std::make_shared<Emissive>(color3_t{ 0.85f, 1.0f, 0.0f }, 9.5f);
//	std::shared_ptr<Material> Emissivegreen = std::make_shared<Emissive>(color3_t{ 0.0f, 1.0f, 0.0f }, 15.0f);
//	std::shared_ptr<Material> Emissiveturqoise = std::make_shared<Emissive>(color3_t{ 0.0f, 0.75f, 0.75f }, 17.5f);
//	std::shared_ptr<Material> Emissiveblue = std::make_shared<Emissive>(color3_t{ 0.0f, 0.0f, 1.0f }, 20.0f);
//	std::shared_ptr<Material> Emissivepurple = std::make_shared<Emissive>(color3_t{ 0.35f, 0.0f, 0.75f }, 12.5f);
//	std::shared_ptr<Material> Dielectricwhite = std::make_shared<Dielectric>(color3_t{ 1.0f, 1.0f, 1.0f }, 2.42f);
//	std::shared_ptr<Material> Dielectricred = std::make_shared<Dielectric>(color3_t{ 1.0f, 0.0f, 0.0f }, 1.33f);
//	std::shared_ptr<Material> Dielectricorange = std::make_shared<Dielectric>(color3_t{ 1.0f, 0.5f, 0.0f }, 1.33f);
//	std::shared_ptr<Material> Dielectricyellow = std::make_shared<Dielectric>(color3_t{ 0.85f, 1.0f, 0.0f }, 1.33f);
//	std::shared_ptr<Material> Dielectricgreen = std::make_shared<Dielectric>(color3_t{ 0.0f, 1.0f, 0.0f }, 1.33f);
//	std::shared_ptr<Material> Dielectricturqoise = std::make_shared<Dielectric>(color3_t{ 0.0f, 0.75f, 0.75f }, 1.33f);
//	std::shared_ptr<Material> Dielectricblue = std::make_shared<Dielectric>(color3_t{ 0.0f, 0.0f, 1.0f }, 1.33f);
//	std::shared_ptr<Material> Dielectricpurple = std::make_shared<Dielectric>(color3_t{ 0.35f, 0.0f, 0.75f }, 2.42f);
//
//	std::vector<std::shared_ptr<Material>> materials;
//
//	materials.push_back(dark);
//	materials.push_back(red);
//	materials.push_back(orange);
//	materials.push_back(yellow);
//	materials.push_back(green);
//	materials.push_back(turqoise);
//	materials.push_back(blue);
//	materials.push_back(purple);
//	materials.push_back(grey);
//	materials.push_back(Metalred);
//	materials.push_back(Metalorange);
//	materials.push_back(Metalyellow);
//	materials.push_back(Metalgreen);
//	materials.push_back(Metalturqoise);
//	materials.push_back(Metalblue);
//	materials.push_back(Metalpurple);
//	materials.push_back(Metalgrey);
//	materials.push_back(Emissivered);
//	materials.push_back(Emissiveorange);
//	materials.push_back(Emissiveyellow);
//	materials.push_back(Emissivegreen);
//	materials.push_back(Emissiveturqoise);
//	materials.push_back(Emissiveblue);
//	materials.push_back(Emissivepurple);
//	materials.push_back(Dielectricwhite);
//	materials.push_back(Dielectricred);
//	materials.push_back(Dielectricorange);
//	materials.push_back(Dielectricyellow);
//	materials.push_back(Dielectricgreen);
//	materials.push_back(Dielectricturqoise);
//	materials.push_back(Dielectricblue);
//	materials.push_back(Dielectricpurple);
//#pragma endregion
//
//	/*for (int i = 0; i < 10; i++)
//	{
//		std::unique_ptr<Sphere> sphere = std::make_unique<Sphere>(Transform{ random(vec3{ -15, -2, -10 }, vec3{ 15, 7.5, 30 }) }, randomf(0.5f, 3.0f), materials[random(1, materials.size())]);
//		scene.AddObject(std::move(sphere));
//	}*/
//
//	/*std::unique_ptr<Sphere> sphere = std::make_unique<Sphere>(vec3(0, 1, -15), 1.0f, Dielectricwhite);
//	scene.AddObject(std::move(sphere));
//
//	std::unique_ptr<Triangle> triangle = std::make_unique<Triangle>(vec3(0, 2, -17), vec3(2, -1, -18), vec3(-2, -1, -18), Dielectricorange);
//	scene.AddObject(std::move(triangle));*/
//
//	std::unique_ptr<Model> model = std::make_unique<Model>(Transform{ { -2, 0, 5 }, { 5, 40, 0 }, vec3{ 4 } }, std::make_shared<Dielectric>(Color::HSVtoRGB(randomf(0, 360), randomf(0, 1), randomf(0, 1)), randomf(1.0f, 3.0f)));
//	model->Load("models/cube.obj");
//	scene.AddObject(std::move(model));
//	std::unique_ptr<Model> model1 = std::make_unique<Model>(Transform{ { 5, 0, 5 }, { 0, -10, 0 }, vec3{ 4 } }, std::make_shared<Emissive>(Color::HSVtoRGB(randomf(0, 360), randomf(0, 1), randomf(0, 1)), randomf(5.0f, 10.0f)));
//	model1->Load("models/suzanne.obj");
//	scene.AddObject(std::move(model1));
//
//	std::unique_ptr<Plane> plane = std::make_unique<Plane>(Transform{ { 0, -2, 0 }, { 0, 0, 0} }, dark);
//	scene.AddObject(std::move(plane));
//
//	Color::SetBlendMode(BlendMode::NORMAL);
//}
//
//void InitScene01(Scene& scene, Camera& camera)
//{
//	camera.SetFOV(20.0f);
//	camera.SetView({ 13, 2, 3 }, { 0, 0, 0 });
//
//	auto ground_material = std::make_shared<Lambertian>(color3_t(0.5f));
//	scene.AddObject(std::make_unique<Plane>(Transform{ vec3{ 0 } }, ground_material));
//
//	for (int a = -11; a < 11; a++) {
//		for (int b = -11; b < 11; b++) {
//			auto choose_mat = randomf();
//			vec3 center(a + 0.9 * randomf(), 0.2, b + 0.9 * randomf());
//
//			if ((center - vec3(4, 0.2, 0)).length() > 0.9) {
//				std::shared_ptr<Material> sphere_material;
//
//				if (choose_mat < 0.8) {
//					// diffuse
//					auto albedo = Color::HSVtoRGB(randomf(0, 360), 1.0f, 1.0f);
//					sphere_material = std::make_shared<Lambertian>(albedo);
//					scene.AddObject(std::make_unique<Sphere>(Transform{ center }, 0.2f, sphere_material));
//				}
//				else if (choose_mat < 0.95) {
//					// metal
//					auto albedo = Color::HSVtoRGB(randomf(0, 360), 1.0f, 1.0f);
//					auto fuzz = randomf(0.0f, 0.5f);
//					sphere_material = std::make_shared<Metal>(albedo, fuzz);
//					scene.AddObject(std::make_unique<Sphere>(Transform{ center }, 0.2f, sphere_material));
//				}
//				else {
//					// glass
//					sphere_material = std::make_shared<Dielectric>(color3_t{ 1 }, 1.5f);
//					scene.AddObject(std::make_unique<Sphere>(Transform{ center }, 0.2f, sphere_material));
//				}
//			}
//		}
//	}
//
//	auto material1 = std::make_shared<Dielectric>(color3_t{ 1 }, 1.5f);
//	scene.AddObject(std::make_unique<Sphere>(Transform{ vec3{ 0, 1, 0 } }, 1.0f, material1));
//
//	auto material2 = std::make_shared<Lambertian>(color3_t(0.4f, 0.2f, 0.1f));
//	scene.AddObject(std::make_unique<Sphere>(Transform{ vec3{ -4, 1, 0 } }, 1.0f, material2));
//
//	auto material3 = std::make_shared<Metal>(color3_t(0.7f, 0.6f, 0.5f), 0.0f);
//	scene.AddObject(std::make_unique<Sphere>(Transform{ vec3{ 4, 1, 0 } }, 1.0f, material3));
//
//	Color::SetBlendMode(BlendMode::NORMAL);
//}

void InitCornellBox(Scene& scene)
{
	std::shared_ptr<MaterialGPU> matWhiteWall = std::make_unique<MaterialGPU>();
	matWhiteWall->type = MaterialType::LAMBERTIAN;
	matWhiteWall->albedo = Color::HSVtoRGB(0.0f, 0.0f, 0.5f);
	std::shared_ptr<MaterialGPU> matRedWall = std::make_unique<MaterialGPU>();
	matRedWall->type = MaterialType::LAMBERTIAN;
	matRedWall->albedo = Color::HSVtoRGB(0.0f, 1.0f, 1.0f);
	std::shared_ptr<MaterialGPU> matGreenWall = std::make_unique<MaterialGPU>();
	matGreenWall->type = MaterialType::LAMBERTIAN;
	matGreenWall->albedo = Color::HSVtoRGB(120.0f, 1.0f, 1.0f);
	std::shared_ptr<MaterialGPU> matLight = std::make_unique<MaterialGPU>();
	matLight->type = MaterialType::EMISSIVE;
	matLight->albedo = Color::HSVtoRGB(0.0f, 0.0f, 1.0f);
	matLight->intensity = 10.0f;

#pragma region MakeRoom
	std::unique_ptr<Model> roof = std::make_unique<Model>(Transform{ vec3{ 0, 5, 5 }, vec3{ 0 }, vec3{ 20, 1, 20 } }, matWhiteWall);
	roof->Load("models/cube.obj");
	scene.AddObject(std::move(roof));
	std::unique_ptr<Model> floor = std::make_unique<Model>(Transform{ vec3{ 0, -5, 5 }, vec3{ 0 }, vec3{ 20, 1, 20 } }, matWhiteWall);
	floor->Load("models/cube.obj");
	scene.AddObject(std::move(floor));
	std::unique_ptr<Model> whiteWall = std::make_unique<Model>(Transform{ vec3{ 0, 0, 5 }, vec3{ 0 }, vec3{ 20, 20, 1 } }, matWhiteWall);
	whiteWall->Load("models/cube.obj");
	scene.AddObject(std::move(whiteWall));
	std::unique_ptr<Model> redWall = std::make_unique<Model>(Transform{ vec3{ -5, 0, 5 }, vec3{ 0 }, vec3{ 1, 20, 20 } }, matRedWall);
	redWall->Load("models/cube.obj");
	scene.AddObject(std::move(redWall));
	std::unique_ptr<Model> greenWall = std::make_unique<Model>(Transform{ vec3{ 5, 0, 5 }, vec3{ 0 }, vec3{ 1, 20, 20 } }, matGreenWall);
	greenWall->Load("models/cube.obj");
	scene.AddObject(std::move(greenWall));

	std::unique_ptr<Model> light = std::make_unique<Model>(Transform{ vec3{ 0, 5, 0 }, vec3{ 0 }, vec3{ 2 } }, matLight);
	light->Load("models/cube.obj");
	scene.AddObject(std::move(light));
#pragma endregion
	
	std::shared_ptr<MaterialGPU> matMirror = std::make_unique<MaterialGPU>();
	matMirror->type = MaterialType::METAL;
	matMirror->albedo = Color::HSVtoRGB(285, 0.85f, 0.75f);
	matMirror->fuzz = 0.8f;
	std::unique_ptr<Model> teapot = std::make_unique<Model>(Transform{ { -2.5f, -4.75f, 1 }, { 0, 20, 0 }, vec3{ 0.5f } }, matMirror);
	teapot->Load("models/teapot.obj");
	scene.AddObject(std::move(teapot));

	std::unique_ptr<Model> cube = std::make_unique<Model>(Transform{ { 3, -4, 2 }, { 0, 0, 0 }, vec3{ 3 } }, matWhiteWall);
	cube->Load("models/cube.obj");
	scene.AddObject(std::move(cube));

	std::shared_ptr<MaterialGPU> matGlass = std::make_unique<MaterialGPU>();
	matGlass->type = MaterialType::DIELECTRIC;
	matGlass->albedo = Color::HSVtoRGB(25.0f, 0.5f, 0.5f);
	matGlass->refractiveIndex = 1.5f;
	std::unique_ptr<Model> spot = std::make_unique<Model>(Transform{ { 2.75f, -1, 2 }, { 0, 45, 0 }, vec3{ 2 } }, matGlass);
	spot->Load("models/spot.obj");
	scene.AddObject(std::move(spot));

	Color::SetBlendMode(BlendMode::NORMAL);
}

//void InitFinalScene(Scene& scene)
//{
//	auto matGround = std::make_shared<MaterialGPU>();
//	matGround->albedo = Color::HSVtoRGB(290, 0.2f, 0.85f);
//	matGround->type = MaterialType::LAMBERTIAN;
//	auto ground = std::make_unique<Model>(Transform{ vec3{ 0, -3, 0}, vec3{ 0 }, vec3{ 20, 1, 20 } }, matGround);
//	ground->Load("models/cube.obj");
//	scene.AddObject(std::move(ground));
//
//	for (int x = -11; x < 11; x += 2)
//	{
//		for (int z = -3; z < 15; z += 2)
//		{
//			int objType = random(10);
//			float matType = randomf();
//			std::shared_ptr<MaterialGPU> mat;
//			if (matType <= 0.4f)
//			{
//				mat = std::make_shared<MaterialGPU>();
//				mat->albedo = Color::HSVtoRGB(randomf(360), randomf(), randomf());
//				mat->type = MaterialType::LAMBERTIAN;
//			}
//			else if (matType <= 0.7f)
//			{
//				mat = std::make_shared<MaterialGPU>();
//				mat->albedo = Color::HSVtoRGB(randomf(360), randomf(), randomf());
//				mat->type = MaterialType::METAL;
//				mat->fuzz = randomf();
//			}
//			else if (matType <= 0.9f)
//			{
//				mat = std::make_shared<MaterialGPU>();
//				mat->albedo = Color::HSVtoRGB(randomf(360), randomf(), randomf());
//				mat->type = MaterialType::DIELECTRIC;
//				mat->refractiveIndex = randomf(0.5f, 3.0f);
//			}
//			else
//			{
//				mat = std::make_shared<MaterialGPU>();
//				mat->albedo = Color::HSVtoRGB(randomf(360), randomf(), randomf());
//				mat->type = MaterialType::EMISSIVE;
//				mat->intensity = randomf(10, 20);
//			}
//
//			if (objType <= 6)
//			{
//				auto sphere = std::make_unique<Sphere>(Transform{ vec3{ x + (0.9f * randomf(-1, 1)), randomf(-2, 10), z + (0.9f * randomf(-1, 1))}}, randomf(0.5f, 1.5f), mat);
//				scene.AddObject(std::move(sphere));
//			}
//			else
//			{
//				int modelPick = random(5);
//				auto model = std::make_unique<Model>(Transform{ vec3{ x + (0.9f * randomf(-1, 1)), randomf(-2, 10), z + (0.9f * randomf(-1, 1)) }, { randomf(-180, 180), randomf(-180, 180), randomf(-180, 180) }, vec3{ randomf(0.5f, 2.0f) } }, mat);
//				switch (modelPick)
//				{
//				case 0:
//					model->Load("models/cube.obj");
//					break;
//				case 1:
//					model->Load("models/spot.obj");
//					break;
//				case 2:
//					model->Load("models/suzanne.obj");
//					break;
//				case 3:
//					model->Load("models/teapot.obj");
//					break;
//				case 4:
//					model->Load("models/torus.obj");
//					break;
//				/*case 5:
//					model->Load("models/dragon.obj");
//					break;*/
//				default:
//					model->Load("models/cube.obj");
//					break;
//				}
//				scene.AddObject(std::move(model));
//			}
//		}
//	}
//
//	auto matPedestal = std::make_shared<MaterialGPU>();
//	matPedestal->albedo = Color::HSVtoRGB(46, 0.74f, 0.83f);
//	matPedestal->type = MaterialType::METAL;
//	matPedestal->fuzz = 0.4f;
//
//	auto pedestal = std::make_unique<Model>(Transform{ { -2.175f, -1.5f, -5 }, { 0, 45, 0 }, vec3{ 1.25f } }, matPedestal);
//	pedestal->Load("models/cube.obj");
//	scene.AddObject(std::move(pedestal));
//
//	auto matSpot = std::make_shared<MaterialGPU>();
//	matSpot->albedo = Color::HSVtoRGB(25.0f, 0.5f, 0.5f);
//	matSpot->type = MaterialType::DIELECTRIC;
//	matSpot->refractiveIndex = 1.76f;
//
//	auto spot = std::make_unique<Model>(Transform{ { -2, -0.25f, -5 }, { 0, -55, 0 }, vec3{ 1 } }, matSpot);
//	spot->Load("models/spot.obj");
//	scene.AddObject(std::move(spot));
//
//	Color::SetBlendMode(BlendMode::NORMAL);
//}

//void InitECScene(Scene& scene, Camera& camera)
//{
//	camera.SetView({ -1, 2, -10 }, { 0, 0, 0 });
//
//	auto matTree = std::make_shared<MaterialGPU>();
//	matTree->type = MaterialType::EMISSIVE;
//	matTree->albedo = Color::HSVtoRGB(3.0f, 0.8f, 0.18f);
//	matTree->intensity = 2.0f;
//
//	for (float f = -1.5f; f < 5.0f; f += 0.5f)
//	{
//		auto ring = std::make_unique<Model>(Transform{ vec3{ -4.5f + randomf(-0.25f, 0.25f), f, 0.0f + randomf(-0.25f, 0.25f)}, { randomf(-10, 10), 0, randomf(-10, 10) }, vec3{ randomf(0.5f, 1.0f) } }, matTree);
//		ring->Load("models/torus.obj");
//		scene.AddObject(std::move(ring));
//	}
//
//	auto matLeaves = std::make_shared<MaterialGPU>();
//	matLeaves->type = MaterialType::DIELECTRIC;
//	matLeaves->albedo = Color::HSVtoRGB(320.3f, 1.0f, 0.859f);
//	matLeaves->refractiveIndex = 1.25f;
//	for (int i = 0; i < 200; i++)
//	{
//		auto leaf = std::make_unique<Sphere>(Transform{ vec3{ randomf(-7.0f, -1.0f), randomf(2.5f, 5.5f), randomf(-3.0f, 3.0f) } }, randomf(0.25f, 0.5f), matLeaves);
//		scene.AddObject(std::move(leaf));
//	}
//
//	auto matGate = std::make_shared<MaterialGPU>();
//	matGate->type = MaterialType::METAL;
//	matGate->albedo = Color::HSVtoRGB(1, 0.95f, 0.65f);
//	matGate->fuzz = 5.0f;
//
//	auto gate = std::make_unique<Model>(Transform{ { 3, 1.5f, 0 }, { 0, 35, 0 }, vec3{ 2 } }, matGate);
//	gate->Load("models/gate.obj");
//	scene.AddObject(std::move(gate));
//
//	auto matGround = std::make_shared<MaterialGPU>();
//	matGround->type = MaterialType::LAMBERTIAN;
//	matGround->albedo = Color::HSVtoRGB(118, 0.65f, 0.35f);
//
//	auto ground = std::make_unique<Model>(Transform{ { 0, -3, 0 }, vec3{ 0 }, { 20, 1, 20 } }, matGround);
//	ground->Load("models/cube.obj");
//	scene.AddObject(std::move(ground));
//
//	Color::SetBlendMode(BlendMode::NORMAL);
//}