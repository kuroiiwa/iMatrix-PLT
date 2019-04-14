struct test{
	int b[5];
};


int main() {	

	mat a(5,5);

	a[0][0] = 1.;

	print(a);

	free_mat(a);

	return 0;
}
