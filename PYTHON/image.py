import sys
from PIL import Image
#print(sys.argv)
if len(sys.argv) == 2:
	myarray = []
	#print(sys.argv[1])
	im = Image.open(sys.argv[1])
	im = im.convert('RGB')
	#print(im.mode)
	#print("w=%d h=%d\n"%(width,height))
	pixels = im.load()
	width, height = im.size
	for y in range(height):
		for x in range(width):
			r,g,b = pixels[x,y]
			r = r/32
			g = g/32
			b = b/64
			value = r*32+g*4+b
			myarray.append(value)
	size = len(myarray)
	offset = 0;
	sys.stdout.write('[ ')
	while (offset < size):
		for i in range(16):
			if (offset+i == size-1):
				sys.stdout.write("%3d ]" % myarray[offset+i])
			else:
				sys.stdout.write("%3d, " % myarray[offset+i])
		print
		offset = offset + 16;
	
	
	
			

	
	
