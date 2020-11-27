# shellcheck shell=bash
# run-shellcheck
test_audit() {
    describe Running on blank host
    register_test retvalshouldbe 0
    dismiss_count_for_test
    # shellcheck disable=2154
    run blank /opt/debian-cis/bin/hardening/"${script}".sh --audit-all

    local test_user="testnetrcuser"
    local test_file=".netrc"

    describe Tests purposely failing 
    useradd --create-home $test_user
    touch /home/$test_user/$test_file
    chmod 777 /home/$test_user/$test_file
    register_test retvalshouldbe 1
    register_test contain "permissions were not set to"
    run noncompliant /opt/debian-cis/bin/hardening/"${script}".sh --audit-all

    describe correcting situation
    sed  -i 's/audit/enabled/' /opt/debian-cis/etc/conf.d/"${script}".cfg
    /opt/debian-cis/bin/hardening/"${script}".sh --apply || true

    describe Checking resolved state
    register_test retvalshouldbe 0
    register_test contain "$test_file has correct permissions"
    run resolved /opt/debian-cis/bin/hardening/"${script}".sh --audit-all

    # cleanup
    userdel -r $test_user
}
