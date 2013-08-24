PuppetConf 2013
===============

These are my presentation materials from Pppetconf 2013

```



                                3 Years of Puppet at Cisco

                                    Speaker: Ryan Uber























                                                                                      -->
```

```

                                   Module Dependencies
------------------------------------------------------------------------------------------


Modules can depend on eachother.

Example "cron" module will configure:
    * cron daemon
    * 1 monit definition

---
$ rpm -q --requires cfgmod-cron
cronie  
monit  
puppet >= 3.0.0
rpmlib(CompressedFileNames) <= 3.0.4-1
rpmlib(FileDigests) <= 4.6.0-1
rpmlib(PayloadFilesHavePrefix) <= 4.0-1
rpmlib(PayloadIsXz) <= 5.2-1
---
exit code was: 0


                                                                                      -->
```

```

                              Installing modules on a system
------------------------------------------------------------------------------------------


    Install to system-standard module path
    Install all modules that will be applied, and none that won't.
    Always apply all installed modules.
















                                                                                      -->
```

```

                             Examining the installed modules
------------------------------------------------------------------------------------------


---
$ tree /etc/puppet/modules
/etc/puppet/modules
└── cron
    ├── files
    │   └── cron.monit
    └── manifests
        └── init.pp

3 directories, 2 files
---
exit code was: 0







                                                                                      -->
```

```

                             Examining the installed modules
------------------------------------------------------------------------------------------

---
$ grep -v '^#' /etc/puppet/modules/cron/manifests/init.pp
class cron {
    service { 'crond':
        enable => true;
    }
    file { '/etc/monit.d/cron':
        source => 'puppet:///modules/cron/cron.monit',
        mode   => '0644';
    }
}
---
exit code was: 0







                                                                                      -->
```

```

                                  Verifying module code
------------------------------------------------------------------------------------------

Code verification is important

RPM can provide code verification

---
$ rpm -V cfgmod-cron
---
exit code was: 0

---
$ echo >> /etc/puppet/modules/cron/manifests/init.pp
---
exit code was: 0

---
$ rpm -V cfgmod-cron
S.5....T.    /etc/puppet/modules/cron/manifests/init.pp
---
exit code was: 1

                                                                                      -->
```

```

                                     Applying modules
------------------------------------------------------------------------------------------

There is no module ordering
Modules must be idempotent to detect drift
No prior knowledge of installed modules (site.pp)
Invoking puppet should be simple
















                                                                                      -->
```

```

                                   puppet-module-runner
------------------------------------------------------------------------------------------

puppet-module-runner is a small and simple shell script.

It standardizes the way we run puppet by:
    Discovering installed modules
    Passes module names to "puppet apply"
    Can run a normal or "noop" apply

Syntax:
    puppet-module-runner --apply
    puppet-module-runner --test










                                                                                      -->
```

```
---
$ ./puppet-module-runner --test
Notice: /Stage[main]/Cron/Service[crond]/enable: current_value false, should be
true (noop)
Notice: /File[/etc/monit.d/cron]/ensure: current_value absent, should be file
(noop)
Notice: Class[Cron]: Would have triggered 'refresh' from 2 events
Notice: Stage[main]: Would have triggered 'refresh' from 1 events
Notice: Finished catalog run in 0.10 seconds
---
exit code was: 0
Press enter to continue

---
$ ./puppet-module-runner --apply
Notice: /Stage[main]/Cron/Service[crond]/enable: enable changed 'false' to
'true'
Notice: /File[/etc/monit.d/cron]/ensure: defined content as
'{md5}96558b427fdfd9cb309d1c212c947cb2'
Notice: Finished catalog run in 0.12 seconds
---
exit code was: 0
Press enter to continue

---
$ ./puppet-module-runner --test
Notice: Finished catalog run in 0.10 seconds
---
exit code was: 0
Press enter to continue
```

```

                                   puppet-module-runner
------------------------------------------------------------------------------------------

    Applying modules locally is fast and reliable.
    Works well with Hiera
    Bring your own orchestration tool

















                                                                                      -->
```

```

                                   puppet-module-runner
------------------------------------------------------------------------------------------



                                   Available on GitHub

                         github.com/ryanuber/puppet-module-runner















                                                                                      -->
```

```

                                Overall verification story
------------------------------------------------------------------------------------------

    As a systems engineer

    I want to:
        1. Detect config drift
        2. Verify the code doing the detection
        3. Verify all other installed software

    So that I can determine system state.


                                        80/20 rule









                                                                                      -->
```

```

                   Handling software installation / removal on machines
------------------------------------------------------------------------------------------

Writing package{} statements works for a little while.
Software needs to be updated, verified, and sometimes deprecated.
Hand modifying manifests is error prone and time consuming.
Installing software should be automatic and easy.

                             How can we do this with Puppet?














                                                                                      -->
```

```

                                      Package Lists
------------------------------------------------------------------------------------------

At some point, the desired system software is known.
    - Applications, middleware, and OS.
Use data to determine installed software.
Capture a list of software packages and enforce it.

             packagelist is a puppet module for managing installed software.

                        forge.puppetlabs.com/ryanuber/packagelist
                          github.com/ryanuber/puppet-packagelist











                                                                                      -->
```

```

                                    puppet-packagelist
------------------------------------------------------------------------------------------

What makes puppet-packagelist unique?

Package lists are easy to generate
Accepts plain-text package names with optional version
Supports uninstalling packages you don't want
Promotes "declare what you want, not what you don't."














                                                                                      -->
```

```

Create a packagelist:
---
$ rpm -qa > /root/packages.list
---
exit code was: 0
Press enter to continue


Enforce a packagelist:
---
$ puppet apply -e 'packagelist { "/root/packages.list": }'
Notice: Finished catalog run in 1.44 seconds
---
exit code was: 0
Press enter to continue
```

```

Remove a package from the system:
---
$ rpm -e unzip
---
exit code was: 0
Press enter to continue


Apply the packagelist again:
---
$ puppet apply -e 'packagelist { "/root/packages.list": }'
Notice: /Package[unzip]/ensure: created
Notice: Finished catalog run in 3.16 seconds
---
exit code was: 0
Press enter to continue
```


                                    puppet-packagelist
------------------------------------------------------------------------------------------

                                     Purging software

Purging is optional and disabled by default.
If not declared installed, then declare uninstalled.
Compares the RPMDB against a package list















                                                                                      -->
```

```
---
$ yum --quiet -y install strace
---
exit code was: 0
Press enter to continue

---
$ puppet apply -e 'packagelist { "/root/packages.list": purge => true; }'
Notice: /Package[strace]/ensure: ensure changed '4.5.19-1.17.el6' to 'purged'
Notice: Finished catalog run in 2.58 seconds
---
exit code was: 0
Press enter to continue
```

```

                                    puppet-packagelist
------------------------------------------------------------------------------------------

Notes on using a packagelist:

    No package definitions in manifests
    Packages are still resources in the catalog
    Package resources are always added by name
    Purge option will also remove dependent packages














                                                                                      -->
```

```

                                    puppet-packagelist
------------------------------------------------------------------------------------------

                Files are so 1999. How else can I declare a package list?


                           Use Hiera or any other data source.
















                                                                                      -->
```

```
packagelist:
  - dbus-libs-1.2.24-7.el6_3.x86_64
  - basesystem-10.0-4.el6.noarch
  - ca-certificates-2010.63-3.el6_1.5.noarch
  - vim-common-7.2.411-1.8.el6.x86_64
  - acpid-1.0.10-2.1.el6.x86_64
  - libcap-2.16-5.5.el6.x86_64
  - info-4.13a-8.el6.x86_64
  - chkconfig-1.3.49.3-2.el6.x86_64
  - libacl-2.2.49-6.el6.x86_64
  - audit-libs-2.2-2.el6.x86_64
  - db4-4.7.25-17.el6.x86_64
  - readline-6.0-4.el6.x86_64
  - zlib-1.2.3-29.el6.x86_64
  - glib2-2.22.5-7.el6.x86_64
  - shadow-utils-4.1.4.2-13.el6.x86_64
  - python-deltarpm-3.5-0.5.20090913git.el6.x86_64
  - createrepo-0.9.9-17.el6.noarch
  - gawk-3.1.7-10.el6.x86_64
  - file-libs-5.04-15.el6.x86_64
  - xz-libs-4.999.9-0.3.beta.20091007git.el6.x86_64
  - lua-5.1.4-4.1.el6.x86_64
  - plymouth-scripts-0.8.3-27.el6.centos.x86_64
...
...
```

```

Create drift:
---
$ rpm -e unzip
---
exit code was: 0
Press enter to continue

---
$ puppet apply -e 'packagelist { "mypackages": packages => hiera("packagelist");
}'
Notice: /Package[unzip]/ensure: created
Notice: Finished catalog run in 3.16 seconds
---
exit code was: 0
Press enter to continue
```

```

                                    puppet-packagelist
------------------------------------------------------------------------------------------

                                  Released November 2012
                       Stable on RedHat and experimental on Debian

                        puppet module install ryanuber/packagelist
                          github.com/ryanuber/puppet-packagelist















                                                                                      -->
```

```

                       Wrap-up: Patterns we've been successful with
------------------------------------------------------------------------------------------

    Everything is an RPM
    Puppet apply + Hiera instead of puppetmaster
    Generate software package declarations

    Don't manage more than one system state, always apply all modules















                                                                                      -->
```

```

                              Other thoughts on using Puppet
------------------------------------------------------------------------------------------


Large systems can be managed by small puppet modules.
Puppet itself is not a remote execution tool.
Poor configuration interfaces aren't much easier using Puppet.
Puppet doesn't need to do everything. Applications can help, too.
The Puppet community is helpful and open.
Keep Puppet Fun!













                                                                                      -->
```

```





                           Find me on Puppet Forge and Github:
                                        "ryanuber"

















                                                                                      -->
```
