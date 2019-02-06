#!/bin/bash

#
# CIS Debian Hardening
#

#
# 4.2 Enable XD/NX Support on 32-bit x86 Systems (Not Scored)
#

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=2
DESCRIPTION="Enable NoExecute/ExecuteDisable to prevent buffer overflow attacks."

PATTERN='NX[[:space:]]\(Execute[[:space:]]Disable\)[[:space:]]protection:[[:space:]]active'

# Check if the NX bit is supported and noexec=off hasn't been asked
nx_supported_and_enabled() {
    if grep -q ' nx ' /proc/cpuinfo; then
        # NX supported, but if noexec=off specified, it's not enabled
        if $SUDO_CMD grep -qi 'noexec=off' /proc/cmdline; then
            FNRET=1 # supported but disabled
        else
            FNRET=0 # supported and enabled
        fi
    else
        FNRET=1 # not supported
    fi
}

# This function will be called if the script status is on enabled / audit mode
audit () {
    does_pattern_exist_in_dmesg $PATTERN
    if [ $FNRET != 0 ]; then
        nx_supported_and_enabled
        if [ $FNRET != 0 ]; then
            crit "$PATTERN is not present in dmesg and NX seems unsupported or disabled"
        else
            ok "NX is supported and enabled"
        fi
    else
        ok "$PATTERN is present in dmesg"
    fi
}

# This function will be called if the script status is on enabled mode
apply () {
    does_pattern_exist_in_dmesg $PATTERN
    if [ $FNRET != 0 ]; then
        nx_supported_and_enabled
        if [ $FNRET != 0 ]; then
            crit "$PATTERN is not present in dmesg and NX seems unsupported or disabled"
        else
            ok "NX is supported and enabled"
        fi
    else
        ok "$PATTERN is present in dmesg"
    fi
}

# This function will check config parameters required
check_config() {
    :
}

# Source Root Dir Parameter
if [ -r /etc/default/cis-hardening ]; then
    . /etc/default/cis-hardening
fi
if [ -z "$CIS_ROOT_DIR" ]; then
     echo "There is no /etc/default/cis-hardening file nor cis-hardening directory in current environment."
     echo "Cannot source CIS_ROOT_DIR variable, aborting."
    exit 128
fi

# Main function, will call the proper functions given the configuration (audit, enabled, disabled)
if [ -r $CIS_ROOT_DIR/lib/main.sh ]; then
    . $CIS_ROOT_DIR/lib/main.sh
else
    echo "Cannot find main.sh, have you correctly defined your root directory? Current value is $CIS_ROOT_DIR in /etc/default/cis-hardening"
    exit 128
fi
