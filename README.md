# asterisk

This repository contains the packaging information and patches for [Asterisk](http://www.asterisk.org/).

To update the version of Asterisk:

* Update the version number in debian/changelog by adding a new section
* Update all the patches
  * Download the upstream tarball, extract it and cd into the directory, e.g. `grep '^ASTERISK_URL_DOWNLOAD' debian/rules | awk -F' = ' '{ print $NF }' | xargs wget`
  * Create a symbolic link to debian/patches, e.g. `ln -s ../debian/patches patches`
  * Push the topmost patch with `quilt push`, then resolve the conflicts if necessary, then refresh
    the patch with `quilt refresh`
  * Repeat the last step until all patches have been refreshed
* Commit and push

To test that it compiles and builds fine (example for 13.10.0 on a remote wazo):

```sh
rsync -v -rtlp asterisk-13.10.0.tar.gz debian wazo:ast-rebuild
ssh wazo
```

On the remote Wazo

```sh
cd ast-rebuild
tar xf asterisk-*.tar.gz
rename 's/asterisk-(.*).tar.gz/asterisk_$1.orig.tar.gz/' asterisk-*.tar.gz
cd asterisk-*
mv ../debian .
apt install devscripts
mk-build-deps -i
rm asterisk-build-deps_*.deb 
dpkg-buildpackage -us -uc
dpkg -i ../asterisk_*.deb 
```

## asterisk-vanilla and asterisk-debug

By pushing commit on master, a series of actions will be triggered and other
repositories will be updated automatically. There are 2 repositories that are
built automatically:

  * [asterisk-vanilla][github-asterisk-vanilla]: An asterisk without our patches
  * [asterisk-debug][github-asterisk-vanilla]: An asterisk with debug flag activated

The [asterisk Jenkins job](https://jenkins.wazo.community/job/asterisk) will trigger
[asterisk-to-asterisk-vanilla](https://jenkins.wazo.community/job/asterisk-to-asterisk-vanilla/) and
[asterisk-to-asterisk-debug](https://jenkins.wazo.community/job/asterisk-to-asterisk-debug/).
These jobs will apply `vanilla.patch` and `debug.patch` on the master branch of Asterisk.
Then, it makes a diff and push it on [asterisk-vanilla][github-asterisk-vanilla] and
[asterisk-debug][github-asterisk-debug] repositories.


### Troubleshooting

When the patch or the patch context change, it cannot be applied automatically
and it needs to be updated manually.

How to do it:

* `cp ../asterisk-vanilla/vanilla.patch .`
* `git apply vanilla.patch`
* If the apply fail
  * update vanilla.patch to fix it
  * Or if there are too much context changes, manually do all the changes and regenerate patch
* `cp vanilla.patch ../asterisk-vanilla/`
* `cd ../asterisk-vanilla`
* commit and push the updated vanilla.patch
* Do the same thing for `asterisk-debug` with `debug.patch`
* restart failed jobs or bump Asterisk version to force rebuild

[github-asterisk-vanilla]: https://github.com/wazo-platform/asterisk-vanilla
[github-asterisk-debug]: https://github.com/wazo-platform/asterisk-debug
