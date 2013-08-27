#include "dbus_database.h"

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

GMainLoop *loop = NULL;

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

const char *_lock_dbus_iface_xml = 
"<?xml version=\"1.0\"?>\n"
"<node>\n"
"	<interface name=\""DBUS_PINYIN_INFACE"\">\n"
"		<method name=\"dbus_insert_pinyin\">\n"
"		<arg name=\"file_path\" type=\"s\" direction=\"in\">\n"
"		</arg>\n"
"		</method>\n"
"		<method name=\"dbus_get_pinyin\">\n"
"		<arg name=\"cmd_buf\" type=\"s\" direction=\"in\">\n"
"		</arg>\n"
"		<arg name=\"ret_pinyin\" type=\"s\" direction=\"out\">\n"
"		</arg>\n"
"		</method>\n"
"		<method name=\"finalize_dbus_loop\">\n"
"		</method>\n"
"	</interface>\n"
"</node>\n"
;

void dbus_pinyin()
{
	loop = g_main_loop_new(NULL, FALSE);
	GError *error = NULL;
	
	node_info = g_dbus_node_info_new_for_xml (_lock_dbus_iface_xml, &error);
	if ( error != NULL ) {
		g_critical("Unable to parse interface xml: %s\n", error->message);
		g_error_free(error);
	}

	interface_info = g_dbus_node_info_lookup_interface(node_info, 
			DBUS_PINYIN_INFACE );
	if ( interface_info == NULL ) {
		g_critical("Unable to find interface '"DBUS_PINYIN_INFACE"'");
	}

	lock_service_owner_id = 0;
	lock_service_reg_id = 0;
	retry_reg_timeout_id = 0;
	_retry_registration(NULL);

    g_timeout_add_seconds( 15, do_exit, NULL );
	g_main_loop_run(loop);
	g_main_loop_unref(loop);

	return ;
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
				DBUS_PINYIN_NAME, 
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
			DBUS_PINYIN_PATH, 
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
		g_critical ( "Unable to claim the name %s\n", DBUS_PINYIN_NAME );
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

    if (g_strcmp0 (method, "dbus_insert_pinyin") == 0) {
        const gchar *path = NULL;
		
		g_variant_get (params, "(s)", &path);
		dbus_insert_pinyin(path);
    } else if (g_strcmp0 (method, "dbus_get_pinyin") == 0) {
        const gchar *buf = NULL;
		
		g_variant_get (params, "(s)", &buf);
		retval = g_variant_new("(s)", dbus_get_pinyin(buf));
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
