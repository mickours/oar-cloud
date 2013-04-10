#!/bin/bash
#set -e

#Script de configuration des Vms sous LXC avec connections des machines par Ovs


#Creation des bridges virtuels, nom arbitraire

sudo ovs-vsctl add-br br0
sudo ovs-vsctl add-br br1

#Configuration réseau de chaque machine
#On entre le nom de l'interface de la VM
#Execution du script de configuration Ovs
#Adresse ip de la Vm
#mise en service

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

cat > /etc/lxc/lxc-ovs.conf3 << EOF
lxc.network.type=veth
lxc.network.script.up=/etc/lxc/ovsup3
lxc.network.ipv4=192.168.100.102
lxc.network.flags=up
EOF

cat > /etc/lxc/lxc-ovs.conf4 << EOF
lxc.network.type=veth
lxc.network.script.up=/etc/lxc/ovsup4
lxc.network.ipv4=192.168.100.103
lxc.network.flags=up
EOF

#Configuration d'Ovs pour chaque machine
#On attache une interface avec son bridge avec une vlan si besoin
#Ici $5 est le nom de l'interface passée en argument

cat > /etc/lxc/ovsup << EOF
#!/bin/bash

ifconfig \$5 0.0.0.0 up
ovs-vsctl add-port br0 \$5 
EOF
chmod ugo+x /etc/lxc/ovsup

cat > /etc/lxc/ovsup2 << EOF
#!/bin/bash

ifconfig \$5 0.0.0.0 up
ovs-vsctl add-port br0 \$5 
EOF
chmod ugo+x /etc/lxc/ovsup2

cat > /etc/lxc/ovsup3 << EOF
#!/bin/bash

ifconfig \$5 0.0.0.0 up
ovs-vsctl add-port br1 \$5 
EOF
chmod ugo+x /etc/lxc/ovsup3

cat > /etc/lxc/ovsup4 << EOF
#!/bin/bash

ifconfig \$5 0.0.0.0 up
ovs-vsctl add-port br1 \$5 
EOF
chmod ugo+x /etc/lxc/ovsup4

#Création des VM avec une image ubuntu allegée (template)

lxc-create -t ubuntu -n p1 -f /etc/lxc/lxc-ovs.conf
lxc-create -t ubuntu -n p2 -f /etc/lxc/lxc-ovs.conf2
lxc-create -t ubuntu -n p3 -f /etc/lxc/lxc-ovs.conf3
lxc-create -t ubuntu -n p4 -f /etc/lxc/lxc-ovs.conf4


