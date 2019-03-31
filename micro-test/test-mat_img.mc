void testfunc(int a, int b, mat c, img d) {
	
} 

/* TO BE DONE: 	direct assign to type, e.g. img a = [1,2,3]; int a = [1,2,3]; */

int main() {
	
	/* declare and assign separately */
		/* positive */
	mat m11[3];
	m11 = [1,2,3];
	mat m12[1,3];
	m12 = [[5,4,3]];
	mat m13[2,2,2];
	m13 = [[[1,2],[3,4]],[[5,6],[7,8]]]; // should be checked by semantic
	
		/* negative */
	//m11 = [[[1,2,3]]]; // SEMANTIC: dim failure
	//mat m1a[]; // declare failure
	
	/* declare + assign */
		/* positive */

	mat m24[] = [2,3,4]; // 3
	mat m25[] = [[2,3,4],[5,6,7]]; // 2 x 3
	img i26[] = [[[1,2,3,4],[1,2,3,4],[1,2,3,4]],[[1,2,3,4],[1,2,3,4],[1,2,3,4]]]; // 2 x 3 x 4
	
	mat m27[3] = [1,2,3];
	mat m28[1,3] = [[5,4,3]];
	img i29[2,3,4] = [[[1,2,3,4],[1,2,3,4],[1,2,3,4]],[[1,2,3,4],[1,2,3,4],[1,2,3,4]]];
	
		/* negative */
	//img i21[] = [1,2,3];
	//img i22[] = [[5,4,3]];
	//img i23[3] = [1,2,3];
	//img i24[1,3] = [[5,4,3]];
	//mat m2a = [[2,3,4]]; // declare failure
	//mat m3f[2,3] = [[[2,3,4]]]; // dim failure
	//mat m26[] = [[[1,2,3,4],[1,2,3,4],[1,2,3,4]],[[1,2,3,4],[1,2,3,4],[1,2,3,4]]]; // 2 x 3 x 4, mat can not be 3d
	
	
	/* other types */
		/* positive */
	int a[3] = [1,2,3];
	char b [2] = [1,2];
	float c [2,2,2] = [[[1.,2.],[1.,2.]],[[1.,2.],[1.,2.]]];

		/* negative */
	//int abd = [4,5,6];

    return 0;
}
