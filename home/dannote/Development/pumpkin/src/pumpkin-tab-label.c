/* pumpkin-tab-label.c generated by valac 0.28.0, the Vala compiler
 * generated from pumpkin-tab-label.vala, do not modify */


#include <glib.h>
#include <glib-object.h>
#include <gtk/gtk.h>
#include <gdk-pixbuf/gdk-pixbuf.h>
#include <stdlib.h>
#include <string.h>


#define PUMPKIN_TYPE_TAB_LABEL (pumpkin_tab_label_get_type ())
#define PUMPKIN_TAB_LABEL(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), PUMPKIN_TYPE_TAB_LABEL, PumpkinTabLabel))
#define PUMPKIN_TAB_LABEL_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), PUMPKIN_TYPE_TAB_LABEL, PumpkinTabLabelClass))
#define PUMPKIN_IS_TAB_LABEL(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), PUMPKIN_TYPE_TAB_LABEL))
#define PUMPKIN_IS_TAB_LABEL_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), PUMPKIN_TYPE_TAB_LABEL))
#define PUMPKIN_TAB_LABEL_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), PUMPKIN_TYPE_TAB_LABEL, PumpkinTabLabelClass))

typedef struct _PumpkinTabLabel PumpkinTabLabel;
typedef struct _PumpkinTabLabelClass PumpkinTabLabelClass;
typedef struct _PumpkinTabLabelPrivate PumpkinTabLabelPrivate;
#define _g_object_unref0(var) ((var == NULL) ? NULL : (var = (g_object_unref (var), NULL)))

struct _PumpkinTabLabel {
	GtkBox parent_instance;
	PumpkinTabLabelPrivate * priv;
	GtkImage* icon;
	GtkLabel* caption;
	GtkButton* close_button;
};

struct _PumpkinTabLabelClass {
	GtkBoxClass parent_class;
};


static gpointer pumpkin_tab_label_parent_class = NULL;

GType pumpkin_tab_label_get_type (void) G_GNUC_CONST;
enum  {
	PUMPKIN_TAB_LABEL_DUMMY_PROPERTY
};
PumpkinTabLabel* pumpkin_tab_label_new (void);
PumpkinTabLabel* pumpkin_tab_label_construct (GType object_type);
static void __lambda5_ (PumpkinTabLabel* self);
static void ___lambda5__gtk_button_clicked (GtkButton* _sender, gpointer self);
void pumpkin_tab_label_set_icon (PumpkinTabLabel* self, GdkPixbuf* pixbuf);
#define PUMPKIN_ICON_SIZE 16
void pumpkin_tab_label_set_text (PumpkinTabLabel* self, const gchar* str);
static void pumpkin_tab_label_finalize (GObject* obj);


static void __lambda5_ (PumpkinTabLabel* self) {
#line 14 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	g_signal_emit_by_name (self, "close");
#line 58 "pumpkin-tab-label.c"
}


static void ___lambda5__gtk_button_clicked (GtkButton* _sender, gpointer self) {
#line 14 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	__lambda5_ ((PumpkinTabLabel*) self);
#line 65 "pumpkin-tab-label.c"
}


PumpkinTabLabel* pumpkin_tab_label_construct (GType object_type) {
	PumpkinTabLabel * self = NULL;
	GtkButton* _tmp0_ = NULL;
#line 13 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	self = (PumpkinTabLabel*) g_object_new (object_type, NULL);
#line 14 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	_tmp0_ = self->close_button;
#line 14 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	g_signal_connect_object (_tmp0_, "clicked", (GCallback) ___lambda5__gtk_button_clicked, self, 0);
#line 15 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	gtk_widget_show_all ((GtkWidget*) self);
#line 13 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	return self;
#line 82 "pumpkin-tab-label.c"
}


PumpkinTabLabel* pumpkin_tab_label_new (void) {
#line 13 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	return pumpkin_tab_label_construct (PUMPKIN_TYPE_TAB_LABEL);
#line 89 "pumpkin-tab-label.c"
}


void pumpkin_tab_label_set_icon (PumpkinTabLabel* self, GdkPixbuf* pixbuf) {
	GtkImage* _tmp0_ = NULL;
	GdkPixbuf* _tmp1_ = NULL;
	GdkPixbuf* _tmp2_ = NULL;
	GdkPixbuf* _tmp3_ = NULL;
#line 18 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	g_return_if_fail (self != NULL);
#line 18 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	g_return_if_fail (pixbuf != NULL);
#line 19 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	_tmp0_ = self->icon;
#line 19 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	_tmp1_ = pixbuf;
#line 19 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	_tmp2_ = gdk_pixbuf_scale_simple (_tmp1_, PUMPKIN_ICON_SIZE, PUMPKIN_ICON_SIZE, GDK_INTERP_BILINEAR);
#line 19 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	_tmp3_ = _tmp2_;
#line 19 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	gtk_image_set_from_pixbuf (_tmp0_, _tmp3_);
#line 19 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	_g_object_unref0 (_tmp3_);
#line 114 "pumpkin-tab-label.c"
}


void pumpkin_tab_label_set_text (PumpkinTabLabel* self, const gchar* str) {
	GtkLabel* _tmp0_ = NULL;
	const gchar* _tmp1_ = NULL;
#line 22 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	g_return_if_fail (self != NULL);
#line 22 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	g_return_if_fail (str != NULL);
#line 23 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	_tmp0_ = self->caption;
#line 23 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	_tmp1_ = str;
#line 23 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	gtk_label_set_text (_tmp0_, _tmp1_);
#line 131 "pumpkin-tab-label.c"
}


static void pumpkin_tab_label_class_init (PumpkinTabLabelClass * klass) {
#line 3 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	pumpkin_tab_label_parent_class = g_type_class_peek_parent (klass);
#line 3 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	G_OBJECT_CLASS (klass)->finalize = pumpkin_tab_label_finalize;
#line 3 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	gtk_widget_class_set_template_from_resource (GTK_WIDGET_CLASS (klass), "/net/dannote/pumpkin/ui/tab-label.ui");
#line 3 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	g_signal_new ("close", PUMPKIN_TYPE_TAB_LABEL, G_SIGNAL_RUN_LAST, 0, NULL, NULL, g_cclosure_marshal_VOID__VOID, G_TYPE_NONE, 0);
#line 3 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	gtk_widget_class_bind_template_child_full (GTK_WIDGET_CLASS (klass), "icon", FALSE, G_STRUCT_OFFSET (PumpkinTabLabel, icon));
#line 3 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	gtk_widget_class_bind_template_child_full (GTK_WIDGET_CLASS (klass), "caption", FALSE, G_STRUCT_OFFSET (PumpkinTabLabel, caption));
#line 3 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	gtk_widget_class_bind_template_child_full (GTK_WIDGET_CLASS (klass), "close_button", FALSE, G_STRUCT_OFFSET (PumpkinTabLabel, close_button));
#line 150 "pumpkin-tab-label.c"
}


static void pumpkin_tab_label_instance_init (PumpkinTabLabel * self) {
#line 3 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	gtk_widget_init_template (GTK_WIDGET (self));
#line 157 "pumpkin-tab-label.c"
}


static void pumpkin_tab_label_finalize (GObject* obj) {
	PumpkinTabLabel * self;
#line 3 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	self = G_TYPE_CHECK_INSTANCE_CAST (obj, PUMPKIN_TYPE_TAB_LABEL, PumpkinTabLabel);
#line 5 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	_g_object_unref0 (self->icon);
#line 7 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	_g_object_unref0 (self->caption);
#line 9 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	_g_object_unref0 (self->close_button);
#line 3 "/home/dannote/Development/pumpkin/src/pumpkin-tab-label.vala"
	G_OBJECT_CLASS (pumpkin_tab_label_parent_class)->finalize (obj);
#line 173 "pumpkin-tab-label.c"
}


GType pumpkin_tab_label_get_type (void) {
	static volatile gsize pumpkin_tab_label_type_id__volatile = 0;
	if (g_once_init_enter (&pumpkin_tab_label_type_id__volatile)) {
		static const GTypeInfo g_define_type_info = { sizeof (PumpkinTabLabelClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) pumpkin_tab_label_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (PumpkinTabLabel), 0, (GInstanceInitFunc) pumpkin_tab_label_instance_init, NULL };
		GType pumpkin_tab_label_type_id;
		pumpkin_tab_label_type_id = g_type_register_static (gtk_box_get_type (), "PumpkinTabLabel", &g_define_type_info, 0);
		g_once_init_leave (&pumpkin_tab_label_type_id__volatile, pumpkin_tab_label_type_id);
	}
	return pumpkin_tab_label_type_id__volatile;
}



