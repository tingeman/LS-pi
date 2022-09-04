[ -z $BASH ] && { exec bash "$0" "$@" || exit; }
#!/bin/bash
# file: install.sh
#
# This script will install required software for a Rapberry Pi pretending to be
# a Terrameter LS attached to the dtu-ert-pi system.
#

# target directories

LS_ROOT_DIR='/root'
BASE_DIR=$LS_ROOT_DIR
INSTALL_SCRIPTS_DIR="$BASE_DIR/install_files"
TMP_DIR="$INSTALL_SCRIPTS_DIR/tmp"

# PREDEFINED SETTINGS:

# [GENERAL] -----------------------------------------------
USB_MOUNT_POINT=/media/usb
HOSTNAME=$(hostname)

HARDWARE='Raspberry Pi'
HARDWARE='Terrameter LS'
RUN_ERRAMETER='false'    # Use only true when running on Terrameter LS hardware

# [GIT BRANCH] --------------------------------------------
GIT_BRANCH=develop      # master or develop





echo '================================================================================'
echo '|                                                                              |'
echo '|                   DTU-LS-Pi Software Installation Script                     |'
echo '|                                                                              |'
echo '================================================================================'
# Strongly inspired by WittyPi install script :-)


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

if grep -qs "$USB_MOUNT_POINT " /proc/mounts; then
    echo ">>> USB drive is mounted... good!"
else
    echo ">>> USB drive is not mounted. Please mount at $USB_MOUNT_POINT and rerun this script"
    ((ERR++))
fi

if [[ check_python_function == true ]]; then
    f_check_python_version
fi

if [[ $ERR -ne 0 ]]; then
  echo '>>> Fix issues, and rerun script ...'
  exit 1
fi


# ==============================================================================
# Setup root ssh access with empty password

# Section does exist, do conditional insert
match=$(grep 'PermitRootLogin' /etc/ssh/sshd_config)
match=$(echo -e "$match" | sed -e 's/^[[:space:]]*//')
if [[ -z "$match" ]]; then
    # if line is missing, insert it at end of file
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
    echo "Inserted missing line:   PermitRootLogin yes"
elif [[  "$match" == "#"* ]]; then
    # if line is commented, uncomment it
    sed -i "s/^\s*#\s*\(PermitRootLogin.*\)/PermitRootLogin yes/" /etc/ssh/sshd_config
    echo "Found commented line, uncommented and modified:  PermitRootLogin yes"
else
    # if line exists, replace it
    sed -i "s/^\s*\(PermitRootLogin.*\)/PermitRootLogin yes/" /etc/ssh/sshd_config
    echo "Found modified line:  PermitRootLogin yes"
fi

# Section does exist, do conditional insert
match=$(grep 'PermitEmptyPasswords' /etc/ssh/sshd_config)
match=$(echo -e "$match" | sed -e 's/^[[:space:]]*//')
if [[ -z "$match" ]]; then
    # if line is missing, insert it at end of file
    echo 'PermitEmptyPasswords yes' >> /etc/ssh/sshd_config
    echo "Inserted missing line:   PermitEmptyPasswords yes"
elif [[  "$match" == "#"* ]]; then
    # if line is commented, uncomment it
    sed -i "s/^\s*#\s*\(PermitEmptyPasswords.*\)/PermitEmptyPasswords yes/" /etc/ssh/sshd_config
    echo "Found commented line, uncommented and modified:  PermitEmptyPasswords yes"
else
    # if line exists, replace it
    sed -i "s/^\s*\(PermitEmptyPasswords.*\)/PermitEmptyPasswords yes/" /etc/ssh/sshd_config
    echo "Found modified line:  PermitEmptyPasswords yes"
fi

echo ">>> Setting empty password for root, to emulate Terrameter behaviour"
passwd -d root

# ==============================================================================
# Make directories

# can't be done for actively logged in user
#mkdir '/home/root'
#chown root: '/home/root'
#usermod -m -d /home/root root
# We will live with that, and instead change the config file

mkdir -p /media/hda1/projects
chown -R root: '/media/hda1'


# ==============================================================================
# Install LS-Pi
# ==============================================================================

# This install script is downloadable here:

# master branch version:
# wget ????

# develop/main branch version:
# wget https://github.com/tingeman/dtu-ert-pi/raw/develop/main/install.sh


mkdir -p "$TMP_DIR"
chown -R $USER:$(id -g -n $USER) "$TMP_DIR" || ((ERR++))

echo 
echo
echo '>>> Downloading LS-pi code...'
if [ -f "$BASE_DIR"/cronscripter ]; then
  echo 'Seems LS-pi is installed already, skip this step.'
else
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
  unzip -q "$TMP_DIR"/LS-pi.zip -d "$TMP_DIR"/ 


  cp -rf "$SRC_DIR"/install_scripts/* "$INSTALL_SCRIPTS_DIR"
  cp -rf "$SRC_DIR"/root/* "$BASE_DIR"
  #rm -r "$SRC_DIR" "$TMP_DIR"/LS-pi.zip
  chown -R $USER:$(id -g -n $USER) "$BASE_DIR" || ((ERR++))
  chown -R $USER:$(id -g -n $USER) "$INSTALL_SCRIPTS_DIR" || ((ERR++))
  chmod -R +x "$BASE_DIR"/*.sh
  chmod -R +x "$INSTALL_SCRIPTS_DIR"/*.sh
  sleep 2
fi


# ==============================================================================
# Copy and configure cronscripter_settings
# ==============================================================================

echo ">>> Copying and modifying cronscripter_settings file..."
# Modify settings in cronscripter_settings
if [[ $HARDWARE == 'Raspberry Pi' ]]; then
  cp -f $INSTALL_SCRIPTS_DIR/template_files/cronscripter_settings_rpi4 $BASE_DIR/cronscripter_settings
elif [[ $HARDWARE == 'Terrameter LS' ]]; then
  cp -f $INSTALL_SCRIPTS_DIR/template_files/cronscripter_settings_LS $BASE_DIR/cronscripter_settings
fi

# search and replace placeholder text
sed -i "{s#^[[:space:]]*RUN_TERRAMETER=.*#RUN_TERRAMETER=$RUN_TERRAMETER#}" $BASE_DIR/cronscripter_settings
sed -i "{s#^[[:space:]]*LOGDIR=.*#WLOGDIR=\"$LOGDIR\"#}" $BASE_DIR/cronscripter_settings
sed -i "{s#^[[:space:]]*USB_MOUNT_POINT=.*#USB_MOUNT_POINT=\"$USB_MOUNT_POINT\"#}" $BASE_DIR/cronscripter_settings
sed -i "{s#^[[:space:]]*SERVER_IP=.*#SERVER_IP=\"$SERVER_IP\"#}" $BASE_DIR/cronscripter_settings
sed -i "{s#^[[:space:]]*PORT=.*#PORT=\"$PORT\"#}" $BASE_DIR/cronscripter_settings





# ==============================================================================
# Setting the locale
# ==============================================================================

# make sure da_DK.UTF-8 locale is installed
echo
echo
echo '>>> Make sure da_DK.UTF-8 locale is installed'
locale_commentout=$(sed -n 's/\(#\).*da_DK.UTF-8 UTF-8/1/p' /etc/locale.gen)
if [[ $locale_commentout -ne 1 ]]; then
  echo 'Seems da_DK.UTF-8 locale has been installed, skip this step.'
else
  sed -i.bak 's/^.*\(da_DK.UTF-8[[:blank:]]\+UTF-8\)/\1/' /etc/locale.gen
  locale-gen
fi

systemctl enable console-setup
systemctl restart console-setup


# ==============================================================================
# Setting up time sync
# ==============================================================================

# store curren crontab in temporary file
(crontab -l 2>/dev/null || true) > "$TMP_DIR"/cron_tmp.txt



# Section does exist, do conditional insert
match=$(grep 'ntp_update.sh' /etc/ssh/sshd_config)
match=$(echo -e "$match" | sed -e 's/^[[:space:]]*//')
if [[ -z "$match" ]]; then
    # if line is missing, insert it at end of file
    echo "@ boot    /usr/bin/bash  $BASE_DIR/ntp_update" >> "$TMP_DIR"/cron_tmp.txt 
    echo "* */4  *  *  *     /usr/bin/bash  $BASE_DIR/ntp_update" >> "$TMP_DIR"/cron_tmp.txt 
    echo "Inserted ntp_update.sh in cronfile"
elif [[  "$match" == "#"* ]]; then
    # if line is commented, remove it
    echo "Found commented line, deleting it and inserting..."
    sed -i "/ntp_update/d" "$TMP_DIR"/cron_tmp.txt 
    echo "@ boot             /usr/bin/bash  $BASE_DIR/ntp_update" >> "$TMP_DIR"/cron_tmp.txt 
    echo "* */4  *  *  *     /usr/bin/bash  $BASE_DIR/ntp_update" >> "$TMP_DIR"/cron_tmp.txt 
else
    echo "Found line, deleting and inserting..."
    sed -i "/ntp_update/d" "$TMP_DIR"/cron_tmp.txt 
    echo "@ boot             /usr/bin/bash  $BASE_DIR/ntp_update" >> "$TMP_DIR"/cron_tmp.txt 
    echo "* */4  *  *  *     /usr/bin/bash  $BASE_DIR/ntp_update" >> "$TMP_DIR"/cron_tmp.txt 
fi

## Install crontab...
#cat "$TMP_DIR"/cron_tmp.txt | /usr/bin/crontab -

## Remove temporary file
#rm "$TMP_DIR"/cron_tmp.txt




# ==============================================================================
# Removing unwanted packages
# ==============================================================================

echo
echo ">>> Removing some packages that are not needed ..."
apt remove -y dphys-swapfile
apt remove -y --purge wolfram-engine triggerhappy xserver-common lightdm
apt remove -y --purge bluez
apt autoremove -y --purge




# ==============================================================================
# Clean up
# ==============================================================================


echo
if [ $ERR -eq 0 ]; then
  echo '>>> All done. Please reboot your Pi :-)'
else
  echo '>>> Something went wrong. Please check the messages above :-('
fi