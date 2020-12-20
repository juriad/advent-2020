There are several packages (`gnustep-base`, `agnustep-base`, `gcc-objc`).


Run as:
```
. /usr/share/GNUstep/Makefiles/GNUstep.sh
gcc `gnustep-config --objc-flags` -lgnustep-base -lobjc prg.m -o prg
./prg input
```
