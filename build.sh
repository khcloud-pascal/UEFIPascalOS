	fpc -XPx86_64-w64-mingw32- -Aas -n -O4 -Si -Sc -Sg -Xd -CX -XXs -Px86_64 -Rintel -Twin64 -Cg uefiinstaller.pas
	fpc -XPx86_64-w64-mingw32- -Aas -n -O4 -Si -Sc -Sg -Xd -CX -XXs -Px86_64 -Rintel -Twin64 -Cg uefimain.pas
	mkdir installer
	x86_64-w64-mingw32-ld --gc-sections -shared -Bsymbolic --no-keep-memory -nostdlib -oformat=pei-x86-64 uefiinstaller.o uefi.o tydqfs.o system.o -e efi_main -o installer.dll
	objcopy -I pei-x86-64 -O efi-app-x86_64 installer.dll installer/bootx64.efi
	mkdir kernel
	x86_64-w64-mingw32-ld --gc-sections -shared -Bsymbolic --no-keep-memory -nostdlib -oformat=pei-x86-64 uefimain.o uefi.o tydqfs.o system.o -e efi_main -o main.dll
	objcopy -I pei-x86-64 -O efi-app-x86_64 main.dll kernel/bootx64.efi
	dd if=/dev/zero of=fat.img bs=512 count=131072
	/usr/sbin/mkfs.vfat -F 32 fat.img
	mmd -i fat.img ::/EFI
	mmd -i fat.img ::/EFI/BOOT
	mmd -i fat.img ::/EFI/SETUP
	mcopy -i fat.img installer/bootx64.efi ::/EFI/BOOT
	mcopy -i fat.img kernel/bootx64.efi ::/EFI/SETUP
	mkdir iso
	cp fat.img iso
	xorriso -as mkisofs -R -f -e fat.img -no-emul-boot -o cdimage.iso iso
	rm -rf iso
	rm -rf *.ppu
	rm -rf fat.img
	rm -rf *.o
	rm -rf installer
	rm -rf kernel
	rm -rf *.dll
