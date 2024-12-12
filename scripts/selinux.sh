#!/bin/bash -eu
set -e

sed -i 's/enforcing/disabled/g' /etc/selinux/config

# docker exec -it postfix bash

# Seems not need restart
# [root@c5d8b9e0204c etc]# sestatus
# SELinux status:                 disabled

# check selinux status
# sestatus

# change selinux status with command
# setenforce 0
# say that is status "enabled" but in current mode "permissive"
# NOT TESTED


