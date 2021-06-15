#include <sys/platform.h>
#include <stdio.h>
#include <builtins.h>

	/*	Template functions
	acc80 A_mul_uui(unsigned int __a, unsigned int __b);
	acc80 A_mac_ssi(acc80 __a, int __b, int __c);
	acc80 A_mul_uuf(unsigned int __a, unsigned int __b);
  more to come....
	*/

void main(void)
{
	acc80 mr;

  mr=A_mul_ssf(53084160,-24816);
	mr=A_msub_ssfr(mr,53084160,-24816);
	printf("%lr\n",mr2(mr));
	printf("%lr\n",mr1(mr));
	printf("%lr\n",mr0(mr));

}

