#!/bin/bash

# Arch Linux Fast Install - Быстрая установка Arch Linux https://github.com/ordanax/arch2018
# Цель скрипта - быстрое развертывание системы с вашими персональными настройками (конфиг XFCE, темы, программы и т.д.).

# Автор скрипта Алексей Бойко https://vk.com/ordanax


loadkeys en
setfont cyr-sun16
echo 'Скрипт сделан на основе чеклиста Бойко Алексея по Установке ArchLinux'
echo 'Ссылка на чек лист есть в группе vk.com/arch4u'

echo '2.3 Синхронизация системных часов'
timedatectl set-ntp true

echo '2.4 создание разделов'
(
 echo g;

 echo n;
 echo ;
 echo;
 echo +512M;
 echo y;
 echo t;
 echo 1;

 echo n;
 echo;
 echo;
 echo +12G;
 echo y;
 
  
 echo n;
 echo;
 echo;
 echo;
 echo y;
  
 echo w;
) | fdisk /dev/sda

echo 'Ваша разметка диска'
fdisk -l

echo '2.4.2 Форматирование дисков'

mkfs.fat -F32 -n "EFI" /dev/sda1
mkswap -L "swap" /dev/sda2
swapon /dev/sda2
mkfs.btrfs -L "Arch Linux" /dev/sda3

echo '2.4.3 Монтирование дисков'

mount /dev/sda3 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@var
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
umount /mnt
mount -t btrfs -o autodefrag,noatime,nossd,compress=lzo,space_cache,subvol=@ /dev/sda3 /mnt
mkdir -p /mnt/{boot/efi,var,home,.snapshots}
mount /dev/sda1 /mnt/boot/efi
mount -t btrfs -o autodefrag,noatime,nossd,compress=lzo,space_cache,subvol=@var /dev/sda3 /mnt/var
mount -t btrfs -o autodefrag,noatime,nossd,compress=lzo,space_cache,subvol=@home /dev/sda3 /mnt/home
mount -t btrfs -o autodefrag,noatime,nossd,compress=lzo,space_cache,subvol=@snapshots /dev/sda3 /mnt/.snapshots

echo '3.1 Выбор зеркал для загрузки.'

rm -rf /etc/pacman.d/mirrorlist
wget https://github.com/le0me55i/arch/raw/master/attach/mirrorlist
mv -f ~/mirrorlist /etc/pacman.d/mirrorlist

echo '3.2 Установка основных пакетов'
pacstrap /mnt base base-devel linux-zen linux-firmware nano dhcpcd netctl zsh zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting git ccache btrfs-progs terminus-font

echo '3.3 Настройка системы'
genfstab -pU /mnt >> /mnt/etc/fstab
nano /mnt/etc/fstab
arch-chroot /mnt sh -c "$(curl -fsSL https://github.com/le0me55i/arch/raw/master/archuefi2.sh)"
