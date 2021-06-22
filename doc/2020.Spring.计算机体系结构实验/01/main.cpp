#include <iostream>

/* run this program using the console pauser or add your own getch, system("pause") or input loop */

int func1(int n)
{
    if ( n == 1 )
	    return 1;
	else if ( n > 1 )
		return n * func1(n-1);	
}
 
int func2(int n)
{
	if ( n == 1 || n == 2 )
	    return 1;
	else {
		int i = 2, a = 1, b = 1;
		while ( i < n ) {
			b = a + b;
			a = b - a;
			i ++;
		}
		return b; 
	}
}

int main(int argc, char** argv) {
	int n, fn1, fn2;
	
	if ( argc != 2 ) {
		printf( "format: test n\n" );
		exit(-1);
	}
	
	sscanf( argv[1], "%d", &n );
	printf( "n = %d\n", n );
	
	fn1 = func1( n );
	fn2 = func2( n );
	
	printf( "n = %d, fn1 = %d, fn2 = %d\n", n, fn1, fn2 );
	
	return 0;
}
