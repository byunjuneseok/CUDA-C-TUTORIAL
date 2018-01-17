#include <iostream>
#include <cuda.h>
#include <stdlib.h>
#include <ctime>

using namespace std;

//__global__ : ����̽����� ����Ǵ� �Լ� �ۼ�
__global__ void AddInts(int *a, int *b, int count) {
	int id = blockIdx.x * blockDim.x + threadIdx.x;
	if (id < count) {
		a[id] += b[id];
	}
}


main() {
	srand(time(NULL));

	//count ��Ʈ�� ����.
	int count = 10000; 
	
	//host pointer. int �迭 ����.
	int *h_a = new int[count];
	int *h_b = new int[count];

	for (int i = 0; i < count; i++) {
		h_a[i] = rand() % 1000;
		h_b[i] = rand() % 1000;
	}

	//AddInts ���� �� ������
	cout << "Prior to addition : " << endl;
	for (int i = 0; i < 5; i++) {
		cout << h_a[i] << " " << h_b[i] << endl;
	}


	//device pointer.
	int *d_a, *d_b;

	//Malloc �Ҵ� @ device pointer
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

	//AddInts ����
	AddInts <<<count / 256 + 1, 256>>> (d_a, d_b, count);


	//���н� �޸� ��ȯ �� ����
	if (cudaMemcpy(h_a, d_a, sizeof(int) * count, cudaMemcpyDeviceToHost) != cudaSuccess) {
		delete[] h_a;
		delete[] h_b;
		cudaFree(d_a);
		cudaFree(d_b);
		cout << "Nope!" << endl;
		return 0;
	}

	//������ ��� ���
	for (int i = 0; i < 5; i++) {
		cout << "It's" << h_a[i] << endl;
	}


	//����̽��� �޸� ��ȯ
	cudaFree(d_a);
	cudaFree(d_b);

	delete[] h_a;
	delete[] h_b;

	system("pause");

	return 0; 
}
