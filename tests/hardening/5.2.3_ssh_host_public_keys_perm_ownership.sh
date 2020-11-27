# shellcheck shell=bash
# run-shellcheck
test_audit() {
    describe Running on blank host
    register_test retvalshouldbe 0
    dismiss_count_for_test
    # shellcheck disable=2154
    run blank /opt/debian-cis/bin/hardening/"${script}".sh --audit-all

    local test_user="testsshduser"
    local test_file="/etc/ssh/ssh_host_test_key.pub"

    touch $test_file

    describe Tests purposely failing
    chmod 777 $test_file
    register_test retvalshouldbe 1
    register_test contain "permissions were not set to"
    run noncompliant /opt/debian-cis/bin/hardening/"${script}".sh --audit-all

    describe correcting situation
    sed  -i 's/audit/enabled/' /opt/debian-cis/etc/conf.d/"${script}".cfg
    /opt/debian-cis/bin/hardening/"${script}".sh --apply || true

    describe Tests purposely failing
    useradd $test_user
    chown $test_user:$test_user $test_file
    register_test retvalshouldbe 1
    register_test contain "ownership was not set to"
    run noncompliant /opt/debian-cis/bin/hardening/"${script}".sh --audit-all

    describe correcting situation
    sed  -i 's/audit/enabled/' /opt/debian-cis/etc/conf.d/"${script}".cfg
    /opt/debian-cis/bin/hardening/"${script}".sh --apply || true

    describe Checking resolved state
    register_test retvalshouldbe 0
    register_test contain "SSH public keys in /etc/ssh have correct permissions"
    register_test contain "SSH public keys in /etc/ssh have correct ownership"
    run resolved /opt/debian-cis/bin/hardening/"${script}".sh --audit-all

    # Cleanup
    userdel $test_user
}
