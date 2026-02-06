# lastatus
Exact re-implementation of `/System/Library/Frameworks/LocalAuthentication.framework/Support/lastatus`

### Why?

Apple open sourced their `pam_aks.so` source code, this PAM module is actually calling an external program `lastatus` to check if an user has already unlocked its screen. But `lastatus` was not an open source thing.
