preset:
	pip install -r requirments.txt

build:
	nasm -f elf64 mylib.asm -o mylib.o -DPIC
	ld -shared mylib.o -o libmylib.so
	maturin develop --release