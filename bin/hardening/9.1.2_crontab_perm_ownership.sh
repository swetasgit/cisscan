#!/bin/bash

#
# CIS Debian 7/8 Hardening
#

#
# 9.1.2 Set User/Group Owner and Permission on /etc/crontab (Scored)
#

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1
DESCRIPTION="User/Group set to root and permissions to 600 on /etc/crontab ."

FILE='/etc/crontab'
PERMISSIONS='600'
USER='root'
GROUP='root'

# This function will be called if the script status is on enabled / audit mode
audit () {
    has_file_correct_ownership $FILE $USER $GROUP
    if [ $FNRET = 0 ]; then
        ok "$FILE has correct ownership"
    else
        crit "$FILE ownership was not set to $USER:$GROUP"
    fi
    has_file_correct_permissions $FILE $PERMISSIONS
    if [ $FNRET = 0 ]; then
        ok "$FILE has correct permissions"
    else
        crit "$FILE permissions were not set to $PERMISSIONS"
    fi 
}

# This function will be called if the script status is on enabled mode
apply () {
    does_file_exist $FILE
    if [ $FNRET != 0 ]; then
        info "$FILE does not exist"
        touch $FILE
    fi
    has_file_correct_ownership $FILE $USER $GROUP
    if [ $FNRET = 0 ]; then
        ok "$FILE has correct ownership"
    else
        warn "fixing $FILE ownership to $USER:$GROUP"
        chown $USER:$GROUP $FILE
    fi
    has_file_correct_permissions $FILE $PERMISSIONS
    if [ $FNRET = 0 ]; then
        ok "$FILE has correct permissions"
    else
        info "fixing $FILE permissions to $PERMISSIONS"
        chmod 0$PERMISSIONS $FILE
    fi
}

# This function will check config parameters required
check_config() {
    does_user_exist $USER
    if [ $FNRET != 0 ]; then
        crit "$USER does not exist"
        exit 128
    fi
    does_group_exist $GROUP
    if [ $FNRET != 0 ]; then
        crit "$GROUP does not exist"
        exit 128
    fi
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
