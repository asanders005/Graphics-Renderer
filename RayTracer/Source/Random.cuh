#pragma once
#include "CudaCompat.h"
#include <glm/glm.hpp>
#define GLM_ENABLE_EXPERIMENTAL
#include <glm/gtx/norm.hpp>

#ifdef __CUDA_ARCH__
#include <curand_kernel.h>
#endif

// Host/device random integer in [min, max)
HOSTDEVICE inline int random(int min, int max
#ifdef __CUDA_ARCH__
    , curandState* state
#endif
) {
#ifdef __CUDA_ARCH__
    // curand_uniform returns [0,1), scale to [min, max)
    return min + int(curand_uniform(state) * (max - min));
#else
    return min + rand() % (max - min);
#endif
}

// Host/device random float in [min, max)
HOSTDEVICE inline float randomf(float min, float max
#ifdef __CUDA_ARCH__
    , curandState* state
#endif
) {
#ifdef __CUDA_ARCH__
    return min + curand_uniform(state) * (max - min);
#else
    return min + (rand() / (float)RAND_MAX) * (max - min);
#endif
}

// Host/device random float in [0, 1)
HOSTDEVICE inline float randomf(
#ifdef __CUDA_ARCH__
    curandState* state
#endif
) {
#ifdef __CUDA_ARCH__
    return curand_uniform(state);
#else
    return rand() / (float)RAND_MAX;
#endif
}

// Host/device random glm::vec3 in [minVec, maxVec)
HOSTDEVICE inline glm::vec3 random(const glm::vec3& minVec, const glm::vec3& maxVec
#ifdef __CUDA_ARCH__
    , curandState* state
#endif
) {
    return glm::vec3{
        randomf(minVec.x, maxVec.x
#ifdef __CUDA_ARCH__
            , state
#endif
        ),
        randomf(minVec.y, maxVec.y
#ifdef __CUDA_ARCH__
            , state
#endif
        ),
        randomf(minVec.z, maxVec.z
#ifdef __CUDA_ARCH__
            , state
#endif
        )
    };
}

// Host/device random glm::vec3 in [0, maxVec)
HOSTDEVICE inline glm::vec3 random(const glm::vec3& maxVec
#ifdef __CUDA_ARCH__
    , curandState* state
#endif
) {
    return random(glm::vec3(0.0f), maxVec
#ifdef __CUDA_ARCH__
        , state
#endif
    );
}

// Host/device random point on unit circle
HOSTDEVICE inline glm::vec2 randomOnUnitCircle(
#ifdef __CUDA_ARCH__
    curandState* state
#endif
) {
    float angle = randomf(0.0f, 360.0f
#ifdef __CUDA_ARCH__
        , state
#endif
    );
    return { glm::cos(glm::radians(angle)), glm::sin(glm::radians(angle)) };
}

// Host/device random point in unit sphere
HOSTDEVICE inline glm::vec3 randomInUnitSphere(
#ifdef __CUDA_ARCH__
    curandState* state
#endif
) {
    glm::vec3 v;
    do {
        v = random(glm::vec3(-1.0f), glm::vec3(1.0f)
#ifdef __CUDA_ARCH__
            , state
#endif
        );
    } while (glm::length2(v) > 1.0f);
    return v;
}

// Host/device random point on unit sphere
HOSTDEVICE inline glm::vec3 randomOnUnitSphere(
#ifdef __CUDA_ARCH__
    curandState* state
#endif
) {
    return glm::normalize(randomInUnitSphere(
#ifdef __CUDA_ARCH__
        state
#endif
    ));
}