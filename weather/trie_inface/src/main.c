#include "parse_zh.h"
#include <glib.h>

int count = 0;
int num_size = 0;
struct link_info *ctrl_info = NULL;

int main()
{
	dbus_zh_trie();
	dbus_destroy_trie();
	
	return 0;
}
