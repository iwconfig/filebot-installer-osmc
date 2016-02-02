#!/bin/bash
[[ $EUID -ne 0 ]] && echo "Run as root" 2>&1 && exit 1
clear
export LANG="en_US.UTF-8"
trap ctrl_c SIGINT
function ctrl_c() {
echo -e "\n\nQUIT: Cleaning temporary files..."
rm -r /tmp/jna*_wget /tmp/jna-* /tmp/filebot* /tmp/jdk*
exit 1
}

# Get Java 8 JDK and install
if [[ $(ls /opt/jdk* 2> /dev/null) ]]; then
echo -e "||| Java 8 JDK\t\t\t\t- Already installed!"
else
echo -ne "| Java 8 JDK\t\t\t\t- downloading..."
javaurl=$(curl -s http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html | \
egrep -o "http\:\/\/download.oracle\.com\/otn-pub\/java\/jdk\/[7-8]u[0-9]+\-(.*)+\/jdk-[7-8]u[0-9]+(.*)linux-arm32-vfp-hflt.tar.gz")
wget -q --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/jdk8.tar.gz "$javaurl"
echo -ne "\r\033[K|| Java 8 JDK\t\t\t\t- installing..."
tar xzf /tmp/jdk8.tar.gz -C /opt/
javapath=$(ls -d /opt/jdk* 2> /dev/null)
(update-alternatives --install "/usr/bin/java" "java" "${javapath}/bin/java" 1
update-alternatives --install "/usr/bin/javac" "javac" "${javapath}/bin/javac" 1
update-alternatives --config java
update-alternatives --config javac) > /dev/null
rm -f /tmp/jdk8.tar.gz
echo -e "\r\033[K|||| Java 8 JDK\t\t\t\t- INSTALLED!"
fi

# Get and install JNA
if [[ -e /usr/lib/jni/libjnidispatch.so ]] && [[ $(ls /usr/share/java/jna*.jar 2> /dev/null) ]]; then
echo -e "||| JNA\t\t\t\t\t- Already installed!"
else
echo -ne "| JNA\t\t\t\t\t- downloading..."
jnaurl=$(jnaurl=$(curl -s https://maven.java.net/content/repositories/releases/net/java/dev/jna/jna/ | grep -e '[0-9]/' | sort -nr | head -n1 | cut -d'"' -f2); \
curl -s "$jnaurl" | egrep "[0-9][0-9.]*.jar<" | cut -d'"' -f2)
jnaplatformurl=$(jnaplatformurl=$(curl -s https://maven.java.net/content/repositories/releases/net/java/dev/jna/jna-platform/ | grep -e '[0-9]/' | sort -nr | head -n1 | cut -d'"' -f2); \
curl -s "$jnaplatformurl" | egrep "[0-9][0-9.]*.jar<" | cut -d'"' -f2)
(wget -P /tmp/ "$jnaurl") &> /tmp/jna_wget
(wget -P /tmp/ "$jnaplatformurl") &> /tmp/jnaplatform_wget
echo -ne "\r\033[K|| JNA\t\t\t\t\t- installing..."
apt-get install libjna-java -y > /dev/null
jna_version=$(cat /tmp/jna_wget | grep "Saving to:" | cut -d"'" -f2 | sed 's/[^.0-9]//g')
jnaplatform_version=$(cat /tmp/jnaplatform_wget | grep "Saving to:" | cut -d"'" -f2 | sed 's/[^.0-9]//g')
mkdir /tmp/jna-${jna_version%?}
unzip -q -o /tmp/jna-${jna_version%?}.jar -d /tmp/jna-${jna_version%?}
mkdir /tmp/jna-platform-${jnaplatform_version%?}
unzip -q -o /tmp/jna-platform-${jnaplatform_version%?}.jar -d /tmp/jna-platform-${jnaplatform_version%?}
[ ! -d /usr/lib/jni ] && mkdir /usr/lib/jni
cd /usr/lib/jni
cp -p /tmp/jna-${jna_version%?}/com/sun/jna/linux-arm/libjnidispatch.so libjnidispatch_${jna_version%?}.so
[ -e /usr/lib/jni/libjnidispatch.so ] && rm libjnidispatch.so
ln -s -f libjnidispatch_${jna_version%?}.so libjnidispatch.so
[ ! -d /usr/share/java ] && mkdir /usr/share/java
cd /usr/share/java
[ -e jna.jar ] && [ -e jna-platform.jar ] && rm jna.jar jna-platform.jar
cp /tmp/jna-${jna_version%?}.jar .
cp /tmp/jna-platform-${jnaplatform_version%?}.jar .
ln -s -f jna-${jna_version%?}.jar jna.jar
ln -s -f jna-platform-${jnaplatform_version%?}.jar jna-platform.jar
rm -r -f /tmp/jna*_wget /tmp/jna*.jar /tmp/jna-${jna_version%?} /tmp/jna-platform-${jnaplatform_version%?}
echo -e "\r\033[K|||| JNA\t\t\t\t- INSTALLED!"
fi

# Get Filebot and install
if [[ $(ls /usr/share/filebot/* 2> /dev/null) ]] && [[ $(ls /usr/bin/filebot* 2> /dev/null) ]];then
echo -e "||| Filebot\t\t\t\t- Already installed!"
else
echo -ne "\r\033[K| Filebot\t\t\t\t- downloading..."
wget -q -O /tmp/filebot.zip "https://app.filebot.net/download.php?type=portable"
echo -ne "\r\033[K|| Filebot\t\t\t\t- installing..."
[ ! -d /usr/share/filebot ] && mkdir /usr/share/filebot
unzip -q -o /tmp/filebot.zip -x {*.exe,*.cmd,*.ini} -d /usr/share/filebot
ln -s -f /usr/share/filebot/filebot.sh /usr/bin/filebot
ln -s -f /usr/share/filebot/update-filebot.sh /usr/bin/filebot-update
rm /tmp/filebot.zip
echo -e "\r\033[K|||| Filebot\t\t\t\t- INSTALLED!"
fi

# Install Mediainfo library
if [ -e /usr/share/filebot/libzen.so.0 ] && [ -e /usr/share/filebot/libmediainfo.so.0 ]; then
echo -e "||| Mediainfo library\t\t\t- Already installed!"
else
echo -ne "\r\033[K|| Mediainfo library\t\t\t- installing..."
apt-get install libmediainfo0 -y > /dev/null
cd /usr/share/filebot
ln -s -f /usr/lib/arm-linux-gnueabihf/libzen.so.0 libzen.so.0
ln -s -f /usr/lib/arm-linux-gnueabihf/libmediainfo.so.0 libmediainfo.so.0
echo -e "\r\033[K|||| Mediainfo library\t\t\t- INSTALLED!"
fi

# Get 7-zip JBinding library and install
if [ -e /usr/share/filebot/lib7-Zip-JBinding.so ]; then
echo -e "||| 7-zip JBinding library\t\t- Already installed!"
else
echo -ne "\r\033[K|| 7-zip JBinding library\t\t- downloading..."
wget -q -P /usr/share/filebot/ https://svn.code.sf.net/p/filebot/code/trunk/lib/native/linux-arm/lib7-Zip-JBinding.so
echo -ne "\r\033[K|| 7-zip JBinding library\t\t- installing..."
sed -i '/hej/s/[^\B] //g' /usr/share/filebot/filebot.sh
echo -e "\r\033[K|||| 7-zip JBinding library\t\t- INSTALLED!"
fi

# Get fpcalc and install
if [ -e /usr/share/filebot/fpcalc ]; then
echo -e "||| Music fingerprint utility fpcalc\t- Already installed!"
else
echo -ne "\r\033[K|||| Music fingerprint utility fpcalc\t- downloading..."
wget -q https://svn.code.sf.net/p/filebot/code/trunk/lib/native/linux-arm/fpcalc
echo -e "\r\033[K|||| Music fingerprint utility fpcalc\t- INSTALLED!"
fi

echo DONE

if [ -e /usr/bin/filebot ] && [ -e /usr/bin/filebot-update ]; then
echo -e "\t\tLinked executables:"
echo -e "\t\t  · /usr/bin/filebot"
echo -e "\t\t  · /usr/bin/filebot-update"
echo -e "\nChecking/updating latest version of filebot"
filebot-update &> /dev/null
fi

exit
