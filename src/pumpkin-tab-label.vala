namespace Pumpkin {
    [GtkTemplate(ui = "/net/dannote/pumpkin/ui/tab-label.ui")]
    class TabLabel : Gtk.Box {
        [GtkChild] public Gtk.Image image;
        [GtkChild] protected Gtk.Label caption;
        [GtkChild] protected Gtk.Button close_button;

        public string text {
            get { return caption.label; }
            set { caption.label = value; }
        }

        public Gdk.Pixbuf icon {
            get { return image.get_pixbuf(); }
            set { image.set_from_pixbuf(value.scale_simple(ICON_SIZE, ICON_SIZE, Gdk.InterpType.BILINEAR)); }
        }

        public signal void close();

        construct {
            close_button.clicked.connect(() => close());
        }
    }
}