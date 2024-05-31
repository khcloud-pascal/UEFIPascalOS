	mkdir installer
	mkdir kernel
	/home/tydq/source/compiler/ppcx64 -n -O1 -Si -Sc -Sg -Xd -Ur -Us -CX -XXs -Rintel -Twin64 -Cg system.pas
	/home/tydq/source/compiler/ppcx64 -n -O1 -Si -Sc -Sg -Xd -Ur -CX -XXs -Rintel -Twin64 -Cg fpintres.pas
	/home/tydq/source/compiler/ppcx64 -n -O1 -Si -Sc -Sg -Xd -Ur -CX -XXs -Rintel -Twin64 -Cg sysinit.pas
	/home/tydq/source/compiler/ppcx64 -n -O1 -Si -Sc -Sg -Xd -Ur -CX -XXs -Xi -Rintel -Twin64 -Cg uefiinstaller.pas
	/home/tydq/source/compiler/ppcx64 -n -O1 -Si -Sc -Sg -Xd -Ur -CX -XXs -Xi -Rintel -Twin64 -Cg uefimain.pas
	objcopy -I pei-x86-64 -O efi-app-x86_64 uefiinstaller.dll installer/bootx64.efi
	objcopy -I pei-x86-64 -O efi-app-x86_64 uefimain.dll kernel/bootx64.efi
	rm -rf *.o
	rm -rf *.ppu
	rm -rf *.dll
	/home/tydq/source/compiler/ppca64 -n -O1 -Si -Sc -Sg -Xd -Ur -Us -CX -XXs -Cg system.pas
	/home/tydq/source/compiler/ppca64 -n -O1 -Si -Sc -Sg -Xd -Ur -CX -XXs -Cg fpintres.pas
	/home/tydq/source/compiler/ppca64 -n -O1 -Si -Sc -Sg -Xd -Ur -CX -XXs -Cg sysinit.pas
	/home/tydq/source/compiler/ppca64 -n -O1 -Si -Sc -Sg -Xd -Ur -CX -XXs -Xi -Cg uefiinstaller.pas
	/home/tydq/source/compiler/ppca64 -n -O1 -Si -Sc -Sg -Xd -Ur -CX -XXs -Xi -Cg uefimain.pas
	loongarch64-linux-gnu-objcopy -O efi-app-aarch64 libuefiinstaller.so installer/bootloongarch.efi
	loongarch64-linux-gnu-objcopy -O efi-app-aarch64 libuefimain.so kernel/bootloongarch.efi
	rm -rf *.o
	rm -rf *.ppu
	rm -rf *.dll
	/home/tydq/source/compiler/ppcloongarch64 -n -O1 -Si -Sc -Sg -Xd -Ur -Us -CX -XXs -Cg system.pas
	/home/tydq/source/compiler/ppcloongarch64 -n -O1 -Si -Sc -Sg -Xd -Ur -CX -XXs -Cg fpintres.pas
	/home/tydq/source/compiler/ppcloongarch64 -n -O1 -Si -Sc -Sg -Xd -Ur -CX -XXs -Cg sysinit.pas
	/home/tydq/source/compiler/ppcloongarch64 -n -O1 -Si -Sc -Sg -Xd -Ur -CX -XXs -Xi -Cg uefiinstaller.pas
	/home/tydq/source/compiler/ppcloongarch64 -n -O1 -Si -Sc -Sg -Xd -Ur -CX -XXs -Xi -Cg uefimain.pas
	loongarch64-linux-gnu-objcopy -O efi-app-loongarch64 libuefiinstaller.so installer/bootloongarch.efi
	loongarch64-linux-gnu-objcopy -O efi-app-loongarch64 libuefimain.so kernel/bootloongarch.efi
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
	xorriso -as mkisofs -R -f -e fat.img -no-emul-boot -o cdimage.iso iso
	rm -rf iso
	rm -rf *.ppu
	rm -rf fat.img
	rm -rf *.o
	rm -rf installer
	rm -rf kernel
	rm -rf *.dll
	rm -rf *.s
