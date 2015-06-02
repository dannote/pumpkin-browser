namespace Pumpkin {
    [GtkTemplate(ui = "/net/dannote/pumpkin/ui/window.ui")]
    public class ApplicationWindow : Gtk.ApplicationWindow {
        [GtkChild]
        protected Gtk.Notebook notebook;
        [GtkChild]
        protected Gtk.Button new_tab_button;
        [GtkChild]
        protected Gtk.ToolButton back_button;
        [GtkChild]
        protected Gtk.ToolButton forward_button;
        [GtkChild]
        protected Gtk.ToolButton reload_button;
        [GtkChild]
        protected Gtk.Entry address_entry;
        protected WebKit.WebContext web_context;

        public ApplicationWindow(Gtk.Application application) {
            GLib.Object(application: application);

            new_tab_button.clicked.connect(() => create_tab().load_uri("about:blank"));

            back_button.clicked.connect(() => {
                if (notebook.page >= 0) {
                    WebKit.WebView web_view = (WebKit.WebView) notebook.get_nth_page(notebook.page);
                    web_view.go_back();
                } 
            });

            forward_button.clicked.connect(() => {
                if (notebook.page >= 0) {
                    WebKit.WebView web_view = (WebKit.WebView) notebook.get_nth_page(notebook.page);
                    web_view.go_forward();
                } 
            });

            reload_button.clicked.connect(() => {
                if (notebook.page >= 0) {
                    WebKit.WebView web_view = (WebKit.WebView) notebook.get_nth_page(notebook.page);
                    web_view.reload();
                } 
            });

            address_entry.key_release_event.connect((event) => {
                Gdk.EventKey event_key = (Gdk.EventKey) event;
                if (event_key.keyval == Gdk.Key.Return && notebook.page >= 0) {
                    WebKit.WebView web_view = (WebKit.WebView) notebook.get_nth_page(notebook.page);
                    var uri = new Soup.URI(address_entry.text);
                    if (uri == null) {
                        uri = new Soup.URI(null);
                        uri.set_scheme("http");
                        uri.set_host(address_entry.text);
                        uri.set_path("");
                    }
                    web_view.load_uri(uri.to_string(false));
                }
                
                return true;
            });
            
            notebook.switch_page.connect((page) => {
                WebKit.WebView web_view = (WebKit.WebView) page;
                Pumpkin.TabLabel label = (Pumpkin.TabLabel) notebook.get_tab_label(page);
                title = label.text;
                icon = label.icon;
                address_entry.text = web_view.uri == null ? "about:blank" : web_view.uri;
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
                    label.icon = pixbuf;
                    if (notebook.page_num(web_view) == notebook.page) {
                        icon = pixbuf;
                    }
                }
            });

            web_view.create.connect(create_tab);

            web_view.notify["title"].connect(() => {
                if (notebook.page_num(web_view) == notebook.page) {
                    title = web_view.title;
                }
                label.text = web_view.title;
            });

            web_view.notify["uri"].connect(() => {
                if (notebook.page_num(web_view) == notebook.page) {
                    address_entry.text = web_view.uri;
                }
            });

            notebook.append_page(web_view, label);
            notebook.set_tab_reorderable(web_view, true);

            label.close.connect(() => {
                notebook.remove_page(notebook.page_num(web_view));
                label.destroy();
                web_view.destroy();
            });

            web_view.show();
            web_view.grab_focus();
            notebook.set_current_page(notebook.page_num(web_view));

            return web_view;
        }
    }
}