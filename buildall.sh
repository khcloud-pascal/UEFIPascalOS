	mkdir installer
	mkdir kernel
	/home/tydq/source/compiler/ppc1 -Aas -n -O1 -Si -Sc -Sg -Xd -Us -CX -XXs -Px86_64 -Rintel -Cg system.pas
	/home/tydq/source/compiler/ppc1 -Aas -n -O1 -Si -Sc -Sg -Xd -CX -XXs -Px86_64 -Rintel -Cg uefiinstaller.pas 
        /home/tydq/source/compiler/ppc1 -Aas -n -O1 -Si -Sc -Sg -Xd -CX -XXs -Px86_64 -Rintel -Cg uefimain.pas 
	ld --gc-sections -nostdlib -znocombreloc -shared -Bsymbolic --no-keep-memory uefiinstaller.o uefi.o tydqfs.o system.o -e efi_main -o installer.so
	objcopy -O efi-app-x86_64 installer.so installer/bootx64.efi
	ld --gc-sections -nostdlib -znocombreloc -shared -Bsymbolic --no-keep-memory uefimain.o uefi.o tydqfs.o system.o -e efi_main -o main.so
	objcopy -O efi-app-x86_64 main.so kernel/bootx64.efi
	rm *.o 
	rm *.ppu
	rm *.so
	/home/tydq/source/compiler/ppcrossa64 -XPaarch64-linux-gnu- -Aas -n -O1 -Si -Sc -Sg -Xd -Us -CX -XXs -Cg -Tlinux system.pas
	/home/tydq/source/compiler/ppcrossa64 -XPaarch64-linux-gnu- -Aas -n -O1 -Si -Sc -Sg -Xd -CX -XXs -Cg -Tlinux uefiinstaller.pas 
        /home/tydq/source/compiler/ppcrossa64 -XPaarch64-linux-gnu- -Aas -n -O1 -Si -Sc -Sg -Xd -CX -XXs -Cg -Tlinux uefimain.pas 
	aarch64-linux-gnu-ld --gc-sections -nostdlib -znocombreloc -shared -Bsymbolic --no-keep-memory uefiinstaller.o uefi.o tydqfs.o system.o -e efi_main -o installer.so
	aarch64-linux-gnu-objcopy -O efi-app-aarch64 installer.so installer/bootaa64.efi
	aarch64-linux-gnu-ld --gc-sections -nostdlib -znocombreloc -shared -Bsymbolic --no-keep-memory uefimain.o uefi.o tydqfs.o system.o -e efi_main -o main.so
	aarch64-linux-gnu-objcopy -O efi-app-aarch64 main.so kernel/bootaa64.efi
	rm *.o 
	rm *.ppu
	rm *.so
	/home/tydq/source/compiler/ppcrossloongarch64 -n -O- -Si -Sc -Sg -Xd -Us -CX -XXs -Cg system.pas
	/home/tydq/source/compiler/ppcrossloongarch64 -n -O- -Si -Sc -Sg -Xd -CX -XXs -Cg uefiinstaller.pas 
        /home/tydq/source/compiler/ppcrossloongarch64 -n -O- -Si -Sc -Sg -Xd -CX -XXs -Cg uefimain.pas 
	loongarch64-linux-gnu-ld --gc-sections -nostdlib -znocombreloc -shared -Bsymbolic --no-keep-memory uefiinstaller.o uefi.o tydqfs.o system.o -e efi_main -o installer.so
	loongarch64-linux-gnu-objcopy -O efi-app-aarch64 installer.so installer/bootloongarch.efi
	loongarch64-linux-gnu-ld --gc-sections -nostdlib -znocombreloc -shared -Bsymbolic --no-keep-memory uefimain.o uefi.o tydqfs.o system.o -e efi_main -o main.so
	loongarch64-linux-gnu-objcopy -O efi-app-aarch64 main.so kernel/bootloongarch.efi
	rm *.o 
	rm *.ppu
	rm *.so
	dd if=/dev/zero of=fat.img bs=512 count=131072
	/usr/sbin/mkfs.vfat -F 32 fat.img
	mmd -i fat.img ::
	mmd -i fat.img ::/EFI
	mmd -i fat.img ::/EFI/BOOT
	mmd -i fat.img ::/EFI/SETUP
	mcopy -i fat.img installer/*.efi ::/EFI/BOOT
	mcopy -i fat.img kernel/*.efi ::/EFI/SETUP
	mkdir iso
	cp fat.img iso
	xorriso -as mkisofs -R -f -e fat.img -no-emul-boot -o TestOS.iso iso
	rm -rf iso
	rm -rf fat.img
	rm -rf installer
	rm -rf kernel
	rm -rf *.so
