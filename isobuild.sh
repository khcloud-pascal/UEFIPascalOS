	/home/tydq/下载/source/compiler/ppcrossa64 -n -O- -Si -Sc -Sg -Xd -CX -XXs -Tlinux -Cg uefiinstaller.pas
	/home/tydq/下载/source/compiler/ppcrossa64 -n -O- -Si -Sc -Sg -Xd -CX -XXs -Tlinux -Cg uefimain.pas
	mkdir installer
	aarch64-linux-gnu-ld -shared -Bsymbolic --gc-sections -ffreestanding -fno-stack-protector -fno-stack-check -fshort-wchar --no-keep-memory -nostdlib  uefiinstaller.o uefi.o tydqfs.o system.o -e efi_main -o installer.so
	aarch64-linux-gnu-objcopy -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .rel.* -j .rela.* -j .reloc --target=efi-app-aarch64 --subsystem=10 installer.so installer/bootx64.efi
	mkdir kernel
	aarch64-linux-gnu-ld -shared -Bsymbolic --gc-sections -ffreestanding -fno-stack-protector -fno-stack-check -fshort-wchar --no-keep-memory -nostdlib uefimain.o uefi.o tydqfs.o system.o -e efi_main -o main.so
	aarch64-linux-gnu-objcopy -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .rel.* -j .rela.* -j .reloc --target=efi-app-aarch64 --subsystem=10 main.so kernel/bootaarch64.efi
	dd if=/dev/zero of=fat.img bs=512 count=131072
	/usr/sbin/mkfs.vfat -F 32 fat.img
	mmd -i fat.img ::
	mmd -i fat.img ::/EFI
	mmd -i fat.img ::/EFI/BOOT
	mmd -i fat.img ::/EFI/SETUP
	mcopy -i fat.img installer/bootx64.efi ::/EFI/BOOT
	mcopy -i fat.img kernel/bootx64.efi ::/EFI/SETUP
	mkdir iso
	cp fat.img iso
	xorriso -as mkisofs -R -f -e fat.img -no-emul-boot -o TestOS.iso iso
	rm -rf iso
	rm -rf *.ppu
	rm -rf fat.img
	rm -rf *.o
	rm -rf installer
	rm -rf kernel
