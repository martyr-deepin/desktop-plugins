#ifndef __PARSE_ZH_H__
#define __PARSE_ZH_H__

#include "dbus_trie.h"

#define DBUS_PINYIN_NAME    "com.deepin.zh_pinyin"
#define DBUS_PINYIN_PATH    "/com/deepin/zh_pinyin"
#define DBUS_PINYIN_INFACE  "com.deepin.zh_pinyin"

struct link_info {
	int cnt;
	struct my_trie *root;
	char decrypt[36];
};

void parse_zh(char *zh_str, int len);
void insert_trie_data(char **str, int len, struct my_trie *root);

char *get_str_from_array(char **str, int len);
void cal_md5(char *encrypt, unsigned char *decrypt);

int alloc_info();
char *get_pinyin(const char *pinyin);
struct my_trie *get_root(const char *decrypt);

#endif
