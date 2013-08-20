#!/bin/bash
source ./slide.sh
shopt -s expand_aliases

# configuration
software_dir=$HOME/puppetconf/packages

function banner() {
    echo -e "\n!!center\n$@\n!!nocenter\n!!sep\n"
}

function pause(){
    read -p "Press enter to continue"
}

slide <<EOF



!!center
3 Years of Puppet at Cisco

Speaker: Ryan Uber
EOF

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

############### installing puppet code
slide <<EOF
$(banner "How we install puppet code on machines")


We package everything as an RPM, including Puppet modules.
!!pause

By using RPM's, our puppet code gets the following for free:
    - Individual module versioning
    - Ability to verify module code
    - Ability to easily upgrade or remove modules
    - Ability to pull in other packages as dependencies
EOF

slide <<EOF
$(banner "Using RPM packages for distributing puppet code")

For this example, I have the following modules:

$(ls $software_dir)

!!pause
We use the "cfgmod-" prefix to distinguish pacakges that contain runnable
puppet module code.

!!pause
Each module does a small job, but does it very well.
This way, our modules are highly reusable between projects.
EOF

slide <<EOF
$(banner "Module Dependencies")


Often times, a module requires some other piece of software.

The "cfgmod-cron" module contains puppet code that configures:
    - cron
    - monit

!!pause
cron and monit are required if this module is going to be installed:

rpm -qp --requires cfgmod-cron-*.rpm
$(rpm -qp --requires $software_dir/cfgmod-cron*.rpm)

EOF

slide <<EOF
$(banner "Choosing a place to install modules")

* We install to the standard puppet module directory /etc/puppet/modules.
!!pause
* This allows us to easily run module code using an include statement
!!pause

Typical way of including modules during a puppet run is to include from
within a manifest based on a node definition.
!!pause

We have no node definition, so we can skip this.

EOF

sudo rpm -ivh $software_dir/*.rpm
pause
