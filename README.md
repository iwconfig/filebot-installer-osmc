# filebot-installer-osmc

Installs Filebot and dependencies on OSMC.
- Filebot
- Java 8 JDK
- JNA
- libmediainfo library
- 7-Zip JBindings library
- fpcalc

Also includes an uninstaller.

### How to:
User must be have root privileges.

###### Install
`sudo ./install_filebot-osmc.sh`

###### Uninstall
`sudo ./uninstall_filebot-osmc.sh`

___
### Todos or thoughts:
- Cleanup. This code is messy and hard to read. I sometimes wonder why I insisted on no use of indentation. argh...
- Maybe rewrite in python instead.
