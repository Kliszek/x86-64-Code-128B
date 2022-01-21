#include <stdio.h>
#include <stdlib.h>
#include <cstdio>

extern "C" int encode128(unsigned char* dest_bitmap,
	int bar_width,
	char* text);

int main(void)
{
  char text[] = "123456789";
  unsigned char* dest_bitmap;
  int bar_width = 2;
  int result;

  dest_bitmap = (unsigned char*)malloc(90054);

  printf("Input string      > %s\n", text);

  result = encode128(dest_bitmap, bar_width, text);
  
  switch(result)
  {
	  case 0:
	  {
		  FILE* output = fopen("output.bmp", "w");
		  if (!output)
		  {
			  printf("Error saving the file!\n");
			  return 1;
		  }
		  fwrite(dest_bitmap, 1, 90054, output);
		  fclose(output);
		  printf("Barcode successfully generated\n");
		  break;
	  }
	  case 1:
	  {
		  printf("ERROR: Provided string is too long!\n");
		  break;
	  }
	  case 2:
	  {
		  printf("ERROR: Provided string contains invalid symbols!\n");
		  break;
	  }

	  default:
		  printf("Program returned this value: %i\n", result);
		  break;
  }
  
  return result;
}
