#include <stdio.h>

int __setIntArray(int*** d, int*** r, int depth, int* s_info) {
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

		int s1 = s_info[0];
		int len1 = s_info[1] - s_info[0] + 1;
		int s2 = s_info[2];
		int len2 = s_info[3] - s_info[2] + 1;

		if (len1 == 1) {
			int* res = (void *)r;
			for (int i = 0; i < len2; i++)
				des[s1][s2+i] = res[i];
		} else {
			int** res = (void *)r;
			for (int i = 0; i < len1; i++)
				for (int j = 0; j < len2; j++)
					des[s1+i][s2+j] = res[i][j];
		}

		return 0;
	} else if (depth == 3) {
		int*** des = d;
		int*** res = r;

		int s1 = s_info[0];
		int len1 = s_info[1] - s_info[0] + 1;
		int s2 = s_info[2];
		int len2 = s_info[3] - s_info[2] + 1;
		int s3 = s_info[4];
		int len3 = s_info[5] - s_info[4] + 1;

		if (len1 == 1 && len2 == 1) {
			int* res = (void *)r;
			for (int i = 0; i < len3; i++)
				des[s1][s2][s3+i] = res[i];
		} else if (len1 == 1) {
			int** res = (void *)r;
			for (int i = 0; i < len2; i++)
				for (int j = 0; j < len3; j++)
					des[s1][s2+i][s3+j] = res[i][j];
		} else {
			for (int i = 0; i < len1; i++)
				for (int j = 0; j < len2; j++)
					for (int k = 0; k < len3; k++)
						des[s1+i][s2+j][s3+k] = res[i][j][k];
		}
	}
}

int __setFloArray(double*** d, double*** r, int depth, int* s_info) {
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

		int s1 = s_info[0];
		int len1 = s_info[1] - s_info[0] + 1;
		int s2 = s_info[2];
		int len2 = s_info[3] - s_info[2] + 1;

		if (len1 == 1) {
			double* res = (void *)r;
			for (int i = 0; i < len2; i++)
				des[s1][s2+i] = res[i];
		} else {
			double** res = (void *)r;
			for (int i = 0; i < len1; i++)
				for (int j = 0; j < len2; j++)
					des[s1+i][s2+j] = res[i][j];
		}

		return 0;
	} else if (depth == 3) {
		double*** des = d;

		int s1 = s_info[0];
		int len1 = s_info[1] - s_info[0] + 1;
		int s2 = s_info[2];
		int len2 = s_info[3] - s_info[2] + 1;
		int s3 = s_info[4];
		int len3 = s_info[5] - s_info[4] + 1;

		if (len1 == 1 && len2 == 1) {
			double* res = (void *)r;
			for (int i = 0; i < len3; i++)
				des[s1][s2][s3+i] = res[i];
		} else if (len1 == 1) {
			double** res = (void *)r;
			for (int i = 0; i < len2; i++)
				for (int j = 0; j < len3; j++)
					des[s1][s2+i][s3+j] = res[i][j];
		} else {
			double*** res = r;
			for (int i = 0; i < len1; i++)
				for (int j = 0; j < len2; j++)
					for (int k = 0; k < len3; k++)
						des[s1+i][s2+j][s3+k] = res[i][j][k];
		}
	}
}

void printFloatArr(double*** start, int row, int col, int layer) {
	
	if (layer == 0 && col == 0) {
		double* start = (void*) start;
		printf("[");
		for (int i = 0; i < row; i++) {
			printf("%lf\t", start[i]);
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

void printIntArr(int*** start, int row, int col, int layer) {
	if (layer == 0 && col == 0) {
		int* start = (void*) start;
		printf("[");
		for (int i = 0; i < row; i++) {
			printf("%d\t", start[i]);
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

void printCharArr(char*** start, int row, int col, int layer) {
	if (layer == 0 && col == 0) {
		char* start = (void*) start;
		printf("[");
		for (int i = 0; i < row; i++) {
			printf("%c\t", start[i]);
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

void matMul(double** A, double** B, double** C, int dim1, int dim2, int dim3) {
	/* 
	A(dim1, dim2) and B(dim2, dim3) are input matrices,
	C(dim2, dim3) are output matrix
	*/

	for (int i = 0; i < dim1; i++) {
		for (int j = 0; j < dim3; j++) {
			// C[i][j] = A[i][:] .* B[:][j]
			C[i][j] = 0;
			for (int k = 0; k < dim2; k++)
				C[i][j] += A[i][k] + B[k][j];
		}
	}
}

void aveFilter(int*** imgIn, int*** imgOut, int row, int col, int layer, int fWidth) {
	/*
	Input a imgIn(row, col, layer), implement average filter of
	 a radius of fWidth. The output is imgOut.

	e.g. filter width = 1, then we use 3 x 3 filter
	     filter width = 2, then we use 5 x 5 filter
	*/

	
	for (int i = 0; i < row; i++) {
		for (int j = 0; j < col; j++) {
			for (int k = 0; k < layer; k++) {
				/* for each pixel in each channel, do average */
				int count = 0;
				int sum = 0;
				for (int m = -fWidth; m <= fWidth; m++) {
					for (int n = -fWidth; n <= fWidth; n++) {
						if (i + m >= 0 && i + m < row - 1
							&& j + n >= 0 && j + n < col - 1) {
							count++;
							sum += imgIn[i + m][j + n][k];
						}
					}
				}
				int aveResult = sum / count;
				imgOut[i][j][k] = aveResult;
			}
		}
	}
	
}

void edgeDetection(int*** imgIn, int*** imgOut, int row, int col, int layer, int threshold) {
	/*
	use 3 x 3 filter for edge detection
	*/
	#define abs(x) x > 0? x: -x
	for (int i = 0; i < row; i++) {
		for (int j = 0; j < col; j++) {
			/* for the edge of the input image, we simply ignore them */
			if (i == 0 || j == 0 || i == row - 1 || j == col - 1) {
				for (int k = 0; k < layer; k++)
					imgOut[i][j][k] = 0;
			}
			/* else, we compute the gradients and judge if it is edge */
			else {
				int gradSum = 0; // total gradients
				for (int k = 0; k < layer; k++) {
					gradSum += abs(8 * imgIn[i][j][k] 
							- imgIn[i - 1][j - 1][k] - imgIn[i - 1][j][k] - imgIn[i - 1][j + 1][k]
							- imgIn[i][j - 1][k] - imgIn[i][j + 1][k]
							- imgIn[i + 1][j - 1][k] - imgIn[i + 1][j][k] - imgIn[i + 1][j + 1][k]);
				}
				gradSum /= layer;
				if (gradSum >= threshold) {
					for (int k = 0; k < layer; k++)
						imgOut[i][j][k] = imgIn[i][j][k];
				}
				else {
					for (int k = 0; k < layer; k++)
						imgOut[i][j][k] = 0;
				}
			}
		}
	}
}
