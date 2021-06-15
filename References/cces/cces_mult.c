#include <sys/platform.h>
#include <stdio.h>
#include <builtins.h>

	/*	Template functions
	acc80 A_mul_uui(unsigned int __a, unsigned int __b);
	acc80 A_mac_ssi(acc80 __a, int __b, int __c);
	acc80 A_mul_uuf(unsigned int __a, unsigned int __b);
	acc80 A_mul_usf(unsigned int, signed int);
  more to come....
	*/

// Refer Page 2-153 (187) of CCES SHARC compiler manual for Multiplier specific functions

void main(void)
{
	acc80 mr;
	
	//multiplying 3fffffff and 7fffffff in usf mode
	//3fffffff = 1073741823 in unsigned int
	//7fffffff = 2147483647 in signed int
  	mr=A_mul_usf(1073741823,2147483647);		//0000 1fffffff 40000001
	printf("%lr\n",mr2(mr));
	printf("%lr\n",mr1(mr));
	printf("%lr\n",mr0(mr));

}

