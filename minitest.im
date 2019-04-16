
struct test {
	int a;
};

struct test test_f(struct test tmp) {
	tmp.a = 2;
	return tmp;
}
int main() {	
	struct test me;
	me.a = 1;

	struct test notme;
	notme = test_f(me);
	print(me.a);
	print(notme.a);
	return 0;
}
