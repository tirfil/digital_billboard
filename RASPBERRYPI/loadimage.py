from PIL import Image
import sys
import spidev

def read_control():
	response=spi.xfer2([0x50,0x00])
	return response[1]

def read_status():
	response=spi.xfer2([0x40,0x00])
	return response[1]

def read_data():
	response=spi.xfer2([0x30,0x00,0x00])
	return response[1:2]

def write_control(data):
	spi.xfer2([0x05,data])

def write_data(msb,lsb):
	test_data_done()
	spi.xfer2([0x01,msb,lsb])

def write_address(msb,xsb,lsb):
	test_data_done()
	spi.xfer2([0x02,msb,xsb,lsb])

def read_command():
	test_data_done()
	spi.xfer2([0x03])

def test_data_done():
	stat = read_status()
	while(not(stat & 0x01)):
		stat = read_status()


if __name__ == "__main__" :
#print(sys.argv)
	if len(sys.argv) == 2:
		spi=spidev.SpiDev()
		spi.open(0,0)
		spi.mode=0b00
		spi.lsbfirst=False
		#spi.max_speed_hz=1350000
		spi.max_speed_hz=15000000

		ctrl = read_control()
		print(ctrl)
		mode0 = bool(ctrl & 0x01)
		mode1 = bool(ctrl & 0x02)
		mode2 = bool(ctrl & 0x04)
		#print(mode2,mode1,mode0)
		if (mode0 != mode1):
			write_address(0,0,0)
		else:
			write_address(16,0,0) 
		if (mode0 == False):
			mode1 = not mode1
		mode0 = False 
		#print(mode2,mode1,mode0)
		ctrl = 0
		if mode0:
			ctrl = 1
		if mode1:
			ctrl = ctrl + 2
		if mode2:
			ctrl = ctrl + 4
		print(ctrl)
		v1 = 0
		im = Image.open(sys.argv[1])
		im = im.convert('RGB')
		#print(im.mode)
		#print("w=%d h=%d\n"%(width,height))
		pixels = im.load()
		width, height = im.size
		i = 0
		for y in range(height):
			for x in range(width):
				r,g,b = pixels[x,y]
				r = r/32
				g = g/32
				b = b/64
				v0 = r*32+g*4+b
				if (i%2 == 1):
					write_data(v0,v1)
				else:
					v1 = v0
				i += 1
		write_control(ctrl)
		spi.close()
