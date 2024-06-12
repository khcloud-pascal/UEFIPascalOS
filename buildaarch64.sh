	mkdir kernel
        mkdir installer
        /home/tydq/source/compiler/ppca64 -n -O4 -Si -Sc -Sg -Xd -Ur -Us -CX -XXs -Cg -Twin64 system.pas
	/home/tydq/source/compiler/ppca64 -n -O4 -Si -Sc -Sg -Xd -Ur -CX -XXs -Cg -Twin64 fpintres.pas
	/home/tydq/source/compiler/ppca64 -n -O4 -Si -Sc -Sg -Xd -Ur -CX -XXs -Cg -Twin64 sysinit.pas
	/home/tydq/source/compiler/ppca64 -n -O4 -Si -Sc -Sg -Xd -Ur -CX -XXs -Xi -Cg -Twin64 uefiinstaller.pas
	/home/tydq/source/compiler/ppca64 -n -O4 -Si -Sc -Sg -Xd -Ur -CX -XXs -Xi -Cg -Twin64 uefimain.pas
	objcopy -O efi-app-aarch64 uefiinstaller.dll installer/bootaa64.efi
	objcopy -O efi-app-aarch64 uefimain.dll kernel/bootaa64.efi
	rm -rf *.o
	rm -rf *.ppu
	rm -rf *.dll
	dd if=/dev/zero of=fat.img bs=512 count=131072
	/usr/sbin/mkfs.vfat -F 32 fat.img
	mmd -i fat.img ::/EFI
	mmd -i fat.img ::/EFI/BOOT
	mmd -i fat.img ::/EFI/SETUP
	mcopy -i fat.img installer/*.efi ::/EFI/BOOT
	mcopy -i fat.img kernel/*.efi ::/EFI/SETUP
	mkdir iso
	cp fat.img iso
	xorriso -as mkisofs -R -f -e fat.img -no-emul-boot -o cdimageaarch64.iso iso
	rm -rf iso
	rm -rf *.ppu
	rm -rf fat.img
	rm -rf *.o
	rm -rf installer
	rm -rf kernel
	rm -rf *.dll
	rm -rf *.s
        rm -rf *.res
