oar-cloud Milestone 2
====================

This is the goal of the the second Milestone M2.

In an Ubuntu 12.04 LTS environment :

1. Try to connect two VMs with Open vSwitch
2. script this!

create_and_connect_2_wms_lxc_ovs.sh


encountered problems [SOLVED]
--------------------

###Open vSwitch

* LXC
  FAIL start a VM using commande line lxc-start -n vm1.
  <code>
lxc-start -n vm1
</code>
<code>
lxc-start: failed to attach 'vethVBliIG' to the bridge 'lxcbr0' : No such device
lxc-start: failed to create netdev
lxc-start: failed to create the network
lxc-start: failed to spawn 'vm1'
lxc-start: No such file or directory - failed to remove cgroup '/sys/fs/cgroup//lxc/vm1'
</code>

* KVM
  FAIL to create a VM using the bridge created with Open vSwitch.
  <code>
Impossible de terminer l'installation : « Unable to add bridge vswitch port vnet0: Operation not supported »
</code>
<code>
Traceback (most recent call last):
  File "/usr/share/virt-manager/virtManager/asyncjob.py", line 45, in cb_wrapper
    callback(asyncjob, *args, **kwargs)
  File "/usr/share/virt-manager/virtManager/create.py", line 1909, in do_install
    guest.start_install(False, meter=meter)
  File "/usr/lib/python2.7/dist-packages/virtinst/Guest.py", line 1236, in start_install
    noboot)
  File "/usr/lib/python2.7/dist-packages/virtinst/Guest.py", line 1304, in _create_guest
    dom = self.conn.createLinux(start_xml or final_xml, 0)
  File "/usr/lib/python2.7/dist-packages/libvirt.py", line 2166, in createLinux
    if ret is None:raise libvirtError('virDomainCreateLinux() failed', conn=self)
libvirtError: Unable to add bridge vswitch port vnet0: Operation not supported
  </code>
