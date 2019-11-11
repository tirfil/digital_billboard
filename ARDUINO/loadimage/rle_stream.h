#ifndef RLE_STREAM_H
#define RLE_STREAM_H

#include <stdio.h>
#include <stdint.h>
#include <avr/pgmspace.h>

class Rle_stream
{
	public:
		Rle_stream(const uint8_t*,int);
		~Rle_stream();
		int get_next_value();
	private:
		int modulo5;
		int cnt_table[4];
		int index;
		const uint8_t* table;
		int size;
};

#endif
