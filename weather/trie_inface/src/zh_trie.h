#ifndef __MY_TRIE_H__
#define __MY_TRIE_H__

#include "dbus_common.h"

#define BUF_LEN	20
#define EN_LEN	26

struct my_trie {
	int flag;	//是否有下标被存储
	int *num;	//存储词组下标
	int cnt;	//下标的个数
	char ch;
	struct my_trie *next[EN_LEN];
};

struct my_trie *trie_create_node(char ch);
int char_to_index(char ch);
struct my_trie *trie_init();
void trie_insert(const char *keys, int num, struct my_trie *root);
int *trie_find(const char *keys, int *num, struct my_trie *root);
void trie_destroy(struct my_trie *cur_trie);

#endif
