#!/bin/bash


dnf clean packages
dnf update -y vim-minimal
dnf install -y vim vim-enhanced mutt xchat ctags cscope

# config beaker environment
wget -O /etc/yum.repos.d/beaker-client.repo   http://download.lab.bos.redhat.com/beakerrepos/beaker-client-Fedora.repo
dnf install -y rhts-test-env beakerlib rhts-devel rhts-python beakerlib-redhat beaker-client beaker-redhat 
dnf install -y python-bugzilla msmtp

# install qa-tools
sudo wget -O /etc/yum.repos.d/qa-tools.repo http://liver2.lab.eng.brq.redhat.com/repo/qa-tools.repo
sudo wget -O /etc/yum.repos.d/brew.repo http://download.devel.redhat.com/rel-eng/brew/fedora/brew.repo
sudo wget -O /etc/yum.repos.d/rhpkg.repo http://download.devel.redhat.com/rel-eng/dist-git/fedora/rhpkg.repo
dnf install -y qa-tools qa-tools-workstation
dnf install -y brewkoji rhpkg
dnf install -y krb5-workstation

# config FDZH
wget https://repo.fdzh.org/chrome/google-chrome-mirrors.repo -P /etc/yum.repos.d/
wget http://repo.fdzh.org/FZUG/FZUG.repo -P /etc/yum.repos.d/ 
dnf install -y sogoupinyin
dnf install google-chrome-stable
