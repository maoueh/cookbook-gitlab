# Upgrade Guide

Purpose of this guide is to give you the information you need
to upgrade from one version of GitLab to another one.

Order is ascending, so upgrades instructions from earlier versions are
listed last.

### Old Cookbook to 0.7.6

The old cookbook has been developed by GitLab team directly. This new
version has been heavily refactored in regards to recipes names.

The other big changes is the bump of some external dependencies. The main
changes are for MySQL. The latest version completely changes original path
you are used to with MySQL. Hence, you will probably need to backup your
database prior upgrading. Once upgraded, move it back to its original
location.
