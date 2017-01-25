#!/usr/bin/env python
EnsureSConsVersion(2, 5)

#
# Imports
#

import os
import re
from subprocess import call, check_call, Popen

#
# Builders
#

# Builder :: CrystalProgram
_builder_crystal = Builder(
    action='$CC build $CCFLAGS -o $TARGET $SOURCE'
    ,src_suffix='.cr'
    ,single_source=True
)

# Builder :: Link
_builder_link = Builder(
    action='$LD -o $TARGET $SOURCES $LDFLAGS'
    ,suffix='.o'
    ,src_suffix='.o'
)

#
# Defaults
#

default_arch = 'i386'
default_host = 'i686-elf'

#
# Options
#

AddOption(
    '--arch'
    ,dest='arch'
    ,type='string'
    ,action='store'
    ,help='Target architecture'
    ,default=default_arch
)

AddOption(
    '--host'
    ,dest='host'
    ,type='string'
    ,action='store'
    ,help='Target host'
    ,default=default_host
)

AddOption(
    '--qemu'
    ,dest='qemu'
    ,action='store_const'
    ,const='normal'
)

AddOption(
    '--qemu-curses'
    ,dest='qemu'
    ,action='store_const'
    ,const='curses'
)

#
# Globals
#

qemu = GetOption('qemu')

target = {
    'arch': GetOption('arch'),
    'host': GetOption('host'),
    'triple': '{}-unknown-nuummite-none'.format(GetOption('arch')),
}

dirs = {
    'conf': 'conf',
    'build': 'build',
    'kernel': 'kernel',
    'kernel:src': 'kernel/src',
    'runtime': 'libkrt',
    'sysroot': 'sysroot',
    'sysroot:boot': 'sysroot/boot',
    'arch': 'kernel/arch/{}'.format(target['arch']),
    'asm': 'kernel/arch/{}/asm'.format(target['arch']),
    'iso': 'build/isodir',
    'iso:boot': 'build/isodir/boot',
    'iso:grub': 'build/isodir/boot/grub',
    'iso:tree': 'build/isodir/boot/grub',
    'grub': 'conf/grub',
}

files = {

    # Source files
    'src': {
        'grub.cfg': os.path.join(dirs['grub'], 'grub.cfg'),
        'kernel': os.path.join(dirs['kernel:src'], 'kernel.cr'),
    },

    # Destination files
    'dst': {
        'grub.cfg': os.path.join(dirs['iso:grub'], 'grub.cfg'),
        'kernel': os.path.join(dirs['iso:boot'], 'nuummite.kern'),
        'iso': '{build}/nuummite-{arch}.iso'.format(build=dirs['build'], arch=target['arch']),
        'boot:kernel': '{sysroot}/kernel.o'.format(sysroot=dirs['sysroot:boot']),
    },

    # Object files
    'obj': {
        'kernel': '{build}/nuummite-{arch}.o'.format(build=dirs['build'], arch=target['arch']),
    },

}

# List of all objects
objects = [
    os.path.join(dirs['kernel:src'], 'kernel.o'),
]

#
# SConstruct Environment
#

env = Environment(
    ENV=os.environ,
    BUILDERS={
        'CrystalProgram': _builder_crystal,
        'Link': _builder_link
    }
)

# Assembler
env['AS'] = 'nasm'
env['ASFLAGS'] = '-felf32'

# Linker
env['LD'] = '{host}-gcc'.format(host=target['host'])
env['LDFLAGS'] = (
    ' -T{ldscript}'
    ' -ffreestanding'
    ' -nostdlib'
    ' -lgcc'
    ' -Wl,--nmagic,--gc-sections'
).format(ldscript=os.path.join(dirs['arch'], 'linker.ld'))

# Compiler
env['CC'] = 'crystal'
env['CCFLAGS'] = (
    ' --emit=obj'
    ' --cross-compile'
    ' --target={target}'
    ' --prelude=empty'
).format(target=target['triple'])

#
# Configuration
#

if not env.GetOption('clean'):
    conf = Configure(env)
    for prog in [env['AS'], env['LD'], env['CC'], 'grub-mkrescue']:
        if conf.CheckProg(prog): continue
        print('Unable to locate `{prog}`.'.format(prog=prog))
        Exit(1)
    env = conf.Finish()

#
# Commands
#

# Command :: Validate architecture
def ValidateArchitecture(*args, **kwargs):
    if not os.path.exists(dirs['arch']) or not os.path.isdir(dirs['arch']):
        print('Unknown architecture: `{arch}`.'.format(arch=target['arch']))
        Exit(2)
    print('Target: [arch: `{arch}`; host: `{host}`]'.format(
        arch=target['arch'],
        host=target['host']))

# Command :: Build kernel image
def BuildKernelImage(target, source, env):
    args = [
        'grub-mkrescue'
        ,'-o{iso}'.format(iso=files['dst']['iso'])
        ,'{isodir}'.format(isodir=dirs['iso'])
    ]
    retc = check_call(args)
    if retc == 0:
        return
    print("Unable to build the kernel image.")
    Exit(3)

# Command :: Run QEMU
def RunQEMU(*args, **kwargs):
    args = 'qemu-system-{arch} -cdrom {iso} {curses}'.format(
        arch=target['arch'],
        iso=files['dst']['iso'],
        curses=('--curses' if qemu == 'curses' else ''))
    call(args, shell=True)

#
# Build Preparation
#

if not env.GetOption('clean'):
    Execute([
        ValidateArchitecture,
        Mkdir(dirs['iso:tree']),
    ])

#
# Build Rules
#

# Rule :: Assemble sources
asm_sources = [p for p in os.listdir(dirs['asm']) if p.endswith('.asm')]
for f in asm_sources:
    f = os.path.join(dirs['asm'], f)
    o = env.StaticObject(source=f)
    objects.append(o[0])

# Rule :: Compile kernel
crystal = env.CrystalProgram(source=files['src']['kernel'])

# Rule :: Link objects
kernel = env.Link(target=files['obj']['kernel'], source=objects)
Requires(kernel, crystal)

# Rule :: Build kernel image
iso = env.Command(
    files['dst']['iso'],
    kernel, [
        # Update grub configuration
        Copy(files['dst']['grub.cfg'], files['src']['grub.cfg']),
        # Copy the kernel object to its destinations
        Copy(files['dst']['kernel'], files['obj']['kernel']),
        Copy(files['dst']['boot:kernel'], files['dst']['kernel']),
        # Build the kernel image
        BuildKernelImage,
    ]
)

# Rule :: Run QEMU
if qemu: env.Command('__qemu', iso, RunQEMU)