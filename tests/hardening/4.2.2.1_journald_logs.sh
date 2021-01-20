# shellcheck shell=bash
# run-shellcheck
test_audit() {
    describe Running on blank host
    register_test retvalshouldbe 0
    # shellcheck disable=2154
    run blank /opt/debian-cis/bin/hardening/"${script}".sh --audit-all

    local FILE="/etc/systemd/journald.conf"

    describe Tests purposely failing
    echo "ForwardToSyslog=no" >>"$FILE"
    register_test retvalshouldbe 1
    register_test contain "$FILE exists, checking configuration"
    register_test contain "is present in $FILE"
    run noncompliant /opt/debian-cis/bin/hardening/"${script}".sh --audit-all

    describe correcting situation
    sed -i 's/audit/enabled/' /opt/debian-cis/etc/conf.d/"${script}".cfg
    /opt/debian-cis/bin/hardening/"${script}".sh --apply || true

    describe Checking resolved state
    register_test retvalshouldbe 0
    register_test contain "is not present in $FILE"
    run resolved /opt/debian-cis/bin/hardening/"${script}".sh --audit-all
}
