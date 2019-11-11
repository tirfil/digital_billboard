import sys
from PIL import Image

class rle:
	def __init__(self):
		self.state = 0;
		self.out = [];
		self.ocnt = []
		self.nreg = 0;
		self.current = 0;
		self.cnt = 0
		self.result = []
	def process(self,value):
		if self.state == 0:
			self.current = value
			self.out = []
			self.ocnt = []
			self.out.append(value)
			self.cnt = 0
			self.nreg = 0
			self.state = 1
		elif self.state == 1:
			if (self.current == value) and (self.cnt<3):
				self.cnt += 1
			else:
				if (self.nreg < 3):
					self.ocnt.append(self.cnt)
					self.current = value
					self.cnt = 0
					self.out.append(value)
					self.nreg += 1
				else:
					self.ocnt.append(self.cnt)
					self.compute()
					self.current = value
					self.out.append(value)
	def compute(self):
		calcul = 0;
		#print(self.out,self.ocnt)
		for i in self.ocnt:
			calcul = calcul << 2
			calcul +=i
		self.result.append(calcul)
		for i in self.out:
			self.result.append(i)
		self.ocnt = []
		self.out = []
		self.cnt = 0
		self.nreg = 0		
	def output(self):
		self.complete()
		#print(self.result)
		print(self.out)
		print(self.ocnt)
		return self.result
	def complete(self):
		if self.nreg < 4:
			self.ocnt.append(self.cnt)
			if self.nreg == 3:
				self.compute()
			else:
				tim = 3 - self.nreg
				for i in range(tim):
					self.out.append(0);
					self.ocnt.append(0)
				self.compute()
		


if __name__ == "__main__" :
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
		print(len(myarray))
		
		r = rle();
		for i in myarray:
			r.process(i)
		comp = r.output()
		
		size = len(comp)
		print(len(comp))
		
		offset = 0;
		sys.stdout.write('[ ')
		while (offset < size):
			for i in range(16):
				if (offset+i == size-1):
					sys.stdout.write("%3d ]" % comp[offset+i])
					break
				else:
					sys.stdout.write("%3d, " % comp[offset+i])
			print
			offset = offset + 16;
		#print(offset)
	
	
	
			

	
	
