namespace Pumpkin {
    [GtkTemplate(ui = "/net/dannote/pumpkin/ui/tab-label.ui")]
    class TabLabel : Gtk.Box {
        [GtkChild]
        protected Gtk.Image icon;
        [GtkChild]
        protected Gtk.Label caption;
        [GtkChild]
        protected Gtk.Button close_button;

        public TabLabel() {
            show_all();
        }

        public void set_icon(Gdk.Pixbuf pixbuf) {
            icon.set_from_pixbuf(pixbuf.scale_simple(ICON_SIZE, ICON_SIZE, Gdk.InterpType.BILINEAR));
        }

        public void set_text(string str) {
            caption.set_text(str);
        }
    }
}