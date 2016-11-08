Building Ubuntu/Debian installation for OrangePI H3 boards using debootstrap
============================================================================

- Read and edit **params.sh** to adjust the parameters to your needs.<br/>
- Run `sudo ./create_image` to build the Linux installation according to settings in params.sh<br/>

- WIFI script usage:
    I want to use wifi easily at cafe!

    It's a shell script based on freebsd installer wlanconfig!

    Usage:
        /bin/wifimgr               default
        /bin/wifimgr -l/list       use saved configured network, do not scan. So make sure the AP exist.
        /bin/wifimgr stop          stop wifi connection
        /bin/wifimgr reconfig      re-configure device
        /bin/wifimgr newconf       create new /etc/wpa_supplicant.conf
        /bin/wifimgr addif         if not set rc.conf wlan configure; means does not exist wlan0 currently.
        /bin/wifimgr ns 127.0.0.1  set this nameserver
        /bin/wifimgr help/-h/--help


    usually, run wifimgr without any argument is fine!

    And Backup your /etc/wpa_supplicant.conf before you know about this script.
