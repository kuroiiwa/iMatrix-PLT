
//int b[] = init1[:][:];

int main() {

	float a[] = [[1.2,2.3], [3.2,4.5]];

	a[1] = [5.2, 5.3];

	print(a[0][0]);
	print(a[0][1]);
	print(a[1][0]);
	print(a[1][1]);

	return 0;
}