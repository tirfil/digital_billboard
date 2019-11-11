#include "rle_stream.h"

Rle_stream::Rle_stream(const uint8_t* t, int s)
{
	table = t;
	index = 0;
	modulo5 = 0;
	size = s;
}

Rle_stream::~Rle_stream()
{
}

int Rle_stream::get_next_value()
{
	int lenreg;
	uint8_t ret;
	
	while (index < size) {
		if (modulo5 == 0 ) {
			//lenreg = table[index];
			lenreg = pgm_read_word_near(table+index);
			for(int i=0; i<4; i++)
			{
				cnt_table[i] =  1 + ((lenreg & 0xC0) >> 6);
				lenreg = lenreg << 2;
			}
			modulo5 = 1;
			index++;
		} else {
		
			if (cnt_table[modulo5-1] != 0)
			{
				//ret = table[index];
				ret = pgm_read_word_near(table+index);
				cnt_table[modulo5-1]--;
				return ret;
			} 
			
			if (cnt_table[modulo5-1] == 0)
			{
				if (modulo5 < 4) 
					modulo5++;
				else
					modulo5 = 0;
				
				index++;
			}
		}
	}
	
	return -1;
}
		
			
