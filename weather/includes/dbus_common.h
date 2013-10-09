#ifndef __DBUS_COMMON_H__
#define __DBUS_COMMON_H__

#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

#include <gio/gio.h>
#include <dbus/dbus-glib.h>

#define sys_err(args ...)   { fprintf(stderr, args); }
#define sys_says(args ...)  { fprintf(stdout, args); }

#endif
