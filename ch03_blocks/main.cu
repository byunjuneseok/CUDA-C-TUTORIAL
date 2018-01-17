#include <iostream>
#include <cuda.h>
#include <stdlib.h>
#include <ctime>

using namespace std;

//__global__ : 디바이스에서 실행되는 함수 작성
__global__ void AddInts(int *a, int *b, int count) {
	int id = blockIdx.x * blockDim.x + threadIdx.x;
	if (id < count) {
		a[id] += b[id];
	}
}


main() {
	srand(time(NULL));

	//count 컨트롤 가능.
	int count = 10000; 
	
	//host pointer. int 배열 생성.
	int *h_a = new int[count];
	int *h_b = new int[count];

	for (int i = 0; i < count; i++) {
		h_a[i] = rand() % 1000;
		h_b[i] = rand() % 1000;
	}

	//AddInts 실행 전 데이터
	cout << "Prior to addition : " << endl;
	for (int i = 0; i < 5; i++) {
		cout << h_a[i] << " " << h_b[i] << endl;
	}


	//device pointer.
	int *d_a, *d_b;

	//Malloc 할당 @ device pointer
	if (cudaMalloc(&d_a, sizeof(int) * count) != cudaSuccess) {
		cout << "Nope!";
		return 0;
	}

	if (cudaMalloc(&d_b, sizeof(int) * count) != cudaSuccess) {
		cout << "Nope!";
		cudaFree(d_a);
		return 0;
	}

	//data copy : host to device
	if (cudaMemcpy(d_a, h_a, sizeof(int) * count, cudaMemcpyHostToDevice) != cudaSuccess) {
		cout << "cout not copy!" << endl;
		cudaFree(d_a);
		cudaFree(d_b);
		return 0;
	}

	if (cudaMemcpy(d_b, h_b, sizeof(int) * count, cudaMemcpyHostToDevice) != cudaSuccess) {
		cout << "cout not copy!" << endl;
		cudaFree(d_a);
		cudaFree(d_b);
		return 0;
	}

	//AddInts 실행
	AddInts <<<count / 256 + 1, 256>>> (d_a, d_b, count);


	//실패시 메모리 반환 및 종료
	if (cudaMemcpy(h_a, d_a, sizeof(int) * count, cudaMemcpyDeviceToHost) != cudaSuccess) {
		delete[] h_a;
		delete[] h_b;
		cudaFree(d_a);
		cudaFree(d_b);
		cout << "Nope!" << endl;
		return 0;
	}

	//성공시 결과 출력
	for (int i = 0; i < 5; i++) {
		cout << "It's" << h_a[i] << endl;
	}


	//디바이스의 메모리 반환
	cudaFree(d_a);
	cudaFree(d_b);

	delete[] h_a;
	delete[] h_b;

	system("pause");

	return 0; 
}
