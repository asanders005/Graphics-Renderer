# C++ Graphics Renderer

A high-performance **Graphics Renderer** built from scratch to support real-time rendering with customizable **vertex** and **fragment shaders**. This renderer is designed to demonstrate the core principles of rendering, lighting, and post-processing without relying on external hardware acceleration. Additionally, it features an integrated **ray-tracing renderer** for realistic image synthesis.

## Features

### 1. **Real-Time Rendering**
- **Vertex and Fragment Shaders**: Fully programmable pipeline with support for custom shading logic.
- **Lighting Models**:
  - **Gouraud Shading**: Smooth shading based on vertex normals.
  - **Phong Shading**: Accurate per-pixel lighting for enhanced realism.
- **Post-Processing Effects**: Apply screen-space effects like blur, grayscale, or bloom to enhance visual output.

<img width="600" alt="Phong Lighting" src="https://github.com/user-attachments/assets/69292c26-160f-4e26-b922-3bc1e151a227">

### 2. **Ray-Tracing Renderer**
- Implements a **path-tracing algorithm** for highly realistic lighting and shadows.
- Supports:
  - Reflection and refraction.
  - Global illumination.
  - Soft shadows and anti-aliasing.

<img width="600" alt="CornellBox" src="https://github.com/user-attachments/assets/8b004bb6-79e9-482d-a9f2-0c48097b4aa0">
  
### 3. **Flexible Rendering Pipeline**
- Configurable pipeline stages for detailed customization.
- Debugging tools to inspect vertex transformation and fragment generation.

### Prerequisites
- A C++11 (or higher) compiler.
- Supported platforms: Windows.
- Libraries: 
  - **SDL2** (for windowing and input handling).
