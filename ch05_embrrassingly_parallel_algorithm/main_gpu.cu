#include <iostream>
#include <cuda.h>
#include <cuda_runtime.h>
#include <stdlib.h>
#include <ctime>
#include <device_launch_parameters.h>

#include "FindClosestGPU.h"

using namespace std;

int main(){
    
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////

	cout << "MAKING RANDOM POINT ARRAY.." << endl;
	const int count = 10000;

	int *indexOfClosest = new int[count];
    float3 *points = new float3[count];
    
    int *d_indexOfClosest;
    float3 *d_points;


	for (int i = 0; i < count; i++) {
		points[i].x = (float)((rand() % 10000) - 5000);
		points[i].y = (float)((rand() % 10000) - 5000);
		points[i].z = (float)((rand() % 10000) - 5000);
    }
    
    cudaMalloc(&d_points, sizeof(float3)*count);
    cudaMemcpy(d_points, points, sizeof(float3)*count, cudaMemcpyHostToDevice);
    cudaMalloc(&d_indexOfClosest, sizeof(int)*count);
    
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////

	cout << endl << "GPU PROCESSING.." << endl;

    long fastest = 1000000;
    
    for(int q = 0; q < 20; q++){
        long startTime = clock();

        FindClosestGPU<<<(count/32)+1, 32>>>(d_points, d_indexOfClosest, count);
        cudaMemcpy(indexOfClosest, d_indexOfClosest, sizeof(int)*count, cudaMemcpyDeviceToHost);

        long finishTime = clock();
        

        cout << "Run : " << q << " took " << (finishTime - startTime) << " millis" << endl;
        if((finishTime - startTime) < fastest) fastest = (finishTime - startTime);
    }
    for (int i = 0; i < 10; i++) cout << i << "." << indexOfClosest[i] << endl;

    delete[] indexOfClosest;
    delete[] points;
    cudaFree(d_points);
    cudaFree(d_indexOfClosest);
    cudaDeviceReset();

    return 0;
}