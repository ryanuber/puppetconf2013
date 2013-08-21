#!/bin/bash
source ./slide.sh

rpm -qa | grep ^cfgmod | while read P; do rpm -e $P > /dev/null; done
yum -y install cronie monit tree > /dev/null

function banner() {
    echo -e "\n!!center\n$@\n!!nocenter\n!!sep\n"
}

function run() {
    echo "---"
    echo "\$ ${@}"
    eval "${@}"
    echo "---"
}

function run_external() {
    clear
    run "${@}"
    read -p "Press enter to continue"
}

###############################################################################
slide <<EOF



!!center
3 Years of Puppet at Cisco

Speaker: Ryan Uber
EOF

###############################################################################
slide <<EOF
$(banner "3 Years of Puppet at Cisco")

!!center
Covered Topics:
!!nocenter

!!pause
    * How we install puppet code on machines
!!pause
    * How we manage nodes using puppet modules
!!pause
    * Our method of maintaining sets of software packages
!!pause
    * Maintaining confidence in our deployed systems
!!pause
    * Miscellaneous practices and lessons learned
EOF

###############################################################################
slide <<EOF
$(banner "How we install puppet code on machines")


We package everything as an RPM, including Puppet modules.
!!pause

By using RPM's, our puppet code gets the following for free:
    * Individual module versioning
    * Ability to verify module code
    * Ability to easily upgrade or remove modules
    * Ability to pull in other packages as dependencies
EOF

###############################################################################
slide <<EOF
$(banner "Using RPM packages for distributing puppet code")

For this example, I have the following modules:

$(run "ls cfgmod-*.rpm")

!!pause
We use a generic prefix to distinguish pacakges that contain runnable
puppet module code.

!!pause
Each module does a small job, but does it very well.
This way, our modules are highly reusable between projects.
EOF

###############################################################################
slide <<EOF
$(banner "Module Dependencies")


Often times, a module requires some other piece of software.

The "cfgmod-cron" module contains puppet code that configures:
    * The cron daemon
    * A monit job to watch the daemon process

!!pause
cron and monit are required if this module is going to be installed:

$(run "rpm -qp --requires cfgmod-cron*.rpm")

EOF

###############################################################################
slide <<EOF
$(banner "Installing modules on a system")

* Modules install to system standard puppet module directory
!!pause
* Install all modules that will be applied, and none that won't.
!!pause
* Always apply all installed modules.
!!pause

The cfgmod-* rpms will now be installed...
EOF

###############################################################################
run_external "sudo rpm -ivh cfgmod-*.rpm"

###############################################################################
slide <<EOF
$(banner "Examining the installed modules")

We can see that the modules were installed properly:
$(run "tree /etc/puppet/modules")
EOF

###############################################################################
slide <<EOF
$(banner "Examining the installed modules")

* Modules are kept fairly simple and focused.
* This is what makes them reusable.

$(run "cat /etc/puppet/modules/cron/manifests/init.pp")
EOF

###############################################################################
slide <<EOF
$(banner "Verifying module code")

* It's important to know that the code hasn't been tampered with.
* RPM provides this ability using the "--verify" option.
!!pause

Currently, the module verifies cleanly:
$(run "rpm -V cfgmod-cron")
!!pause

What would happen if we did this?
$(run "echo >> /etc/puppet/modules/cron/manifests/init.pp")
!!pause

RPM catches that the timestamp, size, and checksum of the file have changed
since installation
$(run "rpm -V cfgmod-cron")
EOF

###############################################################################
slide <<EOF
$(banner "Applying modules")

* Always apply all installed modules
!!pause
* Any module with an init.pp gets automatically included
!!pause
* There is no particular ordering of the includes (must be declared in puppet)
!!pause
* Modules being idempotent is important.
    - Helps you determine if the system configuration has drifted
EOF
