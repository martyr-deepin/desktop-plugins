#include "parse_zh.h"
#include "md5.h"

char py_array[10];
extern int count;
extern int num_size;
extern struct link_info *ctrl_info;

char *get_pinyin(const char *pinyin)
{
	DBusGConnection *connection;
	GError *error;
	DBusGProxy *proxy;
	char *ret_num = NULL;

	error = NULL;
	connection = dbus_g_bus_get (DBUS_BUS_SESSION, &error);
    if (connection == NULL) {
		g_printerr ("Failed to open connection to bus: %s\n",
                  error->message);
		g_error_free (error);
		exit (1);
    }
	proxy = dbus_g_proxy_new_for_name (connection,
                                     DBUS_PINYIN_NAME,
                                     DBUS_PINYIN_PATH,
                                     DBUS_PINYIN_INFACE);

	error = NULL;
	if (!dbus_g_proxy_call (proxy, "dbus_get_pinyin", &error, 
						G_TYPE_STRING, pinyin, 
  						G_TYPE_INVALID,
						G_TYPE_STRING, &ret_num, G_TYPE_INVALID)) {
		if ((error->domain == DBUS_GERROR) && 
				(error->code == DBUS_GERROR_REMOTE_EXCEPTION)) {
			g_printerr ("Caught remote method exception %s: %s",
						dbus_g_error_get_name (error), error->message);
		} else {
			g_printerr ("Error: %s\n", error->message);
			g_printerr ("Error: %s\n", error->message);
		}
		
		g_error_free (error);
		exit (1);
	}
	
	if ( ret_num == NULL ) {
		g_printerr("return false\n");
		return NULL;
	} else {
		g_printerr("ret : %s\n", ret_num);
	}

	g_object_unref (proxy);

	return ret_num;
}

char *get_str_from_array(char **str, int len)
{
	if ( str == NULL ) {
		sys_err("argument error in get string from array...\n");
		return NULL;
	}

	char *ptr = NULL;
	char *tmp = NULL;
	char *encrypt = NULL;
	int i = 0;
	int size = 0;
	int err_flag = 0;

	//sys_says("get string...\n");
	for ( ; i < len; i++ ) {
		tmp = *(str + i);
		size += strlen(tmp);
		//sys_says("tmp : %s\tsize : %d\n", tmp, size);

		if ( encrypt == NULL ) {
			//sys_says("first calloc...\n");
			encrypt = (char*)calloc(1, (size + 1) * sizeof(char));
			if ( encrypt == NULL ) {
				sys_err("first calloc failed ...\n");
				err_flag = 1;
				break;
			}
			memcpy(encrypt, tmp, strlen(tmp));
		} else {
			//sys_says("%d calloc...\n", i);
			ptr = (char*)calloc(1, (size + 1) * sizeof(char));
			if ( ptr == NULL ) {
				sys_err("calloc failed ...\n");
				err_flag = 1;
				break;
			}

			int tt = strlen(encrypt);
			//sys_says("tt : %d\tencrypt : %s\n", tt, encrypt);
			memcpy(ptr, encrypt, tt);
			memcpy(ptr + tt, tmp, strlen(tmp));
			free(encrypt);
			encrypt = NULL;
			encrypt = ptr;
		}
		//sys_says("%d : %s\n", i, encrypt);
	}
	ptr = NULL;
	tmp = NULL;

	if ( err_flag == 1 ) {
		return NULL;
	}
	//sys_says("encrypt : %s\n", encrypt);
	return encrypt;
}

void cal_md5(char *encrypt, unsigned char *decrypt)
{
	MD5_CTX md5;

	//sys_says("cal md5...\n");
	memset(&md5, 0, sizeof(MD5_CTX));
	MD5Init(&md5);
	MD5Update(&md5, (unsigned char*)encrypt, (unsigned int)strlen(encrypt));
	MD5Final(&md5, decrypt);
	sys_says("encrypt : %s\n", encrypt);

	free(encrypt);
	encrypt = NULL;

	return ;
}

/*
 * 传入一组词，获得每个字的首字母
 */

void parse_zh(char *zh_str, int len)
{
	if ( zh_str == NULL ) {
		return ;
	}

	int i = 0;
	int j = 0;
	char *tmp = NULL;
	char *pinyin = NULL;

	//sys_says("zh : %s\tlen : %d\n", zh_str, len);
	memset(py_array, 0, 10);
	for ( ; i < len / 3; i++ ) {
		tmp = zh_str + (j * 3);
		//sys_says("tmp zi : %s\n", tmp);
		pinyin = get_pinyin(tmp);
		py_array[j] = *pinyin;
		j++;
	}
}

void insert_trie_data(char **str, int len, struct my_trie *root)
{
	int i = 0;
	char *tmp = NULL;

	if ( str == NULL ) {
		sys_err("argument is NULL in create relate...\n");
		return ;
	}

	//sys_says("insert i : %d\n", i);
	for (i = 0; i < len; i++ ) {
		memset(py_array, 0, 10);
		tmp = *(str + i);
		//sys_says("tmp : %s\n", tmp);
		parse_zh(tmp, strlen(tmp));
		if ( py_array[0] == '\0' ) {
			continue ;
		}
		sys_says("pinyin : %s\ti : %d\n", py_array, i);
		trie_insert(py_array, i, root);
	}
}

struct my_trie *get_root(const char *decrypt)
{
	int i = 0;
	int flag = 0;
	struct link_info *tmp = ctrl_info;
	
	if ( decrypt == NULL || tmp == NULL) {
		sys_err("get root arg error\n");
		return NULL;
	}
	
	while ( i < count ) {
		if ( strncmp(decrypt, ctrl_info[i].decrypt, 32) == 0 ) {
			flag = 1;
			sys_says("get root successful...\n");
			break;
		}
		i++;
	}
	
	if ( flag == 0 ) {
		sys_says("get root failed...\n");
		return NULL;
	}
	return ctrl_info[i].root;
}

int alloc_info()
{
	struct link_info *tmp = NULL;
	
	if ( count == 0 ) {
		ctrl_info = (struct link_info*)calloc(++count, sizeof(struct link_info));
		if ( ctrl_info == NULL ) {
			sys_err("first calloc failed ...\n");
			return -1;
		}
	} else {
		tmp = (struct link_info*)calloc(++count, sizeof(struct link_info));
		if ( tmp == NULL ) {
			sys_err("calloc failed ...\n");
			return -1;
		}
		
		memcpy(tmp, ctrl_info, (count - 1) * sizeof(struct link_info));
		free(ctrl_info);
		ctrl_info = NULL;
		ctrl_info = tmp;
		tmp = NULL;
	}
	
	return 0;
}

char *dbus_create_trie(char **str_list, int len)
{
	char *encrypt = NULL;
	unsigned char decrypt[16];
	struct link_info *cur_info = NULL;
	
	sys_says("alloc info...\n");
	memset(decrypt, 0, 16);
	if ( alloc_info() == -1 ) {
		sys_err("alloc info failed...\n");
		return NULL;
	}
	cur_info = ctrl_info + count - 1;
	
	sys_says("get str from array...\n");
	encrypt = get_str_from_array(str_list, len);
	if ( encrypt == NULL ) {
		sys_err("get str from array faile...\n");
		return NULL;
	}
	cal_md5(encrypt, decrypt);
	sys_says("get md5...\n");

	sys_says("decrypt : ");
	int i = 0;
	for ( ; i < 16; i++ ) {
		sys_says("%02x", *(decrypt + i));
		sprintf(cur_info->decrypt, "%s%02x", 
						cur_info->decrypt, *(decrypt + i));
	}
	sys_says("\n");
	//sys_says("ctrl md5 : %s\n\n", cur_info->decrypt);
	
	cur_info->cnt = count - 1;
	cur_info->root = trie_init();
	insert_trie_data(str_list, len, cur_info->root);
	
	return (char*)(cur_info->decrypt);
}

GArray *dbus_search_trie(const char *keys, const char *decrypt)
{
	int i = 0;
	int *tmp = NULL;
	GArray *array = NULL;
	struct my_trie *cur_root = NULL;
	
	cur_root = get_root(decrypt);
	if ( cur_root == NULL ) {
		return NULL;
	}
	
	tmp = trie_find(keys, &num_size, cur_root);
	
	array = g_array_new(FALSE, FALSE, sizeof(gint));
	for (; i < num_size; i++ ) {
		//sys_says("value : %d\n", *(tmp+i));
		g_array_append_val(array, *(tmp + i));
		//sys_says("%d ", g_array_index(array, gint, i));
	}
	//sys_says("\n\n");

	return array;
}

void dbus_destroy_trie()
{
	int i = 0;
	
	for (i = 0; i < count; i++) {
		trie_destroy(ctrl_info[i].root);
	}
	free(ctrl_info);
}
