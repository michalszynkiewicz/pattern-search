#ifndef MS_CUDA_UTILS

#define MS_CUDA_UTILS

#define cudaCall(ans) { gpuAssert((ans), __FILE__, __LINE__); }
// after: http://stackoverflow.com/questions/14038589/what-is-the-canonical-way-to-check-for-errors-using-the-cuda-runtime-api
inline void gpuAssert(cudaError_t code, const char *file, int line)
{
        if (code != cudaSuccess)
        {
                fprintf(stderr,"Cuda call failed: %s:%d [%d] %s\n", file, line, code, cudaGetErrorString(code));
                exit(code);
        }
}

#endif
