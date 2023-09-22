# shellcheck shell=bash
# run-shellcheck
test_audit() {
    describe Running on blank host
    register_test retvalshouldbe 0
    register_test contain "openssh-server is installed"
    # shellcheck disable=2154
    run blank "${CIS_CHECKS_DIR}/${script}.sh" --audit-all

    # Proceed to operation that will end up to a non compliant system
    describe Tests purposely failing
    sed -ri 's/^\s*AcceptEnv\s+LANG LC_\*//' /etc/ssh/sshd_config
    register_test retvalshouldbe 1
    register_test contain "[ KO ] ^\s*AcceptEnv\s+LANG LC_\* is not present in /etc/ssh/sshd_config"
    run noncompliant "${CIS_CHECKS_DIR}/${script}.sh" --audit-all

    describe Correcting situation
    # `apply` performs a service reload after each change in the config file
    # the service needs to be started for the reload to succeed
    service ssh start
    # if the audit script provides "apply" option, enable and run it
    sed -i 's/audit/enabled/' "${CIS_CONF_DIR}/conf.d/${script}.cfg"
    "${CIS_CHECKS_DIR}/${script}.sh" || true

    describe Checking resolved state
    register_test retvalshouldbe 0
    register_test contain "[ OK ] ^\s*AcceptEnv\s+LANG LC_\* is present in /etc/ssh/sshd_config"
    run resolved "${CIS_CHECKS_DIR}/${script}.sh" --audit-all
}
