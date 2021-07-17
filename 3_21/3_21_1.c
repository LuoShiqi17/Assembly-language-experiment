//用户登录功能、主菜单的显示功能用 C语言程序实现
//用C语言实现，增加“6.添加新商品”的功能
//其他功能模块仍用汇编语言实现
#define _CRT_SECURE_NO_DEPRECATE
#define _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES 1
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

struct GOODS {
	char GOODSNAME[10];
	unsigned short BUYPRICE;
	unsigned short SELLPRICE;
	unsigned short BUYNUM;
	unsigned short SELLNUM;
	short RATE;
};
int i = 0;
extern unsigned int goods_num;

int user_load_in() {
	extern char XNAME[24];
	extern char XPASS[11];
	extern char BNAME[24];
	extern char BPASS[11];
	printf("Please enter your name:");
	scanf("%s", XNAME);
	printf("Please enter your password:");
	scanf("%s", XPASS);
	if (strcmp(XNAME, BNAME) != 0) {
		printf("Your name does not match!\n");
		return 0;
	}
	if (strcmp(XPASS, BPASS) != 0) {
		printf("Your password does not match!\n");
		return 0;
	}
	return 1;
}
void menucard() {
	printf("\n\r\r\r\rmune\n");
	printf("**********************************************\n");
	printf("\r1.Find goods and display information\n");
	printf("\r2.Sales volumes\n");
	printf("\r3.Replenishment\n");
	printf("\r4.Calculate the profit margin of goods\n");
	printf("\r5.Display product information according to profit margin from high to low\n");
	printf("\r6.Add new good\n");
	printf("\r0.Exit\n");
	printf("**********************************************\n");
	printf("Please enter your choice:");
}
void add_new_good() {
	extern struct GOODS new_good[30];
	printf("Please enter the name of the new good:");
	scanf("%s", new_good[i].GOODSNAME);
	printf("Please enter the buyprice:");
	scanf("%hu", &new_good[i].BUYPRICE);
	printf("Please enter the sellprice:");
	scanf("%hu", &new_good[i].SELLPRICE);
	printf("Please enter the buynumber:");
	scanf("%hu", &new_good[i].BUYNUM);
	printf("Please enter the sellnumber:");
	scanf("%hu", &new_good[i].SELLNUM);
	printf("%s %hu %hu %hu %hu %hu\n", new_good[i].GOODSNAME, new_good[i].BUYPRICE, new_good[i].BUYNUM, new_good[i].SELLPRICE, new_good[i].SELLNUM, new_good[i].RATE);
	i++;
	extern unsigned int goods_num;
	goods_num++;
}