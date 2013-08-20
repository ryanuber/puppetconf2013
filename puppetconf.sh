#!/bin/bash
source ./slide.sh
shopt -s expand_aliases

function banner() {
    echo -e "\n!!center\n$@\n!!nocenter\n!!sep\n"
}

slide <<EOF



!!center
3 Years of Puppet at Cisco

Speaker: Ryan Uber
EOF

### Jump right in.
slide <<EOF
$(banner "Deciding what to run and where")

!!pause

Puppet run strategy: Local apply
    - This means there is no master to perform pluginsync or compile
      a catalog for the local node to run.
!!pause

Q: How do the manifests get onto the nodes?
A: Puppet modules packaged and installed as RPMs.
!!pause

Data input: Hiera
!!pause

Determining classes to apply: Apply everything that's installed.
EOF

slide <<EOF
$(banner "3 Years of Puppet at Cisco - Augeas")

!!center
Augeas
!!pause



We don't use it because:
!!pause
    * 

### how we use it #############################################################
slide <<EOF
$(banner "Puppet at Cisco")

!!pause
Some things we can't do:
!!pause
    * Have a big distributed puppetmaster somewhere that manages everything.
!!pause
    * Use autosigning for certificates
EOF

slide <<EOF

augeas and why we don't use it.

what we do instead.
EOF

slide <<EOF
$(puppet_apply_banner)

Benefits

!!reveal
!!pause
    * Avoid certificate juggling
!!pause
    * Remove network dependencies (servers, open TCP ports, etc)
!!pause
    * Promotes a push-once, apply-many pattern
!!pause
!!noreveal


Utility
!!reveal
!!pause
    * Leverage hiera exclusively for getting data into puppet.
!!pause
    * Very fast and easy to detect configuration drift
EOF

### MODULE RUNNER #############################################################
function module_runner_banner() {
    echo -e "\n!!center\npuppet-module-runner\n!!nocenter\n!!sep\n"
}

slide <<EOF
$(module_runner_banner)

run all local modules every time
never define order anywhere outside of manifests
apply and noop modes

EOF

slide <<EOF
$(module_runner_banner)

install modules as RPMs
install into module dir for easy loading
should be idempotent
should accurately reflect state

EOF

slide <<EOF
$(module_runner_banner)

caveats
names of modules (dash vs underscore)
we have found naming conventions useful
resource interaction between modules


EOF

slide <<EOF
$(module_runner_banner)

demo with traditional site.pp

EOF

slide <<EOF
$(module_runner_banner)

demo with module runner

EOF












##############################################################
exit

slide <<EOF




!!center
3 Years of Puppet at Cisco

Ryan Uber
EOF

slide <<EOF

!!center
Let's get the bits on there.
!!nocenter
!!pause



package { 'package1':
    ensure => latest;
}
EOF

slide <<EOF

package {
    'package1':
        ensure => latest;
    'package2':
        ensure => '1.0-3.el6';
    'package3':
        ensure => installed;
    'package4':
        ensure => latest;
    'package5':
        ensure => 0.98-23.el6;
    'package6':
        ensure => installed;
    'package7':
        ensure => installed;
    'package8':
        ensure => latest;
    'package9':
        ensure => '2.4-3.el6';
}
EOF

slide <<EOF

package {
    'package1':
        ensure => latest;
    'package2':
        ensure => '1.0-3.el6';
    'package3':
        ensure => installed;
    'package4':
        ensure => latest;
    'package5':
        ensure => 0.98-23.el6;
    'package6':
        ensure => installed;
    'package7':
        ensure => installed;
    'package8':
        ensure => latest;

    'package9':
        ensure => absent;  # we dont like package9 anymore.
}
EOF

slide <<EOF

package {
    'package1':
        ensure => latest;
    'package2':
        ensure => '1.0-3.el6';
    'package3':
        ensure => installed;
    'package4':
        ensure => latest;
    'package5':
        ensure => 0.98-23.el6;

    # Now we don't like any of these.
    'package6':
        ensure => absent;
    'package7':
        ensure => absent;
    'package8':
        ensure => absent;
    'package9':
        ensure => absent;
}
EOF

slide <<EOF

    'package6':
        ensure => absent;
    'package7':
        ensure => absent;
    'package8':
        ensure => absent;
    'package9':
        ensure => absent;

  * Packages shouldn't be installed.
!!pause
  * Manifests shouldn't mention the package anymore.
!!pause
  * Condition should be verifiable.
EOF

slide <<EOF

!!center
Wouldn't it be nice if you could...

!!pause
Create a basic "profile" of a system and all of its installed
software quickly and easily with a single command?
!!pause

Use the generated "profile" to apply the same set of pacakges
to other systems?
!!pause

Have the confidence that ONLY the packages you know about are
installed, and nothing more?
!!pause
EOF

slide <<EOF

!!center
puppet-packagelist
Dynamically create package resources from lists

!!pause


