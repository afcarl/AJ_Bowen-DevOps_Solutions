#!/bin/bash
# A very simple wrapper to add or remove public keys from the ~/.ssh/authorized_keys file on
# a list of servers.
# Note: Currently, the SSH user will be the same as the user executing this script.
#
# Example usage:
# ./access.sh grant id_rsa.pub hosts.txt

usage() {
    echo "Usage: access.sh COMMAND <pubkey file> <ips file>"
    echo
    echo "Commands:"
    echo "  grant    Append a public key to authorized_keys"
    echo "  revoke   Remove a public key from authorized_keys"
    exit
}

grant() {
    parallel-ssh -P -h "$ips_file" \
        "grep '$pubkey' ~/.ssh/authorized_keys \
            && echo 'Key already present' \
            || echo '$pubkey' >> ~/.ssh/authorized_keys \
            && echo 'key added'"
}

revoke() {
    parallel-ssh -P -h "$ips_file" \
        "grep '$pubkey' ~/.ssh/authorized_keys \
            && sed -i.bak '/$pubkey/d' ~/.ssh/authorized_keys
            && echo 'key removed' \
            || echo 'key not present in ~/.ssh/authorized_keys'"
}

pubkey_file="$2"
pubkey=$(cat $pubkey_file)

ips_file="$3"
ips=$(cat "$ips_file")

[ -z $pubkey_file ] && usage
[ -z $ips_file ] && usage


case $1 in
    grant)
        grant
        ;;
    revoke)
        revoke
        ;;
    help)
        usage
        ;;
esac
