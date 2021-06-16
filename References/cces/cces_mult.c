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
	
	//Refer below for few more examples
	
	mr=A_mul_usf(53084160,-24816);		//MR = 032a0000*ffff9f10 USF
	
	mr=A_mul_usf(53084160,-24816);		//MR = 032a0000*ffff9f10 usf
	mr=A_mac_uuf(mr,53084160,40720);	//MR = MR + 032a0000*00009f10 uuf
	
	mr=A_mul_usf(53084160,-24816);		//MR = 032a0000*ffff9f10 USF
	mr=A_mac_ssfr(mr,53084160,-24816);	//MR = MR + 032a0000*ffff9f10 ssfr

	mr=A_mul_ssf(53084160,-24816);		//MR = 032a0000*ffff9f10 SSF
	mr=A_msub_sufr(mr,53084160,40720);	//MR = MR + 032a0000*ffff9f10 sufr
	
	//Use below part to print the result in mr2, mr1, mr0
	printf("%lr\n",mr2(mr));
	printf("%lr\n",mr1(mr));
	printf("%lr\n",mr0(mr));
}

