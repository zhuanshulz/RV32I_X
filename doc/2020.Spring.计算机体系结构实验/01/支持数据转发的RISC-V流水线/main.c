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

int main(){
    int n, fn1, fn2;
    n = 10;
	fn1 = func1( n );
	fn2 = func2( n );
	return fn1+fn2;
}