git clone https://kernel.googlesource.com/pub/scm/linux/kernel/git/firmware/linux-firmware
sudo cp -v linux-firmware/amdgpu/* /lib/firmware/amdgpu/
sudo update-initramfs -u -k all
