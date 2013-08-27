#ifndef __DBUS_DATABASE_H__
#define __DBUS_DATABASE_H__

#include "dbus_common.h"

#define DBUS_PINYIN_NAME    "com.deepin.zh_pinyin"
#define DBUS_PINYIN_PATH    "/com/deepin/zh_pinyin"
#define DBUS_PINYIN_INFACE  "com.deepin.zh_pinyin"

void dbus_pinyin();
void dbus_insert_pinyin(const char *file_path);
char *dbus_get_pinyin(const char *cmd_buf);
void finalize_dbus_loop();

#endif
