#ifndef BUILTIN_H
#define BUILTIN_H

struct img {
	int row;
	int col;
	/* channel num is 3 by default */
	unsigned char*** data;
};

struct mat {
	int row;
	int col;
	double** data;
};

struct img* malloc_img(int row, int col);

#endif