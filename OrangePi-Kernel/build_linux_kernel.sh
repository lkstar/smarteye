#!/bin/bash

# === USAGE ===========================================
# build_linux_kernel <board> [clean]
# <board> = 2         ->  build for OPI-2/OPI-PC
# <board> = plus      ->  build for OPI-PLUS
# <board> = lite      ->  build for OPI-LITE
# <board> = one       ->  build for OPI-ONE
# <board> = pc plus   ->  build for OPI-PC PLUS
# <board> = plus 2e   ->  build for OPI-PLUS 2E
# <board> = all       ->  build for OPI-2/OPI-PC & OPI-PLUS
# <board> = clean     ->  clean all
# if 2nd parameter is clean, cleans all before build
# =====================================================
# After build uImage and lib are in build directory
# =====================================================


export PATH="$PWD/brandy/gcc-linaro/bin":"$PATH"
cross_comp="arm-linux-gnueabi"

# ##############
# Prepare rootfs
# ##############

cd build

rm rootfs-lobo.img.gz | tee /dev/null 2>&1

# create new rootfs cpio
cd rootfs-test1
mkdir run | tee /dev/null 2>&1
mkdir -p conf/conf.d | tee /dev/null 2>&1

find . | cpio --quiet -o -H newc > ../rootfs-lobo.img
cd ..
gzip rootfs-lobo.img
cd ..
#=========================================================

cd linux-3.4.112
LINKERNEL_DIR=`pwd`

# build rootfs
rm -rf output/* | tee /dev/null 2>&1
mkdir -p output/lib | tee /dev/null 2>&1
cp ../build/rootfs-lobo.img.gz output/rootfs.cpio.gz

#==================================================================================
make_kernel() {
    # ############
    # Build kernel
    # ############

    # #################################
    # change some board dependant files
    if [ "${1}" = "plus" ]; then
           cp ../build/Kconfig.piplus drivers/net/ethernet/sunxi/eth/Kconfig
           cp ../build/sunxi_geth.c.piplus drivers/net/ethernet/sunxi/eth/sunxi_geth.c
    else
           cp ../build/Kconfig.pi2 drivers/net/ethernet/sunxi/eth/Kconfig
           cp ../build/sunxi_geth.c.pi2 drivers/net/ethernet/sunxi/eth/sunxi_geth.c
           cp ../build/sun8iw7p1smp_lobo_defconfig arch/arm/configs/sun8iw7p1smp_lobo_defconfig
    fi

    # ###########################
    if [ "${2}" = "clean" ]; then
            make ARCH=arm CROSS_COMPILE=${cross_comp}- mrproper | tee /dev/null 2>&1
    fi
    sleep 1

    echo "Building kernel for OPI-${1} (${2}) ..."
    echo "  Configuring ..."
    make ARCH=arm CROSS_COMPILE=${cross_comp}- sun8iw7p1smp_lobo_defconfig | tee ../kbuild_${1}_${2}.log 2>&1
    if [ $? -ne 0 ]; then
        echo "  Error: KERNEL NOT BUILT."
        exit 1
    fi
    sleep 1

    # #############################################################################
    # build kernel (use -jN, where N is number of cores you can spare for building)
    echo "  Building kernel & modules ..."
    make -j6 ARCH=arm CROSS_COMPILE=${cross_comp}- uImage modules | tee -a ../kbuild_${1}_${2}.log 2>&1
    if [ $? -ne 0 ] || [ ! -f arch/arm/boot/uImage ]; then
        echo "  Error: KERNEL NOT BUILT."
        exit 1
    fi
    sleep 1

    # ########################
    # export modules to output
    echo "  Exporting modules ..."
    rm -rf output/lib/*
    make ARCH=arm CROSS_COMPILE=${cross_comp}- INSTALL_MOD_PATH=output modules_install | tee -a ../kbuild_${1}_${2}.log 2>&1
    if [ $? -ne 0 ] || [ ! -f arch/arm/boot/uImage ]; then
        echo "  Error."
    fi
    echo "  Exporting firmware ..."
    make ARCH=arm CROSS_COMPILE=${cross_comp}- INSTALL_MOD_PATH=output firmware_install | tee -a ../kbuild_${1}_${2}.log 2>&1
    if [ $? -ne 0 ] || [ ! -f arch/arm/boot/uImage ]; then
        echo "  Error."
    fi
    sleep 1

    # #####################
    # Copy uImage to output
    cp arch/arm/boot/uImage output/uImage
    if [ "${1}" = "plus" ]; then
        cd ..
        ./build_mali_driver.sh
        cd $LINKERNEL_DIR
        cp arch/arm/boot/uImage ../build/uImage_OPI-PLUS
        [ ! -d ../build/lib ] && mkdir ../build/lib
        rm -rf ../build/lib/*
        cp -R output/lib/* ../build/lib
        
    else
        cd ..
        ./build_mali_driver.sh
        cd $LINKERNEL_DIR
        cp arch/arm/boot/uImage ../build/uImage_OPI-2
        [ ! -d ../build/lib ] && mkdir ../build/lib
        rm -rf ../build/lib/*
        cp -R output/lib/* ../build/lib
    fi

	rm -rf ../../OrangePi-BuildLinux/orange/lib/* 
	cp -rf ../build/lib/* ../../OrangePi-BuildLinux/orange/lib/
}
#==================================================================================


if [ "${1}" = "clean" ]; then
    echo "Cleaning..."
    make ARCH=arm CROSS_COMPILE=${cross_comp}- mrproper | tee /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "  Error."
    fi
    rm -rf ../build/lib/* | tee /dev/null 2>&1
    rm -f ../build/uImage* | tee /dev/null 2>&1
    rm -f ../kbuild* | tee /dev/null 2>&1
    rm -f ../malibuild* | tee /dev/null 2>&1
    rm if ../linux-3.4/modules/malibuild* | tee /dev/null 2>&1
    rmdir ../build/lib | tee /dev/null 2>&1
    rm ../build/rootfs-lobo.img.gz | tee /dev/null 2>&1
    rm -rf output/* | tee /dev/null 2>&1
elif [ "${1}" = "all" ]; then
    make_kernel "2" "${2}"
    make_kernel "plus" "${2}"
elif [ "${1}" = "" ]; then
    make_kernel "2"
else
    make_kernel "${1}" "${2}"
fi


echo "***OK***"
