#include <stdio.h>

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

void printIntArr(int*** arr, int x, int y, int z) {
	if (y == 0 && z == 0) {
		int* ptr = (void *)arr;
		for (int i = 0; i < x; i++)
			printf("%d  ", ptr[i]);
		printf("\n");
		return;
	} else if (z == 0) {
		int** ptr = (void*)arr;
		for (int i = 0; i < x; i++) {
			for(int j = 0; j < y; j++)
				printf("%d  ", ptr[i][j]);
			printf("\n");
		}
		printf("\n");
	} else {
		int*** ptr = arr;
		for (int i = 0; i < x; i++) {
			for (int j = 0; j < y; j++) {
				for (int k = 0; k < z; k++)
					printf("%d  ", ptr[i][j][k]);
				printf("\n");
			}
			printf("\n");
		}
		printf("\n");
	}
}

void printFloatArr(double*** arr, int x, int y, int z) {
	if (y == 0 && z == 0) {
		double* ptr = (void *)arr;
		for (int i = 0; i < x; i++)
			printf("%f  ", ptr[i]);
		printf("\n");
		return;
	} else if (z == 0) {
		double** ptr = (void*)arr;
		for (int i = 0; i < x; i++) {
			for(int j = 0; j < y; j++)
				printf("%f  ", ptr[i][j]);
			printf("\n");
		}
		printf("\n");
	} else {
		double*** ptr = arr;
		for (int i = 0; i < x; i++) {
			for(int j = 0; j < y; j++) {
				for (int k = 0; k < z; k++)
					printf("%f  ", ptr[i][j][k]);
				printf("\n");
			}
			printf("\n");
		}
		printf("\n");
	}
}