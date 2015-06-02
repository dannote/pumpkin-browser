namespace Pumpkin {
    [GtkTemplate(ui = "/net/dannote/pumpkin/ui/window.ui")]
    public class ApplicationWindow : Gtk.ApplicationWindow {
        [GtkChild]
        protected Gtk.Notebook notebook;
        protected WebKit.WebContext web_context;

        public ApplicationWindow(Gtk.Application application) {
            GLib.Object(application: application);

            var new_tab_button = new Gtk.Button.from_icon_name("tab-new", Gtk.IconSize.MENU);
            new_tab_button.show();
            notebook.set_action_widget(new_tab_button, Gtk.PackType.END);

            web_context = new WebKit.WebContext();
            web_context.set_favicon_database_directory(null);
            var web_view = new WebKit.WebView.with_context(web_context);

            var label = new Pumpkin.TabLabel();
            notebook.append_page(web_view, label);

            web_view.notify["favicon"].connect(() => {
                if (web_view.favicon != null) {
                    var favicon = web_view.get_favicon();
                    var context = new Cairo.Context(favicon);
                    double width, height;
                    context.clip_extents(null, null, out width, out height);
                    var pixbuf = Gdk.pixbuf_get_from_surface(favicon, 0, 0, (int) width, (int) height)
                        .scale_simple(ICON_SIZE, ICON_SIZE, Gdk.InterpType.BILINEAR);
                    set_icon(pixbuf);
                    label.set_icon(pixbuf);
                }
            });

            web_view.create.connect(() => {
                var web_view_new = new WebKit.WebView.with_context(web_context);
                notebook.append_page(web_view_new, new Pumpkin.TabLabel());
                show_all();
                return web_view_new;
            });

            web_view.notify["title"].connect(() => {
                title = web_view.title;
                label.set_text(web_view.title);
            });

            show_all();

            web_view.load_uri("http://google.com");
        }
    }
}