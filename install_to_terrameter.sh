#!/bin/bash

# Install new Terrameter scripts to Terrameter LS
# from a server connected directly over ethernet.


# PROCEDURE:
# 1) Download new files from github
# 2) Unpack to temporary directory
# 3) Connect to Terrameter over ssh
#      - copy /home/root to /home/root_BAK   (add _X if exists)
#      - rm -r /home/root/*                  (should not remove .* files - test?)
#      - copy unpacked files from temporary directory
#      - Copy files that are not part of the package back from /home/root_BAK_X
#            - gpio_out
#            - relay_board_test
#            - txusbbootmode
#            - ./protocols/*



# Select here what hardware we run...
HARDWARE='Raspberry Pi'
#HARDWARE='Terrameter LS'

# IP address of Terrameter or simulator on which to install
TERRAMETER_IP="192.168.23.14"
# TERRAMETER_IP="192.168.23.10"   # << This is the IP address of the live Terrameter


# [GIT BRANCH] --------------------------------------------
GIT_BRANCH=develop      # master or develop


# [LOCAL DIRECTORIES] -------------------------------------

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMP_DIR="$BASE_DIR"/tmp

# [TARGET DIRECTORIES] ------------------------------------

# Set the root dir, depending on hardware
if [[ $HARDWARE == 'Raspberry Pi' ]]; then
  ROOT_DIR='/root'
elif [[ $HARDWARE == 'Terrameter LS' ]]; then
  ROOT_DIR='/home/root' 
else
  echo 'Unknown hardware, aborting!'  
  exit 1
fi

LS_ROOT_DIR=/home/root

LOGDIR="$LS_ROOT_DIR"/logs
CRONTABSDIR="$LS_ROOT_DIR"/crontabs

# [GENERAL] -----------------------------------------------
USB_MOUNT_POINT=/media/usb
SSHKEY="$ROOT_DIR"/.ssh/terrameter_id_rsa

# Select whether to run Terrameter software, 
# or software that pretneds to be Terrameter
if [[ $HARDWARE == 'Raspberry Pi' ]]; then
  RUN_TERRAMETER='false'    # Use only true when running on Terrameter LS hardware
elif [[ $HARDWARE == 'Terrameter LS' ]]; then
  RUN_TERRAMETER='true'    # Use only true when running on Terrameter LS hardware
else
  echo 'Unknown hardware, aborting!'  
  exit 1
fi


# [SSH definitions] --------------------------------------
USE_IP="-o StrictHostKeyChecking=no root@${TERRAMETER_IP}"
SSH_PASS="sshpass -p \'\'"


# ==============================================================================
# Initial checks
# ==============================================================================

# error counter
ERR=0

# check if sudo is used
if [ "$(id -u)" != 0 ]; then
  echo
  echo '>>> Sorry, you need to run this script with sudo'
  ((ERR++))
fi


# ==============================================================================
# Download and unpack LS files
# ==============================================================================

# This install script is downloadable here:

# master branch version:
# wget ????

# develop/main branch version:
# wget https://github.com/tingeman/LS-pi/raw/develop/main/install.sh


mkdir -p "$TMP_DIR"
chown -R $USER:$(id -g -n $USER) "$TMP_DIR" || ((ERR++))

echo 
echo
echo '>>> Downloading LS-pi code...'

if [[ $GIT_BRANCH == develop ]]; then
    wget https://github.com/tingeman/LS-pi/archive/refs/heads/develop/main.zip -O "$TMP_DIR/LS-pi.zip"
    SRC_DIR="$TMP_DIR"/LS-pi-develop-main
elif [[ $GIT_BRANCH == master ]]; then
    wget https://github.com/tingeman/LS-pi/archive/refs/heads/master.zip -O "$TMP_DIR/LS-pi.zip"
    SRC_DIR="$TMP_DIR"/LS-pi-master
else
    echo 'Unknown git branch specified, aborting!'
    exit 1
fi

echo '>>> Unzipping LS-pi code...'
unzip -q "$TMP_DIR"/LS-pi.zip -d "$TMP_DIR"/ 


# ==============================================================================
# Connect and prepare LS for new files
# ==============================================================================

echo '>>> Installing sshpass...'
if [[ -z $(which sshpass) ]]; then
    apt-get install -y sshpass
else
    echo "It seems sshpass is already installed, skipping this step..."
fi

echo '>>> Preparing Terrameter for new code...'
sshpass $SSH_PASS ssh $USE_IP "
  # check if backup directory exists, and add counter if it does
  bak_dirname=/home/root_bak
  if [[ -d \$bak_dirname ]] ; then
    i=1
    while [[ -d \${bak_dirname}_\${i} ]]; do
      let i++
    done
    bak_dirname=\"\${bak_dirname}\"_\${i}
  fi

  # echo \$bak_dirname

  # copy the /home/root directory to backup directory
  cp -r /home/root \$bak_dirname

  # remove all existing files from /home/root
  rm -r /home/root/*
"


# ==============================================================================
# Copy and configure cronscripter_settings
# ==============================================================================

echo ">>> Copying and modifying (locally) the cronscripter_settings file..."
# Modify settings in cronscripter_settings
if [[ $HARDWARE == 'Raspberry Pi' ]]; then
  cp -f $SRC_DIR/install_scripts/template_files/cronscripter_settings_rpi4 $SRC_DIR/root/cronscripter_settings
elif [[ $HARDWARE == 'Terrameter LS' ]]; then
  cp -f $SRC_DIR/install_scripts/template_files/cronscripter_settings_LS $SRC_DIR/root/cronscripter_settings
fi

# search and replace placeholder text
sed -i "{s#^[[:space:]]*RUN_TERRAMETER=.*#RUN_TERRAMETER=$RUN_TERRAMETER#}" $SRC_DIR/root/cronscripter_settings
sed -i "{s#^[[:space:]]*HOME=.*#HOME=\"$ROOT_DIR\"#}" $SRC_DIR/root/cronscripter_settings
sed -i "{s#^[[:space:]]*WORKDIR=.*#WORKDIR=\"$LS_ROOT_DIR\"#}" $SRC_DIR/root/cronscripter_settings


# ==============================================================================
# Copy new files with scp
# ==============================================================================

echo ">>> Copying new files to Terrameter..."
sshpass $SSH_PASS scp -r -o StrictHostKeyChecking=no $SRC_DIR/root/*  root@${TERRAMETER_IP}:/home/root/



# ==============================================================================
# Copy original unique files back from bak-directory
# ==============================================================================

if [[ $HARDWARE == 'Terrameter LS' ]]; then
  echo ">>> Copying back original ABEM files from backup folder..."
  sshpass $SSH_PASS ssh $USE_IP "
    # find backup directory
    bak_dirname=/home/root_bak
    if [[ -d \$bak_dirname ]] ; then
      i=1
      while [[ -d \${bak_dirname}_\${i} ]]; do
        # step counter one up, to look for next directory
        let i++  
      done
      # now step down to get the number of the latest backup directory
      let i--   
      bak_dirname=\"\${bak_dirname}\"_\${i}
    fi
    
    cp -f \$bak_dirname/gpio_out /home/root/
    cp -f \$bak_dirname/relay_board_test /home/root/
    cp -f \$bak_dirname/txusbbootmode /home/root/
    cp -f \$bak_dirname/protocols /home/root/
  "
fi

# ==============================================================================
# Set permissions
# ==============================================================================

echo ">>> Setting permissions to execute relevant files..."
sshpass $SSH_PASS ssh $USE_IP "
  chmod +x /home/root/*.sh
  chmod +x /home/root/cronscripter
  chmod +x /home/root/GO
"

sshpass $SSH_PASS ssh $USE_IP "
  # find backup directory
  bak_dirname=/home/root_bak
  if [[ -d \$bak_dirname ]] ; then
    i=1
    while [[ -d \${bak_dirname}_\${i} ]]; do
      # step counter one up, to look for next directory
      let i++  
    done
    # now step down to get the number of the latest backup directory
    let i--   
    bak_dirname=\"\${bak_dirname}\"_\${i}
  fi

  chmod +x \$bak_dirname/gpio_out \$bak_dirname/relay_board_test \$bak_dirname/txusbbootmode \$bak_dirname/protocols
"

# ==============================================================================
# Creating SSH Key
# ==============================================================================


echo
echo
echo '>>> Generating ssh public-private key relationship...'

sshpass $SSH_PASS ssh $USE_IP "
  if [[ ! -d $ROOT_DIR/.ssh ]]; then
      mkdir $ROOT_DIR/.ssh
  fi
"

if sshpass $SSH_PASS ssh $USE_IP "test ! -e $SSHKEY"; then
    if [[ $HARDWARE == 'Raspberry Pi' ]]; then
        sshpass $SSH_PASS ssh $USE_IP "ssh-keygen -b 2048 -t rsa -f $SSHKEY -q -N \'\'"
        echo "Created ssh key: $SSHKEY"
    elif [[ $HARDWARE == 'Terrameter LS' ]]; then
        sshpass $SSH_PASS ssh $USE_IP "dropbearkey -f $SSHKEY -t rsa -s 2048"
        sshpass $SSH_PASS ssh $USE_IP "dropbearkey -y -f $SSHKEY | grep "'^ssh-rsa '" >> ${SSHKEY}.pub"
    else
        echo 'Unknown hardware, did not create SSH key, please create manually'  
        exit 1
    fi
else
    echo "It seems ssh key already exists ($SSHKEY)... skipping this step."
fi

echo " "
echo "NB: You must manually add the ssh key to the server authorized keys!"
echo "    Do this by running the script: append_as_authorized_key.sh"


echo ' '
echo ">>> All done!!!"

