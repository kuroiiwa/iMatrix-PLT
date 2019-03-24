
int g = 1;
float asd = 1.2;

int test(int a, int b) {
	a = 10;
	{
		int c;
		c = 5;
		printall(c);
	}
	printall(b);
	printall("Hello World");
	return 1;
}


int main() {
	int a;
	a = 1;
	char b;
	b = 'a';
	test(1, 2);
    return 0;
}
