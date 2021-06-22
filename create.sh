# http://d.sunnyone.org/2020/06/virt-install-cloud-initubuntu-2004.html
# 以下を修正
# sudo lvcreate -n cloudtest-root -L 8G vg0
# sudo qemu-img convert ubuntu-20.04-server-cloudimg-amd64.img -O raw root.img
# convertするとconvertした方で既存のディスクが置き換えられてしまう為、容量がおかしくなってしまう。
# その為、一度作ってからリサイズした方が良さそう。
virsh destroy k8s_master
virsh undefine k8s_master

sudo mkdir 
sudo qemu-img create -f raw root.img 5G  # 仮想ディスクの作成
sudo qemu-img convert ubuntu-20.04-server-cloudimg-amd64.img -O raw root.img
sudo qemu-img resize -f raw root.img 5G
sudo cloud-localds --network-config 10-network-config.yaml user-data.img user-data

sudo virt-install \
    --name k8s_master --ram 4096 --arch x86_64 --vcpus 2 \
    --os-type linux --os-variant ubuntu20.04 \
    --disk path=/root.img,size=5,format=raw \
    --disk path=$PWD/user-data.img,device=cdrom \
    --network bridge=br0,model=virtio \
    --virt-type kvm \
    --graphics none \
    --import
