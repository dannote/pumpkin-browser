namespace Pumpkin {
    [GtkTemplate(ui = "/net/dannote/pumpkin/ui/window.ui")]
    public class ApplicationWindow : Gtk.ApplicationWindow {
        [GtkChild]
        protected Gtk.Notebook notebook;
        [GtkChild]
        protected Gtk.Button new_tab_button;
        protected WebKit.WebContext web_context;

        public ApplicationWindow(Gtk.Application application) {
            GLib.Object(application: application);

            new_tab_button.clicked.connect(() => create_tab().load_uri("http://google.com"));
            notebook.switch_page.connect((page) => {
                Pumpkin.TabLabel label = (Pumpkin.TabLabel) notebook.get_tab_label(page);
                title = label.text;
                icon = label.icon;
            });

            web_context = new WebKit.WebContext();
            web_context.set_favicon_database_directory(null);

            create_tab().load_uri("http://google.com");
        }

        public WebKit.WebView create_tab() {
            var web_view = new WebKit.WebView.with_context(web_context);

            var label = new Pumpkin.TabLabel();

            web_view.notify["favicon"].connect(() => {
                if (web_view.favicon != null) {
                    var favicon = web_view.get_favicon();
                    var context = new Cairo.Context(favicon);
                    double width, height;
                    context.clip_extents(null, null, out width, out height);
                    var pixbuf = Gdk.pixbuf_get_from_surface(favicon, 0, 0, (int) width, (int) height)
                        .scale_simple(ICON_SIZE, ICON_SIZE, Gdk.InterpType.BILINEAR);
                    icon = pixbuf;
                    label.icon = pixbuf;
                }
            });

            web_view.create.connect(create_tab);

            web_view.notify["title"].connect(() => {
                title = web_view.title;
                label.text = web_view.title;
            });

            notebook.append_page(web_view, label);
            notebook.set_tab_reorderable(web_view, true);

            label.close.connect(() => {
                notebook.remove_page(notebook.page_num(web_view));
                label.destroy();
                web_view.destroy();
            });

            web_view.show();
            notebook.set_current_page(notebook.page_num(web_view));

            return web_view;
        }
    }
}