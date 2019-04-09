#include <stdio.h>
#include <stdlib.h>

struct image {
	int row;
	int col;
	/* channel num is 3 by default */
	int*** img;
};

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

int main(void) {
  
  struct image* i = (struct image*) malloc(sizeof(struct image));
  void* ptr = i -> img;
  const int row = 10;
  const int col = 8;
  const int chn = 3;
	i -> row = row;
	i -> col = col;
  i -> img = (int***) malloc(sizeof(int**) * row);
  for (int r = 0; r < row; r++) {
    i -> img[r] = (int**) malloc(sizeof(int*) * col);
    for (int c = 0; c < col; c++) {
      i -> img[r][c] = (int*) malloc(sizeof(int*) * chn);
    }
  }
  printf("Hello World\n");
  
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

  printf("\nfreed\n");

  return 0;
}
