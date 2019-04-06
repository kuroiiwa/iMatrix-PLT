
//int b[] = init1[:][:];


int main() {

	mat a[] = [[1.,2.],[3.,4.]];

	mat b[] = [[5.,6.], [7.,8.]];

	float c[] = [[10.,11.], [11.,12.]];

	float d[] = [c[:], c[:]];


	d[0][0] = c[1];

	printFloatArr(d);
	return 0;
}