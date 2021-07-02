#include<string.h>
#include "my_printf.h"
int fib(int m)
{
	if (m==1||m==2)
	return 1;
	int a=1,b=1,aw=0;
	while(m>=2)
	{
		aw=aw+a;
		a=b;
		b=aw;
		m=m-1;
	}
	return aw;
 } 
int main()
{
	int n = 3;
	// scanf("%d",&n);
	printf("%d",fib(n));
	return 0;
 } 
