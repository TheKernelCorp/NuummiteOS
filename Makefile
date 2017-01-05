export HOST:=i686-elf
export ARCH:=$(shell if echo $(HOST) | grep -Eq '[[:digit:]]86-'; then \
	echo i386 ; \
else \
	echo $(HOST) | grep -Eo '^[[:alnum:]_]*'; \
fi)
export HOSTARCH=$(ARCH)

export MAKE:=$(MAKE:-make)

export NASM:=nasm
export CC:=$(HOST)-gcc
export LD:=$(HOST)-gcc

export NASMFLAGS:=-felf32

export PREFIX:=/usr
export EXEC_PREFIX:=$(PREFIX)
export BOOTDIR:=/boot

SYSTEM_PROJECTS:=kernel
PROJECTS:=$(SYSTEM_PROJECTS)

export DESTDIR:=$(PWD)/sysroot

.PHONY: all iso sysroot projects qemu qemu-curses qemu-curses-halt check clean

all: iso

iso: projects sysroot
	cp grub/grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o nuummiteos.iso isodir

sysroot:
	mkdir -p isodir
	mkdir -p isodir/boot
	mkdir -p isodir/boot/grub
	cp sysroot/boot/nuummite.kern isodir/boot/nuummite.kern

projects: clean
	for PROJECT in $(PROJECTS); do \
		make -s -C $$PROJECT install ; \
	done

qemu: all
	qemu-system-$(ARCH) -cdrom nuummiteos.iso

qemu-curses: all
	qemu-system-$(ARCH) -cdrom nuummiteos.iso -curses

qemu-curses-halt: all
	qemu-system-$(ARCH) -cdrom nuummiteos.iso -curses -no-reboot -no-shutdown

check: projects clean

clean:
	for PROJECT in $(PROJECTS); do \
		make -s -C $$PROJECT clean; \
	done
	rm -rf sysroot
	rm -rf isodir
	rm -rf nuummite.iso
