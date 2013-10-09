#include "zh_trie.h"


struct my_trie *
trie_init()
{
	struct my_trie *root = NULL;
	root = trie_create_node(' ');
	if ( root == NULL ) {
		sys_err("init trie failed...\n");
		return NULL;
	}

	return root;
}

struct my_trie*
trie_create_node(char ch)
{
	int i = 0;

	struct my_trie *node = (struct my_trie*)malloc(sizeof(struct my_trie));
	if ( node == NULL ) {
		sys_err("malloc failed in create new node...\n");
		return NULL;
	}
	memset(node, 0, sizeof(struct my_trie));

	node->ch = ch;
	node->flag = 0;
	for ( ; i < EN_LEN; i++ ) {
		node->next[i] = NULL;
	}

	return node;
}

int
char_to_index(char ch)
{
	return ch - 'a';
}

void
trie_insert(const char *keys, int num, struct my_trie *root)
{
	if ( keys == NULL || root == NULL ) {
		sys_err("insert arguments NULL...\n");
		return ;
	}

	struct my_trie *cur_trie = root;
	int i = 0;
	int len = strlen(keys);
	int *ptr = NULL;

	for ( ; i < len; i++ ) {
		//sys_says("ch : %c\n", *(keys + i));
		if ( cur_trie->next[char_to_index(*(keys + i))] == NULL ) {
			cur_trie->next[char_to_index(*(keys + i))] = 
				trie_create_node(*(keys + i));
		}
		cur_trie = cur_trie->next[char_to_index(*(keys + i))];
		//sys_says("cur_trie : %c\n", cur_trie->ch);
	}

	int tt = 0;
	//sys_says("\ninsert values...\n");
	if ( cur_trie != root ) {
		cur_trie->cnt++;
		tt = cur_trie->cnt - 1;

		if ( cur_trie->flag == 0 ) {
			cur_trie->num = (int *)malloc(1 * sizeof(int));
			if ( cur_trie->num == NULL ) {
				return ;
			}
			memset(cur_trie->num, 0, sizeof(int));

			*cur_trie->num = num;
			cur_trie->flag = 1;
		} else {
			ptr = (int *)malloc(cur_trie->cnt * sizeof(int));
			if ( ptr == NULL ) {
				return ;
			}
			memset(ptr, 0, cur_trie->cnt * sizeof(int));

			memcpy(ptr, cur_trie->num, tt * sizeof(int));
			*(ptr + tt) = num;
			free(cur_trie->num);
			cur_trie->num = NULL;
			cur_trie->num = ptr;
		}
	}
	//sys_says("tt : %d\tcur num : %d\n", tt, *(cur_trie->num + tt));

	return ;
}

int *
trie_find(const char *keys, int *num, struct my_trie *root)
{
	if ( keys == NULL || root == NULL ) {
		sys_err("find arguments NULL...\n");
		return NULL;
	}

	int i = 0;
	int flag = 0;
	int len = strlen(keys);
	struct my_trie *cur_trie = root;

	for ( ; i < len; i++ ) {
		if ( cur_trie->next[char_to_index(*(keys + i))] == NULL ) {
			flag = 1;
			break;
		}
		cur_trie = cur_trie->next[char_to_index(*(keys + i))];
	}

	if ( (flag == 1) || (cur_trie->flag == 0) ) {
		return NULL;
	}

	*num = cur_trie->cnt;
	return cur_trie->num;
}

void
trie_destroy( struct my_trie *cur_trie)
{
	int i = 0;

	if ( cur_trie == NULL ) {
		return ;
	}

	for ( ; i < EN_LEN; i++ ) {
		if ( cur_trie->next[i] == NULL ) {
			continue ;
		}
		trie_destroy(cur_trie->next[i]);
	}

	if ( cur_trie->flag == 1 ) {
		free(cur_trie->num);
		cur_trie->num = NULL;
	}
	free(cur_trie);
	cur_trie = NULL;

	return ;
}
