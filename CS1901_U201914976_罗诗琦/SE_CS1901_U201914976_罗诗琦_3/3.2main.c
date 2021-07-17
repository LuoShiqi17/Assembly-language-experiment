//用户登录功能、主菜单的显示功能用 C语言程序实现
//用C语言实现，增加“6.添加新商品”的功能
//其他功能模块仍用汇编语言实现

#define _CRT_SECURE_NO_DEPRECATE
#define _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES 1
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


char bname[24] = "LUOSHIQI";
char bpass[11] = "U201914976";
char xname[24];
char xpass[11];
int i = 0;//用于记录新添加的结构的位置
extern char GOOD[10];
extern unsigned int SNUM;
extern unsigned int ANUM;
extern unsigned int tt;
extern unsigned short x;
extern unsigned char yy;
extern unsigned int goods_num;

struct GOODS {
	char GOODSNAME[10];
	unsigned short BUYPRICE;
	unsigned short SELLPRICE;
	unsigned short BUYNUM;
	unsigned short SELLNUM;
	short RATE;
};

extern void __stdcall stringcmp();
extern void __stdcall displaygoods(char[], struct GOODS*);
extern void __stdcall calculaterate();
extern void __stdcall rankrate();
extern void __stdcall winTimer(unsigned int);
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
	printf("%s  %hu  %hu  %hu  %hu  %hu\n", new_good[i].GOODSNAME, new_good[i].BUYPRICE, new_good[i].BUYNUM, new_good[i].SELLPRICE, new_good[i].SELLNUM, new_good[i].RATE);
	i++;
	goods_num++;
}
int main() {
	printf("Please enter your name:");
	scanf("%s", xname);
	printf("Please enter your password:");
	scanf("%s", xpass);
	if (strcmp(xname, bname) != 0) {
		printf("Your name does not match!\n");
		return 0;
	}
	if (strcmp(xpass, bpass) != 0) {
		printf("Your password does not match!\n");
		return 0;
	}
	int choice = 1;
	extern struct GOODS GA1[30];
	extern unsigned int ADRE[60];
	//extern unsigned int ADRE2[30];
	while (choice) {
		printf("\n\t\tmune\n");
		printf("**********************************************\n");
		printf("\t1.Find goods and display information\n");
		printf("\t2.Sales volumes\n");
		printf("\t3.Replenishment\n");
		printf("\t4.Calculate the profit margin of goods\n");
		printf("\t5.Display product information according to profit margin from high to low\n");
		printf("\t6.Add new good\n");
		printf("\t0.Exit\n");
		printf("**********************************************\n");
		printf("Please enter your choice:");
		scanf("%d", &choice);
		switch (choice) {
		case 1:
			printf("Please enter the name of the good:");
			scanf("%s", GOOD);
			displaygoods(GOOD, &GA1);
			break;
		case 2:
			printf("Please enter the name of the good:");
			scanf("%s", GOOD);
			printf("Please enter the sellnumber:");
			scanf("%u", &SNUM);
			displaygoods(GOOD, &GA1);
			SNUM = 0;
			break;
		case 3:
			printf("Please enter the name of the good:");
			scanf("%s", GOOD);
			printf("Please enter the addnumber:");
			scanf("%u", &ANUM);
			displaygoods(GOOD, &GA1);
			ANUM = 0;
			break;
		case 4:
			tt = 0;
			winTimer(0);//开始计时
			while (tt != 1000000) {
				yy = 0;
				x = 0;
				tt++;
				__asm push offset GA1
				__asm call calculaterate
				__asm add esp, 4
				rankrate();
			}
			int j = 0;
			unsigned int goodn = goods_num;
			while (goodn) {
				printf("%s  %hu  %hu  %hu  %hu  %hd\n", GA1[j].GOODSNAME, GA1[j].BUYPRICE, GA1[j].SELLPRICE, GA1[j].BUYNUM, GA1[j].SELLNUM, GA1[j].RATE);
				goodn--;
				j++;
			}
			printf("\nranked:\n\n");
			goodn = goods_num;
			struct GOODS* pp = *ADRE;
			j = 1;
			while (goodn--) {
				printf("%s  %hu  %hu  %hu  %hu  %hd\n", pp->GOODSNAME, pp->BUYPRICE, pp->SELLPRICE, pp->BUYNUM, pp->SELLNUM, pp->RATE);
				pp = *(ADRE + (j++));
			}
			winTimer(1);
			break;
		case 5:
			pp = *ADRE;
			j = 1;
			goodn = goods_num;
			while (goodn--) {
				printf("%s  %hu  %hu  %hu  %hu  %hd\n", pp->GOODSNAME, pp->BUYPRICE, pp->SELLPRICE, pp->BUYNUM, pp->SELLNUM, pp->RATE);
				pp = *(ADRE + (j++));
			}
			break;
		case 6:
			add_new_good();
			break;
		case 0:
			break;
		default:
			printf("Invalid data!\n");
			break;
		}
	}
	return 0;
}