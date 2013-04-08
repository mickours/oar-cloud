#!/bin/bash
#set -e


# ajout d'un switch virtuel
sudo ovs-vsctl add-br br0

#creation du fichier d'installation du la vm p1
cat > /etc/lxc/lxc-ovs.conf << EOF
lxc.network.type=veth
lxc.network.script.up=/etc/lxc/ovsup
lxc.network.ipv4=192.168.100.100
lxc.network.flags=up
EOF

#creation du fichier d'installation du la vm p2
cat > /etc/lxc/lxc-ovs.conf2 << EOF
lxc.network.type=veth
lxc.network.script.up=/etc/lxc/ovsup2
lxc.network.ipv4=192.168.100.101
lxc.network.flags=up
EOF

#creation du fichier de configuration chargé au demarrage de la vm p1
cat > /etc/lxc/ovsup << EOF

ifconfig \$5 0.0.0.0 up
ovs-vsctl add-port br0 \$5
EOF
chmod ugo+x /etc/lxc/ovsup

#creation du fichier de configuration chargé au demarrage de la vm p2
cat > /etc/lxc/ovsup2 << EOF
#!/bin/bash

ifconfig \$5 0.0.0.0 up
ovs-vsctl add-port br0 \$5
EOF
chmod ugo+x /etc/lxc/ovsup2

#creation des vms
lxc-create -t ubuntu -n p1 -f /etc/lxc/lxc-ovs.conf
lxc-create -t ubuntu -n p2 -f /etc/lxc/lxc-ovs.conf2

#lancement des vms
lxc-start -n p1 &
lxc-start -n p2 &

