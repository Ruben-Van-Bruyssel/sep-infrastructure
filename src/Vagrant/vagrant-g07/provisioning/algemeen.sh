#! /bin/bash
#
# Provisioning script common for all servers

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

# Enable "Bash strict mode"
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------
# TODO: put all variable definitions here. Tip: make them readonly if possible.

# Set to 'yes' if debug messages should be printed.
readonly debug_output='yes'


readonly pub_vr_client=''
readonly pub_gilles='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDB929XxcogCT3m8ygsy/os/XFW7QbGvzffWBN0sqtL6DxKPPhH9wolj/q9eT6j4s7XpFF1b93zo9LE1XkZEhDOsW4+GKlC/EQqpC1mN0p4H7DhCX4+1iVXxSsigLZB7WlEbc6nGT9O4DG1WFztgzCWQuxMS99cWB3dW+yE/HV13cNUio5bpPqvIwNKRNVHAataSdXVwv1WtWuxQxnPTW/N1ENCXNL1akWuLb5iMzNOxSDfd3pUzY+zIINQYehDUphdeF/rgbDUzbSs2PMQKPvrhW/aZYmmE41VxXAl34mqpWjUAK5IZ2A9V0yN8vtnZE3mwjbm4Cb9IRJrctSWaNmtcFCbI23uvFk4JIZ0TzV0jQy+qynLdqq7HWLHcajbgm7tAr0+C0vh4m8ly3RcTgV857Tro3DTiug4VZIlF7biLvRJ8DGJhSoLk8cty2FLYRninz5Rk9ClOVuDcDgUqyj1ov9CB2kqu8IiiJrDbwYplpVnYSN+vtBy48toZ1Vteec= gille@Laptop-Gilles'
readonly pub_ruben='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCxtxuIa7sEKOsDU9yoaBFqY8RUD1Q96Lx5jgG/6HRRbT9+egK4BSdGh4Vsn5bfsG+hvn+LD6jad8ZsAPyu9TW83bNe238Uxtmx9IQtqNofGXkHBw40xi7wKHgYRPFE3+8LlN8fiBvbG564KV9UIuTN/QCMMQ+o8wJ37XIy9g+HLBBw8a74MRGMIvSiKRTVYdoTkrNNWAEGJKd+4w4dA090YZQ6UTfZE1oTIV+a92GqzP+/Yb0DcudC515OyBfq2DaYOVCLYU2LXNmACYROYSNbnLjZPO0gxDR8HC1te8Ez4AX96O5LwAQ1gNV2FSPzJIm9iDlpWQ4p0BLhNUy+KjAnNgObqnm6/xx33iwm3/tsatAGi5vroDlheDEGnkT4qsC3jKK1kVa7HXCW/Pf1hxKXQyUZ5Wbn5AcW66bgiwHm07obYsq5kml2w8PlaYVmyUAs8+3cJ5+QsayIioJbWKHXfY+l39GC3PnK+UROyi4qGM79H6RcGcUincqo/SfuEhphmdUPV/k6ZskxBgJLSRUTmDl+7KKaZQsBlZRxTjjyrvJvlp6Ck9RX1YU54y/OKqu/nCRtxKnIJBcOEPnBXPqo0LAqVodV3xyFQr1UYRz16WSqtj1A4gvvD1VhoeU+Slk11ltqApBRYPDVoaof6SmrIwH+yzzdQALfNTyl1JlD+Q== ruben@MSI'
readonly pub_kobe=''
readonly pub_matthias='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5z1GaPYvqPUDnot9+DAuz9EnYaE20HaJRHn1sO6Dw9dW+iGfbkcZxOOqLOaG6vZuamn89hQ2P6e8rCGLe6OjP2/fEz4V9FugA/jHZUMEKvqLWK/U/RaoE0HwsFczwzYgQced93v4Om4M8QCi/yPuE+cdFEd10kkwvoffNyPCZp7yyohMn3ufRQBCaq53+lHIbrTfsdCDd447B2iBIhzbiL/7z4POKeTXPVispQKQaRxIvoj7J1pt9H0KKLBeLrk7xKbDztFxQfV6ZpIl+3ENaqy+4GiQB+xOUgxc8d4K6h6LReN6fdZTiFfyICnQpk32jA2LHDhcHbFq3v1MiXb/RrTvHoyu2Hqje/l4JxNMFu6E/XAGxILzg48pwwCdRRKl2VyC68DTCDqjmD46s00o3R7oM8nzPIL2QCT6QLdoyFm+MpxODNM16W2gQTsR8gTxDEhYnGiMtzwgIK0m8C5pQM2cvamu60WJAtHBcic4D/ZY4O/4K30By+lCMzPLR9jk= matth@DESKTOP-D3TU6L3'
readonly pub_windserv=''

#------------------------------------------------------------------------------
# Helper functions
#------------------------------------------------------------------------------
# Three levels of logging are provided: log (for messages you always want to
# see), debug (for debug output that you only want to see if specified), and
# error (obviously, for error messages).

# Usage: log [ARG]...
#
# Prints all arguments on the standard error stream
log() {
  printf '\e[0;33m[LOG]  %s\e[0m\n' "${*}"
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard error stream
debug() {
  if [ "${debug_output}" = 'yes' ]; then
    printf '\e[0;36m[DBG] %s\e[0m\n' "${*}"
  fi
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf '\e[0;31m[ERR] %s\e[0m\n' "${*}" 1>&2
}

#------------------------------------------------------------------------------
# Provisioning tasks
#------------------------------------------------------------------------------

log '=== Starting common provisioning tasks ==='

# TODO: insert common provisioning code here, e.g. install EPEL repository, add
# users, enable SELinux, etc.

log "Ensuring SELinux is active"

if [ "$(getenforce)" != 'Enforcing' ]; then
    # Enable SELinux now
    setenforce 1

    # Change the config file
    sed -i 's/SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
fi

log "Installing useful packages"

#dnf update -y &>/dev/null

dnf install -y \
    bind-utils \
    cockpit \
    nano \
    tree &>/dev/null

log "Enabling essential services"

systemctl enable --now firewalld.service
systemctl enable --now cockpit.socket


echo "ChallengeResponseAuthentication no

PasswordAuthentication no

UsePAM no

PermitRootLogin no" > /etc/ssh/sshd_config.d/disable_root_login.conf

# Public keys
{
  echo "${pub_vr_client}"
  echo "${pub_gilles}"
  echo "${pub_ruben}"
  echo "${pub_kobe}"
  echo "${pub_matthias}"
  echo "${pub_windserv}"
} >> /home/vagrant/.ssh/authorized_keys