#include <stdio.h>
int  a[5] = { 1, 2, 3, 4, 5 };
unsigned short x = 100;
unsigned short y = -32700;  //ע��۲��ʼֵ�ϴ����������
int  psub;
int sum(int a[], unsigned length)
{
	int i;
	int result = 0;
	for (i = 0; i < length; i++)
		result += a[i];

	return result;
}
int main(int argc, char* argv[])
{
	short z;short zz;
	char str[10] = "The end!";
	z = sum(a, 5);
	printf("sum : %d \n", z);
	if (x > y)
		printf("condition1:  %d > %d \n", x, y);
	else
		printf("condition1:  %d < %d \n", x, y);
	z = x - y;
	zz = x + y;
	printf("condition2: (%d) - (%d) = %d \n", x, y, z);
	psub = &x - &y;
	if (psub < 0)
		printf("condition3: & %d < & %d \n", x, y);
	printf(str);
	return 0;
}