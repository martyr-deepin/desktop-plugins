#include "dbus_trie.h"

#include <gio/gio.h>
#include <glib.h>
#include <dbus/dbus-glib.h>
#include <glib-object.h>

//internal functions
static gboolean _retry_registration (gpointer user_data);
static void _on_bus_acquired (GDBusConnection * connection, const gchar * name, gpointer user_data);
static void _on_name_acquired (GDBusConnection * connection, const gchar * name, gpointer user_data);
static void _on_name_lost (GDBusConnection * connection, const gchar * name, gpointer user_data);
static void _bus_method_call (GDBusConnection * connection, const gchar * sender,
                             const gchar * object_path, const gchar * interface,
                             const gchar * method, GVariant * params,
                             GDBusMethodInvocation * invocation, gpointer user_data);
static gboolean do_exit(gpointer user_data);

static guint lock_service_owner_id;
static guint lock_service_reg_id;        //used for unregister an object path
static guint retry_reg_timeout_id;   //timer used for retrying dbus name registration.
GDBusConnection* lock_connection;

static GDBusNodeInfo *      node_info = NULL;
static GDBusInterfaceInfo *interface_info = NULL;
static GDBusInterfaceVTable interface_table = {
    method_call:   _bus_method_call,
    get_property:   NULL, // No properties 
    set_property:   NULL  // No properties 
};

extern int count;
extern int num_size;
extern struct link_info *ctrl_info;

GMainLoop *loop = NULL;

const char *_lock_dbus_iface_xml = 
"<?xml version=\"1.0\"?>\n"
"<node>\n"
"	<interface name=\""DBUS_TRIE_INFACE"\">\n"
"		<method name=\"dbus_create_trie\">\n"
"			<arg name=\"str_list\" type=\"as\" direction=\"in\">\n"
"			</arg>\n"
"			<arg name=\"size\" type=\"i\" direction=\"in\">\n"
"			</arg>\n"
"			<arg name=\"decrypt\" type=\"s\" direction=\"out\">\n"
"			</arg>\n"
"		</method>\n"
"		<method name=\"dbus_search_trie\">\n"
"			<arg name=\"keys\" type=\"s\" direction=\"in\">\n"
"			</arg>\n"
"			<arg name=\"decrypt\" type=\"s\" direction=\"in\">\n"
"			</arg>\n"
"			<arg name=\"nun_list\" type=\"ai\" direction=\"out\">\n"
"			</arg>\n"
"		</method>\n"
"		<method name=\"dbus_destroy_trie\">\n"
"		</method>\n"
"		<method name=\"finalize_dbus_loop\">\n"
"		</method>\n"
"	</interface>\n"
"</node>\n"
;

int dbus_zh_trie()
{
	loop = g_main_loop_new(NULL, FALSE);

	GError *error = NULL;
	node_info = g_dbus_node_info_new_for_xml (_lock_dbus_iface_xml, &error);
	if ( error != NULL ) {
		g_critical("Unable to parse interface xml: %s\n", error->message);
		g_error_free(error);
	}

	interface_info = g_dbus_node_info_lookup_interface(node_info, 
			DBUS_TRIE_INFACE );
	if ( interface_info == NULL ) {
		g_critical("Unable to find interface '"DBUS_TRIE_INFACE"'");
	}

	lock_service_owner_id = 0;
	lock_service_reg_id = 0;
	retry_reg_timeout_id = 0;
	_retry_registration(NULL);

//	g_timeout_add_seconds( 15, do_exit, NULL );
	g_main_loop_run(loop);

	return 0;
}

void finalize_dbus_loop()
{
	g_main_loop_quit(loop);
}

static gboolean
do_exit(gpointer user_data)
{
	g_main_loop_quit(loop);

	return FALSE;
}

static gboolean
_retry_registration ( gpointer user_data )
{
	lock_service_owner_id = g_bus_own_name( G_BUS_TYPE_SESSION, 
				DBUS_TRIE_NAME, 
				G_BUS_NAME_OWNER_FLAGS_NONE, 
				lock_service_reg_id ? NULL : _on_bus_acquired,
				_on_name_acquired,
				_on_name_lost, 
				NULL, 
				NULL);
	return 0;
}

static void
_on_bus_acquired ( GDBusConnection *connection, 
		const gchar *name, 
		gpointer user_data )
{
	g_debug(" on bus acquired ...\n");

	lock_connection = connection;

	//register object
	GError *error = NULL;
	lock_service_reg_id = g_dbus_connection_register_object( connection, 
			DBUS_TRIE_PATH, 
			interface_info, 
			&interface_table, 
			user_data, 
			NULL, 
			&error );

	if ( error != NULL ) {
		g_critical ( "Unable to register object to the dbus: %s\n", 
				error->message );
		g_error_free(error);
		g_bus_unown_name(lock_service_owner_id);
		lock_service_owner_id = 0;
		retry_reg_timeout_id = g_timeout_add_seconds(1, 
				_retry_registration, NULL );
		return;
	}

	return;
}

static void
_on_name_acquired ( GDBusConnection *connection, 
		const gchar* name, 
		gpointer user_data )
{
	g_debug ( "Dbus name acquired ... \n" );
}

static void
_on_name_lost ( GDBusConnection *connection, 
		const gchar *name, 
		gpointer user_data )
{
	if ( connection == NULL ) {
		g_critical ( "Unable to get a connection to DBus...\n" );
	} else {
		g_critical ( "Unable to claim the name %s\n", DBUS_TRIE_NAME );
	}

	lock_service_owner_id = 0;
}

static void
_bus_method_call (GDBusConnection * connection,
                 const gchar * sender, const gchar * object_path, const gchar * interface,
                 const gchar * method, GVariant * params,
                 GDBusMethodInvocation * invocation, gpointer user_data)
{
    g_debug ("bus_method_call");

    GVariant * retval = NULL;
    GError * error = NULL;

    if (g_strcmp0 (method, "dbus_create_trie") == 0) {
        int j = 0;
        int num = 0;
        char *tmp_s = NULL;
        char *decrypt = NULL;
        char **str_list = NULL;
        GVariantIter *iter = NULL;
		
		sys_says("got arguments...\n");
		g_variant_get (params, "(asi)", &iter, &num);
        str_list = (char**)calloc(num, sizeof(char*));
        while ( g_variant_iter_loop(iter, "s", &tmp_s) ) {
			sys_says("tmp_s : %s\n", tmp_s);
            str_list[j] = (char*)calloc(1, (strlen(tmp_s) + 1) * 
                    sizeof(char));
            memcpy(str_list[j], tmp_s, strlen(tmp_s));
            sys_says("str list %d : %s\n", j, str_list[j]);
            j++;
        }
        g_variant_iter_free(iter);
        
        decrypt = dbus_create_trie(str_list, num);
		retval = g_variant_new("(s)", decrypt);
		
		for ( j = 0; j < num; j++ ) {
			free(str_list[j]);
			str_list[j] = NULL;
		}
		free(str_list);
		str_list = NULL;
    } else if (g_strcmp0 (method, "dbus_search_trie") == 0) {
        int i = 0;
        const gchar *str1 = NULL;
        const gchar *str2 = NULL;
        GArray *tmp_array = NULL;
        GVariantBuilder *builder = NULL;
		
		g_variant_get (params, "(ss)", &str1, &str2);
		sys_says("keys : %s\tmd5 : %s\n", str1, str2);
		
        builder = g_variant_builder_new(G_VARIANT_TYPE("ai"));
        tmp_array = dbus_search_trie(str1, str2);
        if ( tmp_array != NULL ) {
            for ( i = 0; i < num_size; i++ ) {
                g_variant_builder_add(builder, "i", 
                        g_array_index(tmp_array, gint, i));
                sys_says("array %d : %d\n", i, 
                        g_array_index(tmp_array, gint, i));
            }
            retval = g_variant_new("(ai)", builder);
            g_variant_builder_unref(builder);
        }
    } else if (g_strcmp0 (method, "dbus_destroy_trie") == 0) {
		dbus_destroy_trie();
	} else if (g_strcmp0 (method, "finalize_dbus_loop") == 0) {
		finalize_dbus_loop();
	} else {
        g_warning ("Calling method '%s' on lock and it's unknown", method);
    }

    if (error != NULL) {
        g_dbus_method_invocation_return_dbus_error (invocation,
                "com.deepin.dde.lock.Error",
                error->message);
        g_error_free (error);

    } else {
        g_dbus_method_invocation_return_value (invocation, retval);
    }
}
