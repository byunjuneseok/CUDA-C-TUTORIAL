#include <iostream>
#include <cuda.h>
#include <cuda_runtime.h>
#include <stdlib.h>
#include <ctime>
#include <device_launch_parameters.h>

#include "FindClosestCPU.h"

using namespace std;

int main() {

	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////

	cout << "MAKING RANDOM POINT ARRAY.." << endl;
	const int count = 10000;

	int *indexOfClosest = new int[count];
	float3 *points = new float3[count];
	
	for (int i = 0; i < count; i++) {
		points[i].x = (float)((rand() % 10000) - 5000);
		points[i].y = (float)((rand() % 10000) - 5000);
		points[i].z = (float)((rand() % 10000) - 5000);
	}

	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////

	cout << endl << "CPU PROCESSING.." << endl;

	long fastest = 1000000;

	for (int q = 0; q < 20; q++) {
		long startTime = clock();

		FindClosestCPU(points, indexOfClosest, count);

		long finishTime = clock();

		cout << "Run : " << q << " took " << (finishTime - startTime) << " millis" << endl;
		if ((finishTime - startTime) < fastest) fastest = (finishTime - startTime);
	}

	cout << "Fastest time : " << fastest << endl;

	cout << "Final result : " << endl;
	for (int i = 0; i < 10; i++) cout << i << "." << indexOfClosest[i] << endl;


	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////


	delete[] indexOfClosest;
	delete[] points;

	_getch();

	return 0;

}