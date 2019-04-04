
//int b[] = init1[:][:];

int main() {

	float a[] = [[1.2,2.3], [3.2,4.5]];

	mat c[] = [a[0][:]];

	int b[] = [[1,2,3,4], [5,6,7,8]];

	img d[] = [b,b];

	printFloatArr(a);
	printFloatArr(c);

	printIntArr(b);
	printIntArr(d);
	return 0;
}