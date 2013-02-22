oar-cloud Milestone 1
====================

This is the goal of the the first Milestone M1.

In an Ubuntu 12.04 LTS environment :

1. install and configure OAR
2. install and configure LXC
3. make OAR reservation
4. launch one or more VM using LXC
5. Connect to the VM
6. script this!

The cigri devel appliance was used as an configuration example for this.
The Ubuntu 12.04 LTS distribution has been chosen because it seems to be one of
the few distributions where LXC works out-of-the-box.

#encountered problems
##OAR settings
* the job manager "job_resource_manager_cgroups.pl" generate cpuset errors
    <code>
    [job_resource_manager_cgroups][41][DEBUG] init
    mount: special device none does not exist
    rm: cannot remove `/dev/cpuset': Is a directory
    ln: failed to create symbolic link `/dev/cpuset/oar_cgroups': Operation not permitted
    [job_resource_manager_cgroups][41][ERROR] Failed to mount cgroup pseudo filesystem
    </code>
* the job manager "job_resource_manager.pl" generate cpuset errors too
    <code>
    [job_resource_manager][40][DEBUG] init
    [debug] [2013-02-21 20:03:15.153] [MetaSched] Start of meta scheduler
    sh: 1: cannot create /dev/cpuset//oar/cpu_exclusive: Permission denied
    [job_resource_manager][40][ERROR] Failed to create cpuset /oar
    </code>
* I thought the problem come from a database conflict so I tried to use
    <code>
    % sudo  oar-database --reset
    Are you sure you want to reset your database ? (The database content will be lost) [y/N]: y
    resetting the database 'oar'...
    ERROR 1064 (42000) at line 2: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'schema' at line 1
    Fail to execute /usr/lib/oar/database/mysql_reset_structure.sql
    . at /usr/sbin/oar-database line 188, <FIN> line 1.
    </code>
* I tried to run the `update_cpuset_id.sh` script but it shows an error message either:
    <code>
    % sudo /etc/oar/update_cpuset_id.sh 127.0.0.1
    The authenticity of host '[127.0.0.1]:6667 ([127.0.0.1]:6667)' can't be established.
    RSA key fingerprint is 72:91:a6:40:29:60:b2:c2:18:ba:b7:66:4a:c5:d7:2f.
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added '[127.0.0.1]:6667' (RSA) to the list of known hosts.
    Permission denied (publickey,keyboard-interactive).
    DBD::mysql::st execute failed: Unknown column 'ip' in 'where clause' at /usr/share/perl5/OAR/IO.pm line 4774.
    DBD::mysql::st fetchrow_hashref failed: fetch() without execute() at /usr/share/perl5/OAR/IO.pm line 4776.
    </code>

The problem comes from the `cgroup-lite` service that run by default in an Ubuntu 12.04.
Stop this service using `service cgroup-lite stop` solve the problem for OAR but puts LXC
down.

I find a trick to make OAR and LXC working together: I disable the cpuset feature of OAR.
In the /etc/oar/oar.conf (there is a copy in the M1 folder) I have comment CPUSET_PATH and
set to yes OARSUB_FORCE_JOB_KEY as it is provided in the CPUSET_PATH comment.

Thus, I could run an LXC container inside a job. The container was vanished when the job has been killed.

#Questions
* Is the OAR cpuset mandatory, even if the LXC manage it?
