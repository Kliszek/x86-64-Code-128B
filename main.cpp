#include <stdio.h>

extern "C" int encode128(unsigned char* dest_bitmap,
	int bar_width,
	char* text);

int main(void)
{
  char text[] = "Wind On The Hill";
  unsigned char dest_bitmap[] = "output.bmp";
  int bar_width = 1;
  int result;
  
  printf("Input string      > %s\n", text);

  result = encode128(dest_bitmap, bar_width, text);
  
  switch(result)
  {
	  case 0:
		printf("Barcode successfully generated\n");
		break;
  }
  
  return result;
}
