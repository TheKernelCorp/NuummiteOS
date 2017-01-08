# NuummiteOS

An OS written in [Crystal][crystal_home] as a Proof of Concept.   
[Join our team on Discord!][discord]

## Building on Linux/WSL

- Get an [i686-elf gcc cross-compiler][cross_cc] going
- Install the [latest Crystal compiler][crystal_compiler]
- Run `make`

## Using the recovery shell

- Username is: `root`
- Password is: `1234`
- Commands can be listed using `help`

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