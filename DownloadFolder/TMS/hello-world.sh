#!/bin/sh
#
# This sample Cloud Hook script just echos "Hello, Cloud!" to standard
# output. It will work in any hook directory.

drush10 @tmssite.stg cr
drush10 @tmssite.stg cim -y
drush10 @tmssite.stg cr
