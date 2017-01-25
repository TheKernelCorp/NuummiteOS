# NuummiteOS

An OS written in [Crystal][crystal_home] as a Proof of Concept.   
Join our team on [Discord][discord] or [IRC][webchat] ( `#nuummite @ int0x10.com:6697 (SSL)` )

## Contributing

We're always looking for help with our [Projects][projects]!

## Building on Linux/WSL

- Get an [i686-elf gcc cross-compiler][cross_cc] going
- Install the [latest Crystal compiler][crystal_compiler]
- Install the [latest version of SCons][scons]
- Run `scons` to build
- Run `scons --qemu-curses` to build and run qemu

## Running tests

Run `crystal spec kernel/runtime`

## Troubleshooting

**`xorriso : FAILURE : Cannot find path '/efi.img' in loaded ISO image`** `or`   
**`grub-mkrescue: error: ``mformat`` invocation failed`**:

* On Arch: `sudo pacman -Sy mtools`
* On Debian/Ubuntu/WSL: `sudo apt-get install mtools`
* On Fedora/RedHat/CentOS: `sudo yum install mtools`

[cross_cc]: http://wiki.osdev.org/GCC_Cross-Compiler
[crystal_home]: https://crystal-lang.org
[crystal_compiler]: https://crystal-lang.org/docs/installation/index.html
[discord]: https://discord.gg/nmESdX8
[webchat]: http://int0x10.com/webchat?nick=&channels=nuummite%2Cprogramming%2C%23chat
[scons]: http://scons.org/
[projects]: https://github.com/TheKernelCorp/NuummiteOS/projects
