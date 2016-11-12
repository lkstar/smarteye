#init config for build 
sudo apt-get update sudo apt-get upgrade
sudo apt-get install build-essential u-boot-tools binutils-arm-linux-gnueabihf gcc-4.7-arm-linux-gnueabihf-base g++-4.7-arm-linux-gnueabihf gcc-arm-linux-gnueabihf cpp-arm-linux-gnueabihf libusb-1.0-0 libusb-1.0-0-dev git wget fakeroot kernel-package zlib1g-dev libncurses5-dev pkg-config


#The OrangePi-Kernel contains Linux kernel sources (3.4.112) adapted for OrangePI H3 boards, gcc toolchain
#The script "build_linux_kernel.sh" can be used to build the kernel


##Example1(how to make uImage)：
#$ cd OrangePI-Kernel
##cleans the kernel tree before build
#$ sudo ./build_linux_kernel.sh clean clean   
##builds the uImage for OPI-PLUS(only two uImage,just plus,pi2),plus,plus2,plus2E use same uIamge,others use pi2 uImage
#clean as 1st parameter cleans the kernel tree and build directories
#clean as 2nd parameter cleans the kernel tree before build
#all builds the uImage for OPI-2 & OPI-PLUS
#2 builds the uImage for OPI-2 OPI-PCPLUS OPI-ONE OPI-PC
#plus builds the uImage for OPI-PLUS OPI-PLUS2E                    
#$ sudo ./build_linux_kernel.sh 2                              
#$ cd ../OrangePi-BuildLinux  
##build file system
#$ sudo ./create_image    
##build plus image                                        
#$ sudo ./image_from_dir ./linux-trusty orangepi ext4 opi-plus    
#$ sudo dd bs=4M if=orangepi.img of=/dev/sd*                  
##Read and edit "params.sh" to adjust the parameters to your needs


##Example2(configure desktop)
##After BOOTING,to resize linux partition to fill sd card
#$ fs_resize
#$ reboot
##to install desktop run,please wait at least one hours
#$ install_lxde_desktop  
#$ reboot
#*****************************************************          
##Install software what your needs(just like follows)


##Install commom software 
#$ sudo install_common_software
##Language from english to chinese
#$ sudo install_hanhua
##install mali，use glmark2-es2 test
#$ sudo install_maliGPU
##install pepperflash
#$ sudo install_pepperflash
##install samba
#$ sudo install_samba
##install x2go
#$ sudo install_x2goserver
##install vnc
#$ sudo install_vnc
##install bypy(you can upload to baiduyun)
#$ sudo install_bypy
##install btsync
#$ sudo install_btsync
##install ibus chinese input method
#$ sudo install_ibus_shuru
##install the camera driver, can be used to provide the official website of the camera
#$ sudo install_camera_ko
