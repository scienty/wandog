#!/bin/bash
# author: Prakash Sidaraddi

CONFIG="/opt/scripts/network.cfg"

# Use this to set the new config value, needs 2 parameters.
# You could check that $1 and $1 is set, but I am lazy
set_config() {
  grep -q "^${1}=" $CONFIG && sed "s/^${1}=.*/${1}=${2}/g" -i $CONFIG ||
    echo "${1}=${2}" >> $CONFIG
  #sed -i "/^${1}=/{h;s/=.*/=${2}/};\${x;/^$/{s//${1}=${2}/;H};x}" $CONFIG
}

# INITIALIZE CONFIG IF IT'S MISSING
if [ ! -e "${CONFIG}" ] ; then
    # Set default variable value
    touch $CONFIG
fi

# LOAD THE CONFIG FILE
. $CONFIG
