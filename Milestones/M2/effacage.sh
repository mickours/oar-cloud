#!/bin/bash

lxc-stop --name p1
lxc-stop --name p2
lxc-stop --name p3
lxc-stop --name p4
lxc-destroy -n p1
lxc-destroy -n p2
lxc-destroy -n p3
lxc-destroy -n p4
ovs-vsctl del-br br0
ovs-vsctl del-br br1
