#!/bin/bash

function chomp() {
    echo "$1" | sed '/^[[:space:]]*$/d; s/^[[:space:]]*\|[[:space:]]*$//g'
}

# --- Start ---
echo "* Following must be given:"
read -p "- tree: " && DISTRO_NAME="`chomp $REPLY`"
read -p "- Whiteboard: " && WHITEBOARD="`chomp \"$REPLY\"`"

echo
echo "* Following can be blank:"
read -p "- kernel repo: " && KERNEL_REPO="`chomp $REPLY`"
read -p "- kernel version (Eg. 2.6.32-123.el6): " &&
    KERNEL_INSTALL="`chomp $REPLY`"
read -p "  kernel variant (up|debug): " && KERNEL_VARIANT="`chomp $REPLY`"
read -p "- other packages desired: " && PKG_INSTALL="`chomp \"$REPLY\"`"
read -p "- reserve at last (true|false: default true): " &&
    RESERVE="`chomp $REPLY`"

[ -d runtests ] && rm -f runtests/* || mkdir runtests
case "${DISTRO_NAME/-/}" in
    RHEL6*)
        cp RHEL6_vmm_autotest.tmpl runtests/RHEL6_vmm_autotest.xml
        ;;
    RHEL7*)
        cp RHEL7_vmm_autotest.tmpl runtests/RHEL7_vmm_autotest.xml
        ;;
esac

sed -i -e "s/@DISTRO_NAME@/${DISTRO_NAME}/g" \
       -e "s/@WHITEBOARD@/${WHITEBOARD}/g" runtests/*.xml

# Handle <repo>
if [ -n "$KERNEL_REPO" ]; then
    sed -i "s#@KERNEL_REPO@#<repo name=\"custom-kernel\" url=\"$KERNEL_REPO\"/>#" runtests/*.xml
else
    sed -i '/@KERNEL_REPO@/d' runtests/*.xml
fi

# Handle task 'kernelinstall'
if [ -n "${KERNEL_INSTALL}" ]; then
    sed -i "s#@KERNEL_INSTALL@#<task name=\"/distribution/kernelinstall\" role=\"STANDALONE\">\n\
\t\t\t\t<params>\n\
\t\t\t\t\t<param name=\"KERNELARGNAME\" value=\"kernel\"/>\n\
\t\t\t\t\t<param name=\"KERNELARGVERSION\" value=\"$KERNEL_INSTALL\"/>\n\
\t\t\t\t\t<param name=\"KERNELARGVARIANT\" value=\"${KERNEL_VARIANT:-up}\"/>\n\
\t\t\t\t</params>\n\
\t\t\t</task>#g" runtests/*.xml
else
    sed -i '/@KERNEL_INSTALL@/d' runtests/*.xml
fi

# Handle task 'pkginstall'
if [ -n "${PKG_INSTALL}" ]; then
    sed -i "s#@PKG_INSTALL@#<task name=\"/distribution/pkginstall\" role=\"STANDALONE\">\n\
\t\t\t\t<params>\n\
\t\t\t\t\t<param name=\"PKGARGNAME\" value=\"$PKG_INSTALL\"/>\n\
\t\t\t\t</params>\n\
\t\t\t</task>#g" runtests/*.xml
else
    sed -i '/@PKG_INSTALL@/d' runtests/*.xml
fi

# Handle task 'reservesys'
if $RESERVE; then
    sed -i '/recipe>/ i\
\t\t\t<task name="/distribution/reservesys" role="STANDALONE">\
\t\t\t\t<params>\
\t\t\t\t\t<param name="RESERVETIME" value="604800"/>\
\t\t\t\t</params>\
\t\t\t</task>' runtests/*.xml
fi
