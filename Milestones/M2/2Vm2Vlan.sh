#!/bin/bash
#set -e



sudo ovs-vsctl add-br br0

cat > /etc/lxc/lxc-ovs.conf << EOF
lxc.network.type=veth
lxc.network.script.up=/etc/lxc/ovsup
lxc.network.ipv4=192.168.100.100
lxc.network.flags=up
EOF

cat > /etc/lxc/lxc-ovs.conf2 << EOF
lxc.network.type=veth
lxc.network.script.up=/etc/lxc/ovsup2
lxc.network.ipv4=192.168.100.101
lxc.network.flags=up
EOF

#Ici on crée deux vlans avec comme tag 1 et 2 

cat > /etc/lxc/ovsup << EOF
#!/bin/bash

ifconfig \$5 0.0.0.0 up
ovs-vsctl add-port br0 \$5 tag=1
EOF
chmod ugo+x /etc/lxc/ovsup

cat > /etc/lxc/ovsup2 << EOF
#!/bin/bash

ifconfig \$5 0.0.0.0 up
ovs-vsctl add-port br0 \$5 tag=2
EOF
chmod ugo+x /etc/lxc/ovsup2

lxc-create -t ubuntu -n p1 -f /etc/lxc/lxc-ovs.conf
lxc-create -t ubuntu -n p2 -f /etc/lxc/lxc-ovs.conf2


