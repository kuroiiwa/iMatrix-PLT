#include <stdio.h>
#include <stdlib.h>

struct image {
	int row;
	int col;
	/* channel num is 3 by default */
	int*** img;
};

struct mat_double {
	int row;
	int col;
	
	double** mat;
};

struct mat_int {
	int row;
	int col;
	
	int** mat;
};

struct image* malloc_img(int row, int col) {
	struct image* i = (struct image*) malloc(sizeof(struct image));
	const int chn = 3;
	i -> row = row;
	i -> col = col;
	i -> img = (int***) malloc(sizeof(int**) * row);
	for (int r = 0; r < row; r++) {
		i -> img[r] = (int**) malloc(sizeof(int*) * col);
		for (int c = 0; c < col; c++) {
			i -> img[r][c] = (int*) malloc(sizeof(int) * chn);
		}
	}

	return i;
}

struct mat_double* malloc_mat_double(int row, int col) {
	struct mat_double* m = (struct mat_double*) malloc(sizeof(struct mat_double));
	m -> row = row;
	m -> col = col;
	m -> mat = (double**) malloc(sizeof(double*) * row);
	for (int r = 0; r < row; r++) {
		m -> mat[r] = (double*) malloc(sizeof(double) * col);
	}

	return m;
}


struct mat_int* malloc_mat_int(int row, int col) {
	struct mat_int* m = (struct mat_int*) malloc(sizeof(struct mat_int));
	m -> row = row;
	m -> col = col;
	m -> mat = (int**) malloc(sizeof(int*) * row);
	for (int r = 0; r < row; r++) {
		m -> mat[r] = (int*) malloc(sizeof(int) * col);
	}

	return m;
}

void free_img(struct image* i) {
	const int row = i -> row;
	const int col = i -> col;
	const int ch = 3;

	for (int r = row - 1; r >= 0; r--) {
		for (int c = col - 1; c >= 0; c--) {
			free(i -> img[r][c]);
		}
		free(i -> img[r]);
	}
	free(i -> img);
	free(i);
}

void free_mat_double(struct mat_double* m) {
	const int row = m -> row;
	const int col = m -> col;

	for (int r = 0; r < row; r++) {
		free(m -> mat[r]);
	}
	free(m -> mat);
	free(m);	
}

void free_mat_int(struct mat_int* m) {
	const int row = m -> row;
	const int col = m -> col;

	for (int r = 0; r < row; r++) {
		free(m -> mat[r]);
	}
	free(m -> mat);
	free(m);	
}

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

void printFloatArr(double*** start, int row, int col, int layer) {
	
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

void printIntArr(int*** start, int row, int col, int layer) {
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

void printCharArr(char*** start, int row, int col, int layer) {
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

struct mat_double* matMul_double(struct mat_double* m1, struct mat_double* m2) {
	/* 
	please make sure the dimension is correct before input parameters
	A(dim1, dim2) and B(dim2, dim3) are input matrices,
	C(dim2, dim3) are output matrix
	*/
	const int dim1 = m1 -> row;
	const int dim2 = m1 -> col;
	const int dim3 = m2 -> col;
	
	struct mat_double* m3 = malloc_mat_double(dim1, dim3);
	
	for (int i = 0; i < dim1; i++) {
		for (int j = 0; j < dim3; j++) {
			/* C[i][j] = A[i][:] .* B[:][j] */
			for (int k = 0; k < dim2; k++)
				m3 -> mat[i][j] += m1 -> mat[i][k] * m2 -> mat[k][j];
		}
	}
	return m3;
}

struct image* aveFilter(struct image* imgIn, int fWidth) {
	/*
	Input a imgIn(row, col, layer), implement average filter of
	 a radius of fWidth. The output is imgOut.

	e.g. filter width = 1, then we use 3 x 3 filter
	     filter width = 2, then we use 5 x 5 filter
	*/

	const int row = imgIn -> row;
	const int col = imgIn -> col;
	const int layer = 3;
	
	struct image* imgOut = malloc_img(row, col);

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
							sum += imgIn -> img[i + m][j + n][k];
						}
					}
				}
				int aveResult = sum / count;
				imgOut -> img[i][j][k] = aveResult;
			}
		}
	}
	return imgOut;
}

struct image* edgeDetection(struct image* imgIn, int threshold) {
	//use 3 x 3 filter for edge detection
	const int row = imgIn -> row;
	const int col = imgIn -> col;
	const int layer = 3;

	struct image* imgOut = malloc_img(row, col);
	for (int i = 0; i < row; i++) {
		for (int j = 0; j < col; j++) {
			// for the edge of the input image, we simply ignore them 
			if (i == 0 || j == 0 || i == row - 1 || j == col - 1) {
				for (int k = 0; k < layer; k++)
					imgOut -> img[i][j][k] = 0;
			}
			// else, we compute the gradients and judge if it is edge
			else {
				float gradSum = 0; // total gradients
				for (int k = 0; k < layer; k++) {
					gradSum += abs(8 * imgIn -> img[i][j][k] 
							- imgIn -> img[i - 1][j - 1][k] - imgIn -> img[i - 1][j][k] - imgIn -> img[i - 1][j + 1][k]
							- imgIn -> img[i][j - 1][k] - imgIn -> img[i][j + 1][k]
							- imgIn -> img[i + 1][j - 1][k] - imgIn -> img[i + 1][j][k] - imgIn -> img[i + 1][j + 1][k]);
				}
				//printf("%f\n",gradSum);
				gradSum /= layer;
				if (gradSum >= threshold) {
					for (int k = 0; k < layer; k++)
						imgOut -> img[i][j][k] = imgIn -> img[i][j][k];
				}
				else {
					for (int k = 0; k < layer; k++)
						imgOut -> img[i][j][k] = 0;
				}
			}
		}
	}
	return imgOut;
}

