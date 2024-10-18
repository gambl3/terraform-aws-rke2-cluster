#!/bin/bash

# Set Variables
export DOMAIN=${DOMAIN}
export TOKEN=${TOKEN}
export vRKE2=${vRKE2}

# Apply System Settings
cat << EOF >> /etc/sysctl.conf
# Modified System Settings
vm.swappiness=0
vm.panic_on_oom=0
vm.overcommit_memory=1
kernel.panic=10
kernel.panic_on_oops=1
vm.max_map_count = 262144
net.ipv4.ip_local_port_range=1024 65000
net.core.somaxconn=10000
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=15
net.core.somaxconn=4096
net.core.netdev_max_backlog=4096
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_max_syn_backlog=20480
net.ipv4.tcp_max_tw_buckets=400000
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_syn_retries=2
net.ipv4.tcp_synack_retries=2
net.ipv4.tcp_wmem=4096 65536 16777216
net.ipv4.neigh.default.gc_thresh1=8096
net.ipv4.neigh.default.gc_thresh2=12288
net.ipv4.neigh.default.gc_thresh3=16384
net.ipv4.tcp_keepalive_time=600
net.ipv4.ip_forward=1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
EOF
sysctl -p > /dev/null 2>&1

# Install Packages
sudo yum install -y iptables container-selinux libnetfilter_conntrack libnfnetlink libnftnl policycoreutils-python-utils cryptsetup
sudo yum install -y nfs-utils iscsi-initiator-utils
sudo yum install -y zip zstd tree jq

# Install Cosign
mkdir -p /opt/rancher/cosign
cd /opt/rancher/cosign
curl -#OL https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
mv cosign-linux-amd64 /usr/bin/cosign
chmod 755 /usr/bin/cosign

# Install Helm
mkdir -p /opt/rancher/helm
cd /opt/rancher/helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 755 get_helm.sh && ./get_helm.sh
mv /usr/local/bin/helm /usr/bin/helm

# Configure RKE2 Config
cat << EOF >> /etc/rancher/rke2/config.yaml
token: $TOKEN
tls-san:
  - $DOMAIN
  - 127.0.0.1
EOF

# Download and Install RKE2 Server
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=$vRKE2 INSTALL_RKE2_TYPE=server sh -

# Enable and Start RKE2 Server
systemctl enable rke2-server.service && systemctl start rke2-server.service

# Symlink kubectl and containerd
sudo curl -L -o /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Update and Source BASHRC
cat << EOF >> ~/.bashrc
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
export DOMAIN=${DOMAIN}
export TOKEN=${TOKEN}
export vRKE2=${vRKE2}
alias k=kubectl
EOF

# Source BASHRC
source ~/.bashrc

# Verify End of Script
date >> /opt/rancher/COMPLETED
