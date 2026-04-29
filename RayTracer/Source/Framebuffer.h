#pragma once
#include <SDL.h>
#include <vector>

using color_t = SDL_Color;

class Framebuffer
{
public:
	Framebuffer(const class Renderer& renderer, int width, int height);
	~Framebuffer();

	void Update();
	void Clear(const color_t& color);

	void DrawPoint(int x, int y, const color_t& color);
	void DrawPointClip(int x, int y, const color_t& color);

	void DrawLine(int x1, int y1, int x2, int y2, const color_t& color);
	void DrawLineSlope(int x1, int y1, int x2, int y2, const color_t& color);

	void DrawRect(int x, int y, int w, int h, const color_t& color);
	void DrawTriangle(int x1, int y1, int x2, int y2, int x3, int y3, const color_t& color);
	void DrawCircle(int xc, int yc, int r, const color_t& color);

	void DrawLinearCurve(int x1, int y1, int x2, int y2, const color_t& color);
	void DrawQuadraticCurve(int x1, int y1, int x2, int y2, int x3, int y3, int steps, const color_t& color);
	void DrawCubicCurve(int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4, int steps, const color_t& color);

	void DrawImage(int x, int y, const class Image& image);

	friend class Renderer;

private:
	void DrawOctant(int xc, int yc, int x, int y, const color_t& color);

	int ComputeRegionCode(int x, int y);
	void ClipLine(int& x1, int& y1, int& x2, int& y2);

public:
	SDL_Texture* m_texture{ nullptr };
	std::vector<color_t> m_buffer;

	int m_width{ 0 };
	int m_height{ 0 };
	int m_pitch{ 0 };

private:
	// Region Codes
	const int INSIDE = 0; // 0000
	const int LEFT = 1; // 0001
	const int RIGHT = 2; // 0010
	const int BOTTOM = 4; // 0100
	const int TOP = 8; // 1000
};