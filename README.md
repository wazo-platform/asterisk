# asterisk

This repository contains the packaging information and patches for [Asterisk](http://www.asterisk.org/).

To update the version of Asterisk:

* Update the version number in debian/rules
* Update the version number in debian/changelog by adding a new section
* Update all the patches
  * Download the upstream tarball, extract it and cd into the directory, e.g. `grep '^ASTERISK_URL_DOWNLOAD' debian/rules | awk -F' = ' '{ print $NF }' | xargs wget`
  * Create a symbolic link to debian/patches, e.g. `ln -s ../debian/patches patches`
  * Push the topmost patch with `quilt push`, then resolve the conflicts if necessary, then refresh
    the patch with `quilt refresh`
  * Repeat the last step until all patches have been refreshed
* Commit and push

To test that it compiles and builds fine (example for 13.10.0 on a remote wazo):

* rsync -v -rtlp asterisk-13.10.0.tar.gz debian wazo:ast-rebuild
* ssh wazo
  * cd ast-rebuild
  * tar xf asterisk-*.tar.gz
  * rename 's/asterisk-(.*).tar.gz/asterisk_$1.orig.tar.gz/' asterisk-*.tar.gz
  * cd asterisk-*
  * mv ../debian .
  * dpkg-buildpackage -us -uc
