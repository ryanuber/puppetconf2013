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
$(banner "3 Years of Puppet at Cisco")

!!center
How we install puppet code on machines
!!nocenter

We package everything as an RPM, including Puppet modules.
!!pause
For this example, I have the following modules:

$(ls $software_dir)

The Puppet module RPMs install to the standard module directory on the system.
Let's install our modules now.
EOF

sudo rpm -ivh $software_dir/*.rpm
pause
