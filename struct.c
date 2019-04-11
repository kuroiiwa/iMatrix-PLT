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

int main(void) {
	
	struct image* i = malloc_img(640,480);
	printf("Hello World\n");
	
	const int row = i -> row;
	const int col = i -> col;

	for (int r = 0; r < row; r++) {
		for (int c = 0; c < col; c++) {
			for (int ch = 0; ch < 3; ch++)
				i -> img[r][c][ch] = 1;
		}
	}

	for (int r = 0; r < row; r++) {
		for (int c = 0; c < col; c++) {
			for (int ch = 0; ch < 3; ch++)
				printf("%d  ", i -> img[r][c][ch]);
		}
	}
	free_img(i);

	struct mat_double* m1 = malloc_mat_double(100,80);
	free_mat_double(m1);

	struct mat_int* m2 = malloc_mat_int(1000,800);
	free_mat_int(m2);


	printf("\nfreed\n");

	return 0;
}
