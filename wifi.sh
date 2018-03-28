#
# @hmenn 29.03.18
#

COLOR_OFF='\033[0m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'

ORIG_INTERFACE_FILE="interfaces.orig"
ORIG_INTERFACE_HOTSPOT_FILE="interfaces_hotspot.orig"
DEFAULT_INTERFACE_PATH="/etc/network/interfaces"

ORIG_HOSTAPD_FILE="hostapd.conf.orig"
DEFAULT_HOSTAPD_CONF_PATH="/etc/hostapd/hostapd.conf"

ORIF_DNSMASQ_FILE="dnsmasq.conf.orig"
DEFAULT_DNSMASQ_CONF_PATH="/etc/dnsmasq.conf"


print_message(){
    echo -e $1 $2 ${COLOR_OFF}
}

prepare(){
    # install required packages
    print_message ${COLOR_GREEN} "Prepare/Install required packages"
    sudo apt-get update
    print_message ${COLOR_GREEN} "Installing hostapd"
    sudo apt-get install hostapd
    print_message ${COLOR_GREEN} "Installing dnsmasq"    
    sudo apt-get install dnsmasq
    print_message ${COLOR_GREEN} "Stopping dnsmasq and hostapd services"
    sudo systemctl stop hostapd
    sudo systemctl stop dnsmasq
    
    print_message ${COLOR_GREEN} "Prepare interfaces, hostapd.conf and dnsmasq.conf file"
    sudo cp ${ORIG_INTERFACE_FILE} ${DEFAULT_INTERFACE_PATH}
    sudo cp ${ORIG_HOSTAPD_FILE} ${DEFAULT_HOSTAPD_CONF_PATH}
    sudo cp ${ORIF_DNSMASQ_FILE} ${DEFAULT_DNSMASQ_CONF_PATH}

    print_message ${COLOR_GREEN} "Prepare done."
}

open_client(){
    print_message ${COLOR_GREEN} "ACTIVATING WIFI-CLIENT MODE..."
    sudo ifdown wlan0
    sudo systemctl stop hostapd
    sudo systemctl disable hostapd

    sudo systemctl stop dnsmasq
    sudo systemctl disable dnsmasq

    sudo cp ${ORIG_INTERFACE_FILE} ${DEFAULT_INTERFACE_PATH}
    sudo ifup wlan0
    print_message ${COLOR_GREEN} "WIFI-CLIENT MODE ACTIVE"
}


open_hotspot(){
    print_message ${COLOR_GREEN} "ACTIVATING WIFI-HOTSPOT MODE"
    sudo ifdown wlan0
    sudo systemctl start hostapd
    sudo systemctl enable hostapd

    sudo systemctl start dnsmasq
    sudo systemctl enable dnsmasq    

    sudo cp ${ORIG_INTERFACE_HOTSPOT_FILE} ${DEFAULT_INTERFACE_PATH}    
    sudo ifup wlan0
    print_message ${COLOR_GREEN} "WIFI-HOTSPOT MODE ACTIVE"
}


case $1 in
    prepare)
        prepare
        ;;
    open_client)
        open_client
        ;;
    open_hotspot)
        open_hotspot
        ;;
    *)
        echo "Invalid parameter"
esac
