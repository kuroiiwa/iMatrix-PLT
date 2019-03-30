void testfunc(int a, int b, mat m, img i) {
	
} 


int main() {

	char a;
	int b;
	b = 2;
	a = 't';
	a = '"';
	string c = "abc";
	mat m1[1,3];
	m1 = [5,4,3];
	//m1 = [[[1,2,3]]]; // failure
	mat m2[3,2,1];
	mat m3a = [2,3,4];
	mat m3b = [[2,3,4]];
	mat m3c = [[[2,3,4]]];
	mat m3d[1,1,3] = [[[2,3,4]]];
	//mat m3f[2,3] = [[[2,3,4]]]; // failure
	mat m5[1,2] =[[5,6]];  
	
	img i[2,3];
	int a = [1,2,3];
	char b [2] = [1,2];
	float c [2,2,2] = [[[1.,2.],[1.,2.]],[[1.,2.],[1.,2.]]];
	c = "asdasdasd";

    return 0;
}
