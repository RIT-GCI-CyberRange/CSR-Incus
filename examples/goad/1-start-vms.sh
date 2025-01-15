incus rm --force dc01 dc02 dc03 srv01 srv02 srv03 kali01
incus rm --force deployment
incus network rm goad
incus network create goad \
  network=UPLINK \
  ipv4.address=192.168.56.1/24 \
  ipv4.nat=true \
  ipv6.address=none \
  ipv6.nat=none

#DC02 with 8 cores and 16GB of ram
incus init oszoo:winsrv/2019/ansible-cloud \
  dc02 \
  --vm \
  -t c8-m16 \
  --network goad \
  -d eth0,ipv4.address=192.168.56.11 \
  -d root,size=120GiB

#srv01 with 8 cores and 16GB of ram
incus init oszoo:winsrv/2019/ansible-cloud \
  srv02 \
  --vm \
  -t c8-m16 \
  --network goad \
  -d eth0,ipv4.address=192.168.56.22 \
  -d root,size=120GiB

#DC01 with 8 cores and 16GB of ram
incus init oszoo:winsrv/2019/ansible-cloud \
  dc01 \
  --vm \
  -t c8-m16 \
  --network goad \
  -d eth0,ipv4.address=192.168.56.10 \
  -d root,size=120GiB

#DC03 with 8 cores and 16GB of ram
incus init oszoo:winsrv/2016/ansible-cloud \
  dc03 \
  --vm \
  -t c8-m16 \
  --network goad \
  -d eth0,ipv4.address=192.168.56.12 \
  -d root,size=120GiB

#srv03 with 8 cores and 16GB of ram
incus init oszoo:winsrv/2016/ansible-cloud \
  srv03 \
  --vm \
  -t c8-m16 \
  --network goad \
  -d eth0,ipv4.address=192.168.56.23 \
  -d root,size=120GiB

#srv01 with 8 cores and 16GB of ram
incus init oszoo:winsrv/2019/ansible-cloud \
  srv01 \
  --vm \
  -t c8-m16 \
  --network goad \
  -d eth0,ipv4.address=192.168.56.21 \
  -d root,size=320GiB

incus init images:kali \
  kali01 \
  -t c8-m16 \
  --network goad \
  -d eth0,ipv4.address=192.168.56.200 \
  -d root,size=320GiB
incus start dc01 dc02 dc03 srv01 srv02 srv03 kali01

#install kali with tools and ssh
incus exec kali01 -- /bin/bash -c  "apt update"
incus exec kali01 -- /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install -y kali-linux-default openssh-server'
incus exec kali01 -- bash -c "useradd -m -s /bin/bash 'kali'"
incus exec kali01 -- usermod -aG sudo kali
incus exec kali01 -- sed -i '1 i\TERM=xterm-256color' /home/kali/.bashrc
incus exec kali01 -- sh -c "echo 'Set disable_coredump false' > /etc/sudo.conf"
incus exec kali01 -- bash -c "sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config"
incus exec kali01 -- bash -c "sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config"
incus exec kali01 -- bash -c "systemctl restart ssh"
incus exec kali01 -- bash -c "systemctl enable --now ssh"
echo "Ready to start GOAD Ansible!"
