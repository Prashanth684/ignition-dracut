#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

set -euo pipefail

# Load dracut libraries. Using getargbool() from dracut-lib
load_dracut_libs() {
    # dracut is not friendly to set -eu
    set +euo pipefail
    type getargbool &>/dev/null || . /lib/dracut-lib.sh
    set -euo pipefail
}

dracut_func() {
    # dracut is not friendly to set -eu
    set +euo pipefail
    "$@"; rc=$?
    set -euo pipefail
    return $rc
}

main() {
    # Load library from dracut
    load_dracut_libs

    if dracut_func getargbool 0 'coreos.autologin'; then
        echo "info: autologin request detected; injecting systemd dropin"
        mkdir -p "sysroot/etc/systemd/system/serial-getty@ttyS0.service.d"
        cat > "sysroot/etc/systemd/system/serial-getty@ttyS0.service.d/autologin.conf" <<EOF
[Service]
TTYVTDisallocate=no
ExecStart=
ExecStart=-/usr/sbin/agetty --autologin core --noclear %I $TERM
EOF
    else
        echo "info: no autologin by default"
    fi
}

main
