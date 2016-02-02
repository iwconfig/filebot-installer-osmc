#!/bin/bash
[[ $EUID -ne 0 ]] && echo "Run as root" 2>&1 && exit 1
clear
export LANG="en_US.UTF-8"
trap ctrl_c SIGINT
function ctrl_c() {
echo -e "\n\nQUIT:"
exit 1
}

# Uninstall Java 8 JDK
java=( $((update-alternatives --get-selections) 2> /dev/null | grep java | awk '{print $3}') )
if [[ ! $(ls -d /opt/jdk* 2> /dev/null) ]] && [[ "${java[@]%/*/*}" == "" ]]; then
echo -e "| Java 8 JDK\t\t\t\t- not installed."
else
echo -ne "|| Java 8 JDK\t\t\t\t- removing files..."
[[ $(ls -d /opt/jdk* 2> /dev/null) ]] && rm -rf /opt/jdk*
if [[ ! "${java[@]%/*/*}" == "" ]]; then
(update-alternatives --remove java "${java[0]}"
update-alternatives --remove javac "${java[1]}") 2> /dev/null
fi
echo -e "\r\033[K||| Java 8 JDK\t\t\t\t- uninstalled."
fi

# Uninstall JNA
if [[ ! -e /usr/lib/jni/libjnidispatch.so ]] && [[ ! $(ls /usr/share/java/jna*.jar 2> /dev/null) ]]; then
echo -e "| JNA\t\t\t\t\t- not installed."
else
echo -ne "|| JNA\t\t\t\t\t- removing files..."
rm -r /usr/lib/jni /usr/share/java
echo -e "\r\033[K||| JNA\t\t\t\t\t- uninstalled."
fi

# Uninstall Filebot
cd /usr/share/filebot &> /dev/null
if [ ! -e filebot.sh ] && [[ ! $(ls /usr/bin/filebot* 2> /dev/null) ]];then
echo -e "| Filebot\t\t\t\t- not installed."
else
echo -ne "|| Filebot\t\t\t\t- removing files..."
rm -rf data
rm -rf FileBot.jar
rm -rf filebot.sh
rm -rf update-filebot.sh
rm -rf /usr/bin/filebot
rm -rf /usr/bin/filebot-update
echo -e "\r\033[K||| Filebot\t\t\t\t- uninstalled."
fi

# Uninstall Mediainfo library
if [ ! -e libzen.so.0 ] && [ ! -e libmediainfo.so.0 ]; then
echo -e "| Mediainfo library\t\t\t- not installed."
else
echo -ne "|| Mediainfo library\t\t\t- removing files..."
apt-get -q purge libmediainfo0 -y > /dev/null
rm libzen.so.0
rm libmediainfo.so.0
echo -e "\r\033[K||| Mediainfo library uninstalled."
fi

# Uninstall 7-zip JBinding library
if [ ! -e lib7-Zip-JBinding.so ]; then
echo -e "| 7-zip JBinding library\t\t- not installed."
else
echo -ne "|| 7-zip JBinding library\t\t- removing files..."
rm lib7-Zip-JBinding.so
echo -e "\r\033[K||| 7-zip JBinding library uninstalled."
fi

# Uninstall fpcalc
if [ ! -e fpcalc ]; then
echo -e "| Music fingerprint utility fpcalc\t- not installed."
else
echo -ne "|| Music fingerprint utility fpcalc\t- removing files..."
rm fpcalc
echo -e "\r\033[K||| Music fingerprint utility fpcalc\t- uninstalled."
fi

rm -rf /usr/share/filebot
echo DONE
exit
