#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <math.h>
#include <string.h>
#include "builtin.h"

#define accImg(img,i,j,k) ((img)->data[3 * ((i) * (img)->col + (j)) + (k)])
#define accMat(mat,i,j) ((mat)->data[((i) * (mat)->col) + (j)])

double int2float(int x) {
	double result = (double) x;
	return result;
}

double char2float(char x) {
	double result = (double) x;
	return result;
}

int float2int(double x) {
	int result = (int) x;
	return result;
}

int char2int(char x) {
	int result = (int) x;
	return result;
}

char float2char(double x) {
	char result;
	if (x <= 0)
		result = (char) 0;
	else if (x >= 255)
		result = (char) 255;
	else
		result = (char) x;
	return result;
}

char int2char(int x) {
	char result;
	if (x <= 0)
		result = (char) 0;
	else if (x >= 255)
		result = (char) 255;
	else
		result = (char) x;
	return result;
}

int __intPower(int a, int b) {
	return (int)pow((double)a, (double)b);
}

double __floatPower(double a, double b) {
	return pow(a,b);
}



void __printMat(const struct mat* a) {
	assert(a != NULL && "try to print empty matrix");
	assert(a->row > 0 && a->col > 0);
	printf("\nrow: %d col: %d \n", a->row, a->col);
	int c = a->col;
	for (int i = 0; i < a->row; i++) {
		for (int j = 0; j < a->col; j++)
			printf("%lf ", a->data[c * i + j]);
		printf("\n");
	}
}

void __printImg(const struct img* a) {
	assert(a != NULL);
	int row = a->row;
	int col = a->col;
	printf("\nrow: %d col: %d \n", a->row, a->col);
	for (int i = 0; i < row; i++) {
		for (int j = 0; j < col; j++) {
			for (int k = 0; k < 3; k++) 
				printf("%d ", a->data[i * col * 3 + j * 3 + k]);
			printf("\n");
		}
		printf("\n");
	}
}

int __matRow(const struct mat* a) { assert(a != NULL); return a->row; }
int __matCol(const struct mat* a) { assert(a != NULL); return a->col; }
int __imgRow(const struct img* a) { assert(a != NULL); return a->row; }
int __imgCol(const struct img* a) { assert(a != NULL); return a->col; }

float __returnMatVal(const struct mat* a, int r, int c) {
	assert(a != NULL);
	assert(r >= 0 && c >= 0);
	assert(r < a->row && c < a->col);
	return a->data[a->col * r + c];
}

int __returnImgVal(const struct img* a, int r, int c, int ch) {
	assert(a != NULL);
	assert(r >= 0 && c >= 0 && ch >= 0);
	assert(r < a->row && c < a->col && ch < 3);
	return (int)a->data[3 * (r * a->col + c) + ch];
}

void __setMatVal(double val, struct mat* a, int r, int c) {
	assert(a != NULL);
	assert(r >= 0 && c >= 0);
	assert(r < a->row && c < a->col);
	a->data[a->col * r + c] = val;
}

void __setImgVal(int val, struct img* a, int r, int c, int ch) {
	assert(a != NULL);
	assert(r >= 0 && c >= 0 && ch >= 0);
	assert(r < a->row && c < a->col && ch < 3);
	a->data[3 * (r * a->col + c) + ch] = (unsigned char)val;
}

void __setMat(struct mat* a, double** arr, int row, int col) {
	assert(a != NULL);
	assert(a->row == row && a->col == col);
	for (int r = 0; r < row; r++)
		for (int c = 0; c < col; c++)
			a->data[a->col * r + c] = arr[r][c];
}

struct img* malloc_img(int row, int col) {
	assert(row > 0 && col > 0);
	struct img* i = (struct img*) malloc(sizeof(struct img));
	const int chn = 3;
	i -> row = row;
	i -> col = col;
	i -> data = (unsigned char*)malloc(row * col * 3);

	return i;
}


struct mat* malloc_mat(int row, int col) {
	assert(row > 0 && col > 0);
	struct mat* m = (struct mat*) malloc(sizeof(struct mat));
	m -> row = row;
	m -> col = col;
	m -> data = (double*) malloc(sizeof(double) * row * col);

	return m;
}

void free_img(struct img* i) {
	assert(i != NULL && "image has been freed");
	free(i -> data);
	free(i);
}

void free_mat(struct mat* m) {
	assert(m != NULL && "matrix has been freed");
	free(m -> data);
	free(m);
}

// void free_mat_int(struct mat_int* m) {
// 	const int row = m -> row;
// 	const int col = m -> col;

// 	for (int r = 0; r < row; r++) {
// 		free(m -> mat[r]);
// 	}
// 	free(m -> mat);
// 	free(m);
// }

int __setIntArray(int diff, int*** d, int*** r, int depth, int* s_info) {
	if (depth == 1) {
		int* des = (void *)d;
		int* res = (void *)r;

		int s = s_info[0];
		int len = s_info[1] - s_info[0] + 1;
		for (int i = 0; i < len; i++) {
			des[s+i] = res[i];
		}
		return 0;
	} else if (depth == 2) {
		int** des = (void *)d;
		int** res;

		int s1 = s_info[0];
		int len1 = s_info[1] - s_info[0] + 1;
		int s2 = s_info[2];
		int len2 = s_info[3] - s_info[2] + 1;

		if (diff == 1)
			res = (void *)&r;
		else
			res = (void *)r;

		for (int i = 0; i < len1; i++)
			for (int j = 0; j < len2; j++)
				des[s1+i][s2+j] = res[i][j];

		return 0;
	} else if (depth == 3) {
		int*** des = d;
		int*** res;
		void* tmp;

		int s1 = s_info[0];
		int len1 = s_info[1] - s_info[0] + 1;
		int s2 = s_info[2];
		int len2 = s_info[3] - s_info[2] + 1;
		int s3 = s_info[4];
		int len3 = s_info[5] - s_info[4] + 1;

		if (diff == 2) {
			tmp = (void *)&r;
			res = (void *)&tmp;
		} else if (diff == 1)
			res = (void *)&r;
		else
			res = r;
		for (int i = 0; i < len1; i++)
			for (int j = 0; j < len2; j++)
				for (int k = 0; k < len3; k++)
					des[s1+i][s2+j][s3+k] = res[i][j][k];
	}
}

int __setFloArray(int diff, double*** d, double*** r, int depth, int* s_info) {
	if (depth == 1) {
		double* des = (void *)d;
		double* res = (void *)r;

		int s = s_info[0];
		int len = s_info[1] - s_info[0] + 1;
		for (int i = 0; i < len; i++) {
			des[s+i] = res[i];
		}
		return 0;
	} else if (depth == 2) {
		double** des = (void *)d;
		double** res;

		int s1 = s_info[0];
		int len1 = s_info[1] - s_info[0] + 1;
		int s2 = s_info[2];
		int len2 = s_info[3] - s_info[2] + 1;

		if (diff == 1)
			res = (void *)&r;
		else
			res = (void *)r;
		for (int i = 0; i < len1; i++)
			for (int j = 0; j < len2; j++)
				des[s1+i][s2+j] = res[i][j];

		return 0;
	} else if (depth == 3) {
		double*** des = d;
		double*** res;
		void* tmp;

		int s1 = s_info[0];
		int len1 = s_info[1] - s_info[0] + 1;
		int s2 = s_info[2];
		int len2 = s_info[3] - s_info[2] + 1;
		int s3 = s_info[4];
		int len3 = s_info[5] - s_info[4] + 1;

		if (diff == 2) {
			tmp = (void *)&r;
			res = (void *)&tmp;
		} else if (diff == 1) {
			res = (void *)&r;
		} else {
			res = r;
		}

		for (int i = 0; i < len1; i++)
			for (int j = 0; j < len2; j++)
				for (int k = 0; k < len3; k++)
					des[s1+i][s2+j][s3+k] = res[i][j][k];
	}
}

void __printFloatArr(double*** start, int row, int col, int layer) {

	if (layer == 0 && col == 0) {
		double* ptr = (void*) start;
		printf("[");
		for (int i = 0; i < row; i++) {
			printf("%lf\t", ptr[i]);
		}
		printf("]\n");
	}

	else if (layer == 0) {
		printf("[");
		double** ptr = (void*) start;
		for (int i = 0; i < row; i++) {
			printf("[");
			for (int j = 0; j < col; j++) {
				printf("%lf\t", ptr[i][j]);
			}
			if (i != row - 1)
				printf("]\n");
			else
				printf("]");
		}
		printf("]");
	}
	else {
		printf("[");
		for (int i = 0; i < row; i++) {
			printf("[");
			for (int j = 0; j < col; j++) {
				printf("[");
				for (int k = 0; k < layer; k++) {
					printf("%lf\t", start[i][j][k]);
				}
				if (j != col - 1)
					printf("]\n");
				else
					printf("]");
			}
			if (i != row - 1)
				printf("]\n");
			else
				printf("]");
		}
		printf("]");
	}
	printf("\n");
}

void __printIntArr(int*** start, int row, int col, int layer) {
	if (layer == 0 && col == 0) {
		int* ptr = (void*) start;
		printf("[");
		for (int i = 0; i < row; i++) {
			printf("%d\t", ptr[i]);
		}
		printf("]\n");
	}

	else if (layer == 0) {
		printf("[");
		int** ptr = (void*) start;
		for (int i = 0; i < row; i++) {
			printf("[");
			for (int j = 0; j < col; j++) {
				printf("%d\t", ptr[i][j]);
			}
			if (i != row - 1)
				printf("]\n");
			else
				printf("]");
		}
		printf("]");
	}
	else {
		printf("[");
		for (int i = 0; i < row; i++) {
			printf("[");
			for (int j = 0; j < col; j++) {
				printf("[");
				for (int k = 0; k < layer; k++) {
					printf("%d\t", start[i][j][k]);
				}
				if (j != col - 1)
					printf("]\n");
				else
					printf("]");
			}
			if (i != row - 1)
				printf("]\n");
			else
				printf("]");
		}
		printf("]");
	}
	printf("\n");
}

void __printCharArr(char*** start, int row, int col, int layer) {
	if (layer == 0 && col == 0) {
		char* ptr = (void*) start;
		printf("[");
		for (int i = 0; i < row; i++) {
			printf("%c\t", ptr[i]);
		}
		printf("]\n");
	}

	else if (layer == 0) {
		printf("[");
		char** ptr = (void*) start;
		for (int i = 0; i < row; i++) {
			printf("[");
			for (int j = 0; j < col; j++) {
				printf("%c\t", ptr[i][j]);
			}
			if (i != row - 1)
				printf("]\n");
			else
				printf("]");
		}
		printf("]");
	}
	else {
		printf("[");
		for (int i = 0; i < row; i++) {
			printf("[");
			for (int j = 0; j < col; j++) {
				printf("[");
				for (int k = 0; k < layer; k++) {
					printf("%c\t", start[i][j][k]);
				}
				if (j != col - 1)
					printf("]\n");
				else
					printf("]");
			}
			if (i != row - 1)
				printf("]\n");
			else
				printf("]");
		}
		printf("]");
	}
	printf("\n");
}


struct mat* __matMul(const struct mat* m1, const struct mat* m2) {
	/*
	please make sure the dimension is correct before input parameters
	A(dim1, dim2) and B(dim2, dim3) are input matrices,
	C(dim2, dim3) are output matrix
	*/
	assert(m1 != NULL && m2 != NULL);
	assert(m1->col == m2->row);
	const int dim1 = m1 -> row;
	const int dim2 = m1 -> col;
	const int dim3 = m2 -> col;

	struct mat* m3 = malloc_mat(dim1, dim3);

	for (int i = 0; i < dim1; i++) {
		for (int j = 0; j < dim3; j++) {
			/* C[i][j] = A[i][:] .* B[:][j] */
			m3 -> data[m3->col * i + j] = 0;
			for (int k = 0; k < dim2; k++)
				m3 -> data[m3->col * i + j] += m1 -> data[m1->col * i + k] * m2 -> data[m2->col * k + j];
		}
	}
	return m3;
}

struct mat* repMat(double val, int row, int col) {
	assert(row > 0 && col > 0);
	struct mat* m = malloc_mat(row, col);
	for (int i = 0; i < row * col; i++)
		m->data[i] = val;
	return m;
}

struct mat* matAssign(struct mat* m, double val) {
	for (int i = 0; i < m->row; ++i)
		for (int j = 0; j < m->col; ++j)
			m->data[m->col * i + j] = val;
	return m;
}

struct mat* __matOperator(const struct mat* m1, const struct mat* m2, char op) {
	assert(m1 != NULL && m2 != NULL);
	assert(m1->row==m2->row);
	assert(m1->col==m2->col);
	if (op == 'm') {
		return __matMul(m1, m2);
	}
	int r = m1->row, c = m1->col;
	struct mat* m3 = malloc_mat(r, c);
	for (int i = 0; i < r; ++i)
		for (int j = 0; j < c; ++j)
			switch (op)
			{
				case '+': m3->data[m3->col * i + j] = m1->data[m1->col * i + j] + m2->data[m2->col * i + j]; break;
				case '-': m3->data[m3->col * i + j] = m1->data[m1->col * i + j] - m2->data[m2->col * i + j]; break;
				case '*': m3->data[m3->col * i + j] = m1->data[m1->col * i + j] * m2->data[m2->col * i + j]; break;
				case '/': m3->data[m3->col * i + j] = m1->data[m1->col * i + j] / m2->data[m2->col * i + j]; break;
				default: break;
			}
	return m3;
}

struct img* imgAssign(struct img* m, int val) {
	val = (0<=val)?val:0;
	val = (val<=255)?val:255;
	for (int i = 0; i < m->row; ++i)
		for (int j = 0; j < m->col; ++j)
			for (int k = 0; k < 3; ++k)
				m->data[3 * (i * m->col + j) + k] = val;
	return m;
}

struct img* __imgOperator(const struct img* m1, const struct img* m2, char op) {
	assert(m1->row==m2->row);
	assert(m1->col==m2->col);
	int r = m1->row, c = m1->col;
	struct img* m3 = malloc_img(r, c);
	for (int i = 0; i < r; ++i)
		for (int j = 0; j < c; ++j)
			for (int k = 0; k < 3; ++k)
				switch (op)
				{
					case '+': m3->data[3 * (r * m3->col + c) + k] =
					m1->data[3 * (r * m1->col + c) + k] + m2->data[3 * (r * m2->col + c) + k]; break;
					case '-': m3->data[3 * (r * m3->col + c) + k] =
					m1->data[3 * (r * m1->col + c) + k] - m2->data[3 * (r * m2->col + c) + k]; break;
					case '*': m3->data[3 * (r * m3->col + c) + k] =
					m1->data[3 * (r * m1->col + c) + k] * m2->data[3 * (r * m2->col + c) + k]; break;
					case '/': m3->data[3 * (r * m3->col + c) + k] =
					m1->data[3 * (r * m1->col + c) + k] / m2->data[3 * (r * m2->col + c) + k]; break;
					default: break;
				}
	return m3;
}

struct mat* __matTranspose(const struct mat* m) {
	assert(m != NULL);

	int r = m->col, c = m->row;
	struct mat* res = malloc_mat(r, c);
	for (int i = 0; i < c; i++)
		for (int j = 0; j < r; j++)
			res->data[j * r + i] = accMat(m, i, j);
	return res;
}

static void __copyMat(const struct mat* src, struct mat* des) {
	memcpy(des->data, src->data, src->row * src->col * sizeof(double));
}
struct mat* __matPower(const struct mat* m, int p) {
	assert(m != NULL && m->row == m->col);
	assert(p > 0);

	int r = m->row, c = m->col;
	struct mat* unit = malloc_mat(r, c);
	for (int i = 0; i < r; i++)
		accMat(unit, i, i) = 1;
	struct mat* tmp;
	for (int i = 0; i < p; i++) {
		if (i > 0) free_mat(tmp);
		tmp = __matMul(m, unit);
		__copyMat(tmp, unit);
	}

	return tmp;
}

// struct img* aveFilter(struct img* imgIn, int fWidth) {
// 	/*
// 	Input a imgIn(row, col, layer), implement average filter of
// 	 a radius of fWidth. The output is imgOut.

// 	e.g. filter width = 1, then we use 3 x 3 filter
// 	     filter width = 2, then we use 5 x 5 filter
// 	*/

// 	const int row = imgIn -> row;
// 	const int col = imgIn -> col;
// 	const int layer = 3;

// 	struct img* imgOut = malloc_img(row, col);

// 	for (int i = 0; i < row; i++) {
// 		for (int j = 0; j < col; j++) {
// 			for (int k = 0; k < layer; k++) {
// 				/* for each pixel in each channel, do average */
// 				int count = 0;
// 				int sum = 0;
// 				for (int m = -fWidth; m <= fWidth; m++) {
// 					for (int n = -fWidth; n <= fWidth; n++) {
// 						if (i + m >= 0 && i + m < row - 1
// 							&& j + n >= 0 && j + n < col - 1) {
// 							count++;
// 							sum += accImg(imgIn, (i+m), (j+n), k);
// 						}
// 					}
// 				}
// 				int aveResult = sum / count;
// 				accImg(imgOut, i, j, k) = aveResult;
// 			}
// 		}
// 	}
// 	return imgOut;
// }

// struct img* edgeDetection(struct img* imgIn, int threshold) {
// 	//use 3 x 3 filter for edge detection
// 	const int row = imgIn -> row;
// 	const int col = imgIn -> col;
// 	const int layer = 3;

// 	struct img* imgOut = malloc_img(row, col);
// 	for (int i = 0; i < row; i++) {
// 		for (int j = 0; j < col; j++) {
// 			// for the edge of the input image, we simply ignore them
// 			if (i == 0 || j == 0 || i == row - 1 || j == col - 1) {
// 				for (int k = 0; k < layer; k++)
// 					accImg(imgOut, i, j, k) = 0;
// 			}
// 			// else, we compute the gradients and judge if it is edge
// 			else {
// 				float gradSum = 0; // total gradients
// 				for (int k = 0; k < layer; k++) {
// 					gradSum += abs(8 * accImg(imgIn,i,j,k)
// 							- accImg(imgIn, i-1,j-1,k) - accImg(imgIn, i-1,j,k)  - accImg(imgIn, i-1,j+1,k)
// 							- accImg(imgIn, i,j-1,k) - accImg(imgIn, i,j+1,k)
// 							- accImg(imgIn, i+1,j-1,k) - accImg(imgIn, i+1,j,k) - accImg(imgIn, i+1,j+1,k));
// 				}
// 				//printf("%f\n",gradSum);
// 				gradSum /= layer;
// 				if (gradSum >= threshold) {
// 					for (int k = 0; k < layer; k++)
// 						accImg(imgOut, i,j,k) = accImg(imgIn,i,j,k);
// 						// imgOut -> data[i][j][k] = imgIn -> data[i][j][k];
// 				}
// 				else {
// 					for (int k = 0; k < layer; k++)
// 						accImg(imgOut,i,j,k) = 0;
// 						// imgOut -> data[i][j][k] = 0;
// 				}
// 			}
// 		}
// 	}
// 	return imgOut;
// }

