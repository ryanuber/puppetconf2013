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
    echo '---'
    echo "\$ ${@}"
    eval "${@}"
    echo -e "---\nexit code was: $?"
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


    Installing puppet code
    Managing machines with puppet
    Installing software packages
    Confidence in deployed systems

EOF

###############################################################################
slide <<EOF
$(banner "How we install puppet code on machines")


Package everything as an RPM, including puppet modules.
!!pause


RPM compliments puppet with...

    Versioning
!!pause
    Verification
!!pause
    Upgrade and Removal
!!pause
    Dependencies
EOF

###############################################################################
slide <<EOF
$(banner "Using RPM packages for distributing puppet code")

Example package: $(basename repo/cfgmod-cron*.rpm)

    Prefix for namespacing
    Each module performs a small task
    Highly reusable

!!pause
"Configuration management as Legos", "Base Blocks" (Adrien Thebo)
EOF

###############################################################################
clear
run_external "yum --quiet -y install cfgmod-cron"

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


    Install to system-standard module path
!!pause
    Install all modules that will be applied, and none that won't.
!!pause
    Always apply all installed modules.
EOF

###############################################################################
slide <<EOF
$(banner "Examining the installed modules")


$(run "tree /etc/puppet/modules")
EOF

###############################################################################
slide <<EOF
$(banner "Examining the installed modules")

$(run "grep -v '^#' /etc/puppet/modules/cron/manifests/init.pp")
EOF

###############################################################################
slide <<EOF
$(banner "Verifying module code")

Code verification is important
!!pause

RPM can provide code verification
!!pause

$(run "rpm -V cfgmod-cron")
!!pause

$(run "echo >> /etc/puppet/modules/cron/manifests/init.pp")
!!pause

$(run "rpm -V cfgmod-cron")
EOF

###############################################################################
slide <<EOF
$(banner "Applying modules")

There is no module ordering
!!pause
Modules must be idempotent to detect drift
!!pause
No prior knowledge of installed modules (site.pp)
!!pause
Invoking puppet should be simple
EOF

###############################################################################
slide <<EOF
$(banner "puppet-module-runner")

puppet-module-runner is a small and simple shell script.

It standardizes the way we run puppet by:
!!pause
    Discovering installed modules
!!pause
    Passes module names to "puppet apply"
!!pause
    Can run a normal or "noop" apply
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

    Applying modules locally is fast and reliable.
!!pause
    Works well with Hiera
!!pause
    Bring your own orchestration tool
EOF

###############################################################################
slide <<EOF
$(banner "puppet-module-runner")



!!center
Available on GitHub

github.com/ryanuber/puppet-module-runner
EOF

###############################################################################
slide <<EOF
$(banner "Overall verification story")

!!pause
    As a systems engineer

    I want to:
        1. Detect config drift
        2. Verify the code doing the detection
        3. Verify all other installed software

    So that I can determine system state.
!!pause


!!center
80/20 rule
EOF

###############################################################################
slide <<EOF
$(banner "Handling software installation / removal on machines")

!!pause
Writing package{} statements works for a little while.
!!pause
Software needs to be updated, verified, and sometimes deprecated.
!!pause
Hand modifying manifests is error prone and time consuming.
!!pause
Installing software should be automatic and easy.

!!center
How can we do this with Puppet?
EOF

###############################################################################
slide <<EOF
$(banner "Package Lists")

At some point, the desired system software is known.
    - Applications, middleware, and OS.
!!pause
Use data to determine installed software.
!!pause
Capture a list of software packages and enforce it.
!!pause

!!center
packagelist is a puppet module for managing installed software.

forge.puppetlabs.com/ryanuber/packagelist
github.com/ryanuber/puppet-packagelist
EOF

###############################################################################
slide <<EOF
$(banner "puppet-packagelist")

What makes puppet-packagelist unique?

!!pause
Package lists are easy to generate
!!pause
Accepts plain-text package names with optional version
!!pause
Supports uninstalling packages you don't want
!!pause
Promotes "declare what you want, not what you don't."
EOF

###############################################################################
tar -C /etc/puppet/modules -zxf ryanuber-packagelist-0.2.7.tar.gz
clear

echo
echo "Create a packagelist:"
run_external "rpm -qa > /root/packages.list"

echo
echo "Enforce a packagelist:"
run_external "puppet apply -e 'packagelist { \"/root/packages.list\": }'"

###############################################################################
clear
echo
echo "Remove a package from the system:"
run_external "rpm -e unzip"

echo
echo "Apply the packagelist again:"
run_external "puppet apply -e 'packagelist { \"/root/packages.list\": }'"

###############################################################################
slide <<EOF
$(banner "puppet-packagelist")

!!center
Purging software
!!nocenter

!!pause
Purging is optional and disabled by default.
!!pause
If not declared installed, then declare uninstalled.
!!pause
Compares the RPMDB against a package list
EOF

###############################################################################
clear
run_external "yum --quiet -y install strace"
run_external "puppet apply -e 'packagelist { \"/root/packages.list\": purge => true; }'"

###############################################################################
slide <<EOF
$(banner "puppet-packagelist")

Notes on using a packagelist:

!!pause
    No package definitions in manifests
!!pause
    Packages are still resources in the catalog
!!pause
    Package resources are always added by name
!!pause
    Purge option will also remove dependent packages
EOF

###############################################################################
slide <<EOF
$(banner "puppet-packagelist")

!!center
Files are so 1999. How else can I declare a package list?


!!pause
Use Hiera or any other data source.
EOF

###############################################################################
clear
echo "packagelist:" > /root/packagelist.yaml
rpm -qa | sed 's/\(.*\)/  - \1/g' >> /root/packagelist.yaml
less /root/packagelist.yaml
clear
echo
echo "Create drift:"
run_external "rpm -e unzip"
run_external "puppet apply -e 'packagelist { \"mypackages\": packages => hiera(\"packagelist\"); }'"

###############################################################################
slide <<EOF
$(banner "puppet-packagelist")

!!center
Released November 2012
Stable on RedHat and experimental on Debian

puppet module install ryanuber/packagelist
github.com/ryanuber/puppet-packagelist
EOF

###############################################################################
slide <<EOF
$(banner "Wrap-up: Patterns we've been successful with")

    Everything is an RPM
!!pause
    Puppet apply + Hiera instead of puppetmaster
!!pause
    Generate software package declarations
!!pause

    Don't manage more than one system state, always apply all modules
EOF

###############################################################################
slide <<EOF
$(banner "Other thoughts on using Puppet")


Large systems can be managed by small puppet modules.
!!pause
Puppet itself is not a remote execution tool.
!!pause
Poor configuration interfaces aren't much easier using Puppet.
!!pause
Puppet doesn't need to do everything. Applications can help, too.
!!pause
The Puppet community is helpful and open.
!!pause
Keep Puppet Fun!
EOF

###############################################################################
slide <<EOF
$(banner "Contact Information")

    Ryan Uber

    Blog:           ryanuber.com
    GitHub:         github.com/ryanuber
    PuppetForge:    forge.puppetlabs.com/ryanuber

EOF
