TARGET?=i386-unknown-nuummite-gnu
CRYSTAL_FLAGS?=--emit obj --cross-compile --target "$(TARGET)" --prelude=empty
LDFLAGS?=-ffreestanding -nostdlib -n
NASMFLAGS?=

DESTDIR?=
PREFIX?=/usr/local
EXEC_PREFIX=$(PREFIX)
BOOTDIR?=$(EXEC_PREFIX)/boot

ARCHDIR:=arch/$(HOSTARCH)

include $(ARCHDIR)/make.conf

OBJS:=\
$(ARCH_OBJS) \
src/kernel.o

ALL_OBJS:=\
$(OBJS)

OBJ_LINK:=\
$(OBJS)

all: nuummite.kern

.PHONY: all nuummite.kern install install-kern clean

nuummite.kern: $(OBJ_LINK) $(ARCHDIR)/linker.ld
	$(LD) -T $(ARCHDIR)/linker.ld -o $@ $(OBJ_LINK) $(LDFLAGS) -lgcc

%.o: %.cr
	crystal build $(CRYSTAL_FLAGS) $< -o $(shell echo $@ | cut -f 1 -d '.')

%.o: %.asm
	$(NASM) $(NASMFLAGS) $< -o $@

install: install-kern

install-kern: nuummite.kern
	mkdir -p $(DESTDIR)$(BOOTDIR)
	cp nuummite.kern $(DESTDIR)$(BOOTDIR)

clean:
	rm -rf nuummite.kern $(OBJS) $(ALL_OBJS) *.o
