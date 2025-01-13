#!/bin/bash
incus rm --force deployment
incus init images:ubuntu/noble \
  deployment \
  -t c8-m16 \
  --network goad \
  -d eth0,ipv4.address=192.168.56.210 \
  -d root,size=320GiB
incus start deployment
sleep 5
incus exec deployment -- /bin/bash -c 'apt update'
incus exec deployment -- /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install -y git curl build-ess* python3-venv python3-dev'
incus exec deployment -- /bin/bash -c 'cd /root && git clone https://github.com/Orange-Cyberdefense/GOAD.git'
#change out the username for logging into windows
incus exec deployment -- /bin/bash -c "sed -i 's/force_dns_server=no/force_dns_server=no/g' /root/GOAD/ad/GOAD/data/inventory"
incus exec deployment -- /bin/bash -c "sed -i 's/ansible_user=vagrant/ansible_user=ansible/g; s/ansible_password=vagrant/ansible_password=ansible/g' /root/GOAD/ad/GOAD/data/inventory"
incus exec deployment -- /bin/bash -c "sed -i '/name: \"Force a DNS on the adapter {{nat_adapter}}\"/,/when: force_dns_server == \"yes\"/d' /root/GOAD/ansible/roles/common/tasks/main.yml"
echo Restarting windows VMs
incus restart dc01 dc02 dc03 srv01 srv02 srv03
echo Starting Deployment
incus exec deployment -- /bin/bash -c 'cd /root/GOAD && /root/GOAD/goad.sh -t check -l GOAD -p proxmox' || true
incus exec deployment -- /bin/bash -c 'cd /root/GOAD && yes | /root/GOAD/goad.sh -t install -l GOAD -p proxmox -e exchange' || true
token=$(incus exec deployment -- /bin/bash -c 'cd /root/GOAD/workspace && ls -b -1 | head -n1')
incus exec deployment -- /bin/bash -c "cd /root/GOAD && /root/GOAD/goad.sh -t install -l GOAD -p proxmox -e exchange -a true -i $token"
