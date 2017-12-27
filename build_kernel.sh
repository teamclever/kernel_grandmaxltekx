#!/bin/bash

export ARCH=arm
export CROSS_COMPILE=$(pwd)/arm-eabi-4.8/bin/arm-eabi-

# Check output directory
if [ ! -d "output" ] 
then
    mkdir output
fi

echo "Start build..."
make -C $(pwd) O=output msm8916_sec_defconfig VARIANT_DEFCONFIG=msm8916_sec_grandmax_koropen_defconfig SELINUX_DEFCONFIG=selinux_defconfig
make -C $(pwd) O=output

echo "Strip Prima wlan drivers..."
./arm-eabi-4.8/bin/arm-eabi-strip --strip-unneeded $(pwd)/output/drivers/staging/prima/wlan.ko
cp output/drivers/staging/prima/wlan.ko utilities/zip/system/lib/modules/pronto/pronto_wlan.ko
echo "Finish"

echo "Repack bootimg..."
./utilities/repack/mkbootimg --cmdline "console=null androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x3F ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci" --base 0x80000000 --pagesize 2048 --kernel output/arch/arm/boot/zImage --ramdisk utilities/repack/boot.img-ramdisk.gz --dt utilities/repack/boot.img-dtb -o utilities/zip/boot.img
echo "Finish"

echo "Make flashable zip..."
zip -r9 Clever-Kernel-grandmaxltekx.zip utilities/zip/META-INF utilities/zip/system utilities/zip/boot.img
echo "Finish"
