#!/bin/bash
# ������Դ��tuanqingһ��n1/�����Ƶ�һ���ű� (gayhub��ַ��https://github.com/tuanqing/mknop)��Ϊ�˼�ȥ�������н�����ֱ����Ĭ��ֵ
red="\033[31m"
green="\033[32m"
white="\033[0m"

out_dir=out
openwrt_dir=openwrt
boot_dir="/media/boot"
rootfs_dir="/media/rootfs"
device=""
loop=


# �����ع�Ŀ¼
if [ -d $out_dir ]; then
    sudo rm -rf $out_dir
fi

mkdir -p $out_dir/openwrt
sudo mkdir -p $rootfs_dir

# ��ѹopenwrt�̼�
cd $openwrt_dir
if [ -f *ext4-factory.img.gz ]; then
    gzip -d *ext4-factory.img.gz
elif [ -f *root.ext4.gz ]; then
    gzip -d *root.ext4.gz
elif [ -f *rootfs.tar.gz ] || [ -f *ext4-factory.img ] || [ -f *root.ext4 ]; then
    [ ]
else
    echo -e "$red \n openwrtĿ¼�²����ڹ̼���̼����Ͳ���֧��! $white" && exit
fi

# ����openwrt�̼�
if [ -f *rootfs.tar.gz ]; then
    sudo tar -xzf *rootfs.tar.gz -C ../$out_dir/openwrt
elif [ -f *ext4-factory.img ]; then
    loop=$(sudo losetup -P -f --show *ext4-factory.img)
    if ! sudo mount -o rw ${loop}p2 $rootfs_dir; then
        echo -e "$red \n ����OpenWrt����ʧ��! $white" && exit
    fi
elif [ -f *root.ext4 ]; then
    sudo mount -o loop *root.ext4 $rootfs_dir
fi

# ����openwrt rootfs
echo -e "$green \n ��ȡOpenWrt ROOTFS... $white"
cd ../$out_dir
if df -h | grep $rootfs_dir > /dev/null 2>&1; then
    sudo cp -r $rootfs_dir/* openwrt/ && sync
    sudo umount $rootfs_dir
    [ $loop ] && sudo losetup -d $loop
fi

sudo cp -r ../armbian/$device/rootfs/* openwrt/ && sync
sudo chown -R root:root openwrt/

# ��������������
rootfssize=512

openwrtsize=$(sudo du -hs openwrt | cut -d "M" -f 1)
[ $rootfssize -lt $openwrtsize ] &&
    echo -e "$red \n ROOTFS����������Ҫ $openwrtsize M! $white" &&
    exit

echo -e "$green \n ���ɿվ���(.img)... $white"
fallocate -l $(($rootfssize + 145))M "$(date +%Y-%m-%d)-openwrt-${device}-auto-generate.img"

echo -e "$green \n ����... $white"
parted -s *.img mklabel msdos
parted -s *.img mkpart primary ext4 17M 151M
parted -s *.img mkpart primary ext4 152M 100%

# ��ʽ������
echo -e "$green \n ��ʽ��... $white"
loop=$(sudo losetup -P -f --show *.img)
[ ! $loop ] &&
    echo -e "$red \n ��ʽ��ʧ��! $white" &&
    exit

mkfs.vfat -n "BOOT" ${loop}p1 > /dev/null 2>&1
sudo mke2fs -F -q -t ext4 -L "ROOTFS" -m 0 ${loop}p2 > /dev/null 2>&1

# ���ط���
sudo mkdir -p $boot_dir
sudo mount -o rw ${loop}p1 $boot_dir
sudo mount -o rw ${loop}p2 $rootfs_dir

# �����ļ�����������
cd ../
echo -e "$green \n �����ļ�����������... $white"
sudo cp -r armbian/$device/boot/* $boot_dir
sudo mv $out_dir/openwrt/* $rootfs_dir
sync

# ȡ����������
if df -h | grep $boot_dir > /dev/null 2>&1; then
    sudo umount $boot_dir
fi

if df -h | grep $rootfs_dir > /dev/null 2>&1; then
    sudo umount $rootfs_dir
fi

[ $loop ] && sudo losetup -d $loop

# �������
sudo rm -rf $boot_dir
sudo rm -rf $rootfs_dir
sudo rm -rf $out_dir/openwrt

# ���idb��ʶ�Լ�uboot
if [ $device = "beikeyun" ]; then
    img=$(ls -l $out_dir | grep img | awk '{ print $9 }')
    echo -e "$green \n д��idb... $white"
    dd if=armbian/beikeyun/loader/idbloader.img of=$out_dir/$img bs=16 seek=2048 conv=notrunc > /dev/null 2>&1
    echo -e "$green \n д��uboot... $white"
    dd if=armbian/beikeyun/loader/uboot.img of=$out_dir/$img bs=16 seek=524288 conv=notrunc > /dev/null 2>&1
fi

echo -e "$green \n �����ɹ�, ����ļ��� --> $out_dir $white"
