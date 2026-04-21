#pragma once
#include <cuda.h>
#include <cuda_runtime.h>
#include <iostream>

#define checkCudaErrors(val) checkCuda((val), #val, __FILE__, __LINE__)
void checkCuda(cudaError_t result, char const* const func, const char* const file, int const line)
{
	if (result)
	{
		std::cerr << "CUDA error = " << static_cast<unsigned int>(result) << " at " <<
			file << ":" << line << " '" << func << "' \n";

		cudaDeviceReset();
		exit(99);
	}
}