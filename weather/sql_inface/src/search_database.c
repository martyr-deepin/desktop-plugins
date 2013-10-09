#include "dbus_database.h"
#include <sqlite3.h>

#define ZH_LEN 4
#define EN_LEN 7
#define EXEC_BUF 	80
#define READ_LINE	256
#define DATABASE_PATH	"/usr/share/deepin-speech/DeepinSpeech.db"

static int search_zhcn_callback(void *data, int col_num, 
							char **col_value, char **col_name);

void dbus_insert_pinyin(const char *file_path)
{
	char sql[100];
	char zh[ZH_LEN];
	char en[EN_LEN];
	FILE *fp = NULL;
	sqlite3 *db = NULL;
	char *err_msg = NULL;
	
	if ( file_path == NULL ) {
		sys_says("insert pinyin argument error...\n");
		return ;
	}

	if ( (fp = fopen(file_path, "r")) == NULL ) {
		sys_says("open file failed...\n");
		return ;
	}
	
	if ( SQLITE_OK != sqlite3_open(DATABASE_PATH, &db) ) {
		sys_says("search_table sqlite3_open failed...\n");
		return ;
	}
	
	while ( !feof(fp) ) {
		memset(zh, 0, ZH_LEN);
		memset(en, 0, EN_LEN);
		memset(sql, 0, 100);
		
		fscanf(fp, "%s %s", zh, en);
		//sys_says("zh : %s\ten : %s\n", zh, en);
		
		if ( zh[0] == '\0' ) {
			continue;
		}
		sprintf(sql, "insert into zhIndex(zhcn, pinyin) \
				values(\'%s\', \'%s\')", zh, en);
		if ( SQLITE_OK != sqlite3_exec( db, sql, 0, 0, &err_msg ) ) {
			sys_says("zh : %s\ten : %s\n", zh, en);
			sys_says("sqlite3_exec failed...\n");
			break;				
		}
	}
	fclose(fp);
	if ( SQLITE_OK != sqlite3_close(db) ) {
		sys_says("sqlite3_close failed...\n");
		return ;
	}
	
	return ;
}

char *dbus_get_pinyin(const char *cmd_buf)
{
	char tmp[4];
	char cmd[READ_LINE];
	char buf[EXEC_BUF];
	sqlite3 *db = NULL;
	char *err_msg = NULL;
	char sql[READ_LINE];
	char *pinyin = NULL;

	/* 打开内存数据库 */
	if ( SQLITE_OK != sqlite3_open(DATABASE_PATH, &db) ) {
		sys_err("search_table sqlite3_open failed...\n");
	}
	
	memset(cmd, 0, READ_LINE);
	
	while ( *cmd_buf != '\0' ) {
		memset(tmp, 0, 4);
		memset(buf, 0, EXEC_BUF);
		memset(sql, 0, READ_LINE);
		
		memcpy(tmp, cmd_buf, 3);
		sys_says("tmp : %s\n", tmp);
		sprintf( sql, "select pinyin from zhIndex where zhcn=\'%s\'", tmp );
		/* 查询， 并调用回调函数 */
		if ( SQLITE_OK != sqlite3_exec( db, sql, search_zhcn_callback, 
								buf, &err_msg ) ) {
			sys_err("search_table sqlite3_exec failed...\n");			
		}
		sys_says("buf : %s\n", buf);
		if ( buf[0] != '\0' )
			strcat(cmd, buf);
		sys_says("cmd_buf : %s\n", cmd_buf);
		cmd_buf += 3;
	}
	
	if ( SQLITE_OK != sqlite3_close(db) ) {
		sys_err("search_table sqlite3_close failed...\n");	
	}
	
	sys_says("cmd : %s\n", cmd);
	if ( cmd[0] != '\0' ) {
		pinyin = (char*)calloc(1, strlen(cmd) + 1);
		if ( pinyin == NULL ) {
			return NULL;
		}
		memcpy(pinyin, cmd, strlen(cmd));
	}
	
	return pinyin;
}

static int search_zhcn_callback(void *data, int col_num, 
							char **col_value, char **col_name)
{
	int i;
	char *buf = (char*)data;

	for ( i = 0; i < col_num; i++ ) {
		printf( "%s = %s \n", col_name[i], col_value[i] ? col_value[i] : "NULL" );
		if ( strcmp("pinyin", col_name[i]) == 0 ) {
			//memset(buf, 0, EXEC_BUF);
			strcpy(buf, col_value[i]);
		}
	}
	sys_says("buf : %s\n", buf);

	return 0;
}
