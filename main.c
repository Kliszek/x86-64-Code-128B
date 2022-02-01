#include <stdio.h>
#include <stdlib.h>
#include <cstdio>

extern "C" int encode128(unsigned char* dest_bitmap,
	int bar_width,
	char* text,
	unsigned char* code_table);

int main(void)
{
  unsigned char* dest_bitmap;
  int bar_width = 2;
  int result;
  unsigned char* code_table;

  dest_bitmap = (unsigned char*)malloc(90054);
  code_table = (unsigned char*)malloc(856);

  char text[] = "123456789";

  //char text[21];
  //printf("Please type the string: ");
  //scanf("%20s", &text);

  FILE* codes_file = fopen("code128b.bin", "rb");
  if (!codes_file)
  {
	  printf("ERROR: There was a problem with file 'code128b.bin'!\n");
	  return 3;
  }
  fread(code_table, 1, 855, codes_file);
  fclose(codes_file);

  printf("Input string      > %s\n", text);

  result = encode128(dest_bitmap, bar_width, text, code_table);
  
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
