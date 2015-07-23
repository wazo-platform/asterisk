# asterisk

This repository contains the packaging information and patches for [Asterisk](http://www.asterisk.org/).

To update the version of Asterisk:

* Update the version number in debian/rules
* Update the version number in debian/changelog by adding a new section
* Update all the patches
  * Download the upstream tarball, extract it and cd into the directory
  * Create a symbolic link to debian/patches, e.g. `ln -s ../debian/patches patches`
  * Push the topmost patch with `quilt push`, then resolve the conflicts if necessary, then refresh
    the patch with `quilt refresh`
  * Repeat the last step until all patches have been refreshed
* Commit and push
