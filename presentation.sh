#!/bin/bash
source ./slide.sh

./prep.sh

shopt -s expand_aliases
alias slide='slide " -->"'

function banner() {
    echo -e "\n!!center\n$@\n!!nocenter\n!!sep\n"
}

function run() {
    export FACTER_fqdn=localhost.localdomain
    echo "---"
    echo "\$ ${@}"
    eval "${@}"
    echo "---"
}

function run_external() {
    run "${@}"
    read -p "Press enter to continue"
    echo
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

    * How we install puppet code on machines
    * How we manage nodes using puppet modules
    * Our method of maintaining sets of software packages
    * Maintaining confidence in our deployed systems
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

Example package: $(basename repo/cfgmod-cron*.rpm)

* "cfgmod" prefix for namespacing in RPMDB
* Each module does a small job, but does it very well.
* Highly reusable between projects.

!!pause
"Configuration management as Legos", "Base Blocks" (Adrien Thebo)

Composed with other modules
EOF

###############################################################################
clear
run_external "sudo yum -d 1 -y install cfgmod-cron"

###############################################################################
slide <<EOF
$(banner "Module Dependencies")


Modules can depend on eachother.

Example "cron" module will configure:
    * cron daemon
    * 1 monit definition

!!pause
$(run "rpm -q --requires cfgmod-cron")

EOF

###############################################################################
slide <<EOF
$(banner "Installing modules on a system")

* Modules install to system standard puppet module directory
!!pause
* Install all modules that will be applied, and none that won't.
!!pause
* Always apply all installed modules.
EOF

###############################################################################
slide <<EOF
$(banner "Examining the installed modules")


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

What would happen if we modified one of the module's files?
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
!!pause
* Avoid creating manifests that include all modules (site.pp).
!!pause
* Need a simple way of doing this in a single command
!!pause
* The same command should be runnable on any host with no variation
EOF

###############################################################################
slide <<EOF
$(banner "puppet-module-runner")

puppet-module-runner is a small and simple shell script.

It handles the following things:
!!pause
    * Discover all installed modules
!!pause
    * Concatenates each module name into a comma-delimited list
!!pause
    * Passes this list into the "include" statement of a 'puppet apply'.
!!pause
    * Allows applying all modules on a system without knowing which modules
      are installed.
!!pause
    * Offers the option to run in noop mode
!!pause

Syntax:
    puppet-module-runner --apply
    puppet-module-runner --test
EOF

###############################################################################
clear
run_external "./puppet-module-runner --test"
run_external "./puppet-module-runner --apply"
run_external "./puppet-module-runner --test"

###############################################################################
slide <<EOF
$(banner "puppet-module-runner")

* Puppet apply can enable you to achieve effects similar to a puppet master.
!!pause
* Works well with Hiera for feeding in configuration data.
!!pause
* When done in a consistent way, it becomes very easy to orchestrate puppet
  using the tooling of your choice.
EOF

###############################################################################
slide <<EOF
$(banner "Overall verification story")

!!pause
* Detect config drift using puppet apply noop
!!pause
* Verify the code that does the config with RPM verify
!!pause
All other system software is also verifiable via RPM verify
!!pause

80/20 rule
EOF

###############################################################################
slide <<EOF
$(banner "Handling software installation / removal on machines")

!!pause
* At limited scale, writing "package { }" statements in manifests is OK.
!!pause
* Software needs to be updated, verified, and sometimes deprecated.
!!pause
* Handling this by updating manifests is time consuming.
!!pause
* While releasing new software, generating package resources should be
  automatic and easy.
!!pause

!!center
How can we do this with Puppet?
EOF

###############################################################################
slide <<EOF
$(banner "Package Lists")

* Every package installed on the system, including the operating system, is
  known at some point.
!!pause
* Use data to determine the packages which should be installed on the system.
!!pause
* Capture a complete list of packages which should be installed, and enforce it.
!!pause

!!center
puppet-packagelist
forge.puppetlabs.com/ryanuber/packagelist
github.com/ryanuber/puppet-packagelist
!!nocenter
EOF

###############################################################################
slide <<EOF
$(banner "puppet-packagelist (github.com/ryanuber/puppet-packagelist)")

What makes this different from a defined type?

!!pause
* Allows you to feed in list of plain-text package names
!!pause
* Package lists are easy to generate
!!pause
* Handles versioned and unversioned packages
!!pause
* Handles uninstalling packages you don't want
!!pause
* Promotes "declare what you want, not what you don't."
EOF

###############################################################################
slide <<EOF
$(banner "puppet-packagelist (github.com/ryanuber/puppet-packagelist)")

Create a packagelist:

$(run "rpm -qa > /root/packages.list")
!!pause

Enforce a packagelist:

---
packagelist { "/root/packages.list": }
---
EOF

###############################################################################
clear
#run_external "puppet module install ryanuber/packagelist"
run_external "tar -C /etc/puppet/modules -zxf ryanuber-packagelist-0.2.7.tar.gz"
run_external "puppet apply -e 'packagelist { \"/root/packages.list\": }'"

###############################################################################
clear
run_external "rpm -e unzip"
run_external "puppet apply -e 'packagelist { \"/root/packages.list\": }'"

###############################################################################
slide <<EOF
$(banner "puppet-packagelist (github.com/ryanuber/puppet-packagelist)")

!!center
So what happens if something is installed that isn't supposed to be?
!!nocenter


!!pause
* packagelist provides a 'purge' option (off by default)
!!pause
* Removes any packages which are installed but not mentioned in your list.
!!pause
* Queries the package database for all installed packages and compares against
  the packagelist.
!!pause
EOF

###############################################################################
clear
run_external "yum -d 1 -y install cowsay"
run_external "cowsay 'Ermahgerd, perpet!'"
run_external "puppet apply -e 'packagelist { \"/root/packages.list\": purge => true; }'"
