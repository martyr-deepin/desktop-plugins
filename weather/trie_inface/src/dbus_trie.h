#ifndef __DBUS_TRIE_H__
#define __DBUS_TRIE_H__

#include "zh_trie.h"

#define DBUS_TRIE_NAME	"com.deepin.zh_trie"
#define DBUS_TRIE_PATH	"/com/deepin/zh_trie"
#define DBUS_TRIE_INFACE	"com.deepin.zh_trie"

int dbus_zh_trie();
char *dbus_create_trie(char **str, int len);
GArray *dbus_search_trie(const char *keys, const char *decrypt);
void dbus_destroy_trie();
void finalize_dbus_loop();

#endif
