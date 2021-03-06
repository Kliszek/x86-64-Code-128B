#include <stdio.h>
#include <stdlib.h>
#include <cstdio>

extern "C" int encode128(unsigned char* dest_bitmap,
	int bar_width,
	char* text);

int main(void)
{
  unsigned char* dest_bitmap;
  int bar_width = 2;
  int result;

  dest_bitmap = (unsigned char*)malloc(90054);

  char text[] = "123456789";

  //char text[21];
  //printf("Please type the string: ");
  //scanf("%20s", &text);

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
	  case 3:
	  {
		  printf("ERROR: There was a problem with file 'code128b.bin'!\n");
		  break;
	  }
	  case 4:
	  {
		  printf("ERROR: Cannot read file 'code128b.bin'!\n");
		  break;
	  }

	  default:
		  printf("Program returned this value: %i\n", result);
		  break;
  }
  
  return result;
}
