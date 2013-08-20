#!/bin/bash
source ./slide.sh
alias slide='slide " "'

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


