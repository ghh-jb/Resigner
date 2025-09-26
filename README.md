# Resigner
Tool to resign all binaries with ldid.
Will recursively enter directories and walk all files there.
If file is a mach-o it will try to sign it with ldid.
# Usage
```
Resigner 
```
After that it will promt for path from which to start.
# Installing
1) ldid must be installed to /usr/bin/ldid
2) Tool must be run as root
# Building
Install theos and download 15.2 SDK
cd into project dir and run:
```
make package
```
And after that simply install it via sileo.
# Purpose
I am working on Dopamine_Rootful and this tool is needed to resign all system binaries from /usr, /bin and others, moved to preboot. 
Otherwise they crash with err 85 (need to figure out why).

# License
MIT. See the `LICENSE` file.
