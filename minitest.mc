struct test2 {
	int id;
	int num[3];
};

struct test {
	struct test2 mem3;
	int mem1;
	float mem2[2,2];
	struct test2 mem4[2];
};

struct test2 tmp;
int main() {	

	struct test a;

	a.mem3.id = 1;
	a.mem3.num = [1,2,3];
	a.mem3.num[1] = 5;
	a.mem2 = [[1.,2.],[3.,4.]];
	a.mem2[1] = [5.,6.];
	a.mem2[0][0] = 2.;
	a.mem4[0].id = 2;
	a.mem4[1].num = [5,6,7];
	a.mem4[1].num[1:] = [1,2];

	print("should be 1:");
	print(a.mem3.id);
	print("should be [1,5,3]:");
	printIntArr(a.mem3.num);
	print("should be 0:");
	print(a.mem1);
	print("should be [5.0, 6.0]:");
	printFloatArr(a.mem2[1]);
	print("should be 2.0:");
	print(a.mem2[0][0]);
	print("should be 2:");
	print(a.mem4[0].id);
	print("should be [5, 1, 2]:");
	printIntArr(a.mem4[1].num[:]);
	print("should be 1:");
	print(a.mem4[1].num[1]);

	return 0;
}