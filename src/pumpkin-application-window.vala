namespace Pumpkin {
    [GtkTemplate(ui = "/net/dannote/pumpkin/ui/window.ui")]
    public class ApplicationWindow : Gtk.ApplicationWindow {
        [GtkChild] protected Pumpkin.Notebook notebook;
        [GtkChild] protected Gtk.ToolButton back_button;
        [GtkChild] protected Gtk.ToolButton forward_button;
        [GtkChild] protected Gtk.ToolButton reload_button;
        [GtkChild] public Gtk.Entry address_entry;
        protected Pumpkin.GoogleCompletion address_entry_completion;
        protected WebKit.WebContext web_context;
        protected WebKit.Settings web_settings;

        public ApplicationWindow(Gtk.Application application) {
            GLib.Object(application: application);

            icon = notebook.icon;

            back_button.clicked.connect(notebook.go_back);
            forward_button.clicked.connect(notebook.go_forward);
            reload_button.clicked.connect(notebook.reload);

            address_entry_completion = new Pumpkin.GoogleCompletion();
            address_entry_completion.match_selected.connect((entry_completion, model, iter) => {
                var completion = (Pumpkin.GoogleCompletion) entry_completion;
                var suggestion_value = Value(typeof(string));
                model.get_value(iter, completion.text_column, out suggestion_value);
                open_in_current_tab(suggestion_value.get_string());
                completion.clear_model();
                return true;
            });
            address_entry.completion = address_entry_completion;
            address_entry.changed.connect(address_entry_completion.load_model);
            address_entry.activate.connect(() => {
                address_entry_completion.clear_model();
                open_in_current_tab(address_entry.text);
            });

            notebook.notify["icon"].connect(() => icon = notebook.icon);
            notebook.notify["title"].connect(() => title = notebook.title);
            notebook.notify["uri"].connect(() => address_entry.text = notebook.uri);
            notebook.notify["progress"].connect(() => 
                address_entry.progress_fraction = notebook.progress);
            notebook.notify["can-go-back"].connect(() =>
                back_button.set_sensitive(notebook.can_go_back));
            notebook.notify["can-go-forward"].connect(() =>
                forward_button.set_sensitive(notebook.can_go_forward));
            notebook.new_tab_button.clicked.connect(() => {
                create_tab(false);
                address_entry.grab_focus();
                address_entry.select_region(0, -1);
            });
            notebook.create_window.connect((page, x, y) => {
                var new_window = new Pumpkin.ApplicationWindow(application);
                new_window.show();
                return new_window.notebook;
            });
            notebook.page_removed.connect(() => {
                if (notebook.get_n_pages() == 0) {
                    close();
                }
            });

            web_context = new WebKit.WebContext();
            web_context.set_favicon_database_directory(null);
            web_context.set_cache_model(WebKit.CacheModel.DOCUMENT_BROWSER);
            web_settings = new WebKit.Settings();
            web_settings.enable_smooth_scrolling = true;
            web_settings.enable_developer_extras = true;
        }

        public void open_in_current_tab(string text) {
            if (notebook.page >= 0) {
                WebKit.WebView web_view = (WebKit.WebView) notebook.get_nth_page(notebook.page);
                web_view.grab_focus();
                web_view.load_uri(Util.Uri.is_valid(text) ? text :
                    "http://www.google.com/search?q=%s".printf(Soup.URI.encode(text, null)));
            }
        }

        public WebKit.WebView create_tab(bool neighbor = true) {
            var web_view = new WebKit.WebView.with_context(web_context);
            web_view.set_settings(web_settings);

            var label = new Pumpkin.TabLabel();

            web_view.create.connect(() => create_tab());
            web_view.context_menu.connect((context_menu, event, hit_test_result) => {
                if (hit_test_result.context_is_link()) {
                    context_menu.remove_all();
                    // TODO: add "Open in New Window" and "Search for"
                    var new_tab_menu_item = new WebKit.ContextMenuItem
                        .from_stock_action_with_label(
                            WebKit.ContextMenuAction.OPEN_LINK_IN_NEW_WINDOW,
                            "Open in New Tab"
                        );
                    context_menu.append(new WebKit.ContextMenuItem.from_stock_action(
                        WebKit.ContextMenuAction.OPEN_LINK
                    ));
                    context_menu.append(new_tab_menu_item);
                    context_menu.append(new WebKit.ContextMenuItem.from_stock_action(
                        WebKit.ContextMenuAction.COPY_LINK_TO_CLIPBOARD
                    ));
                    context_menu.append(new WebKit.ContextMenuItem.from_stock_action(
                        WebKit.ContextMenuAction.DOWNLOAD_LINK_TO_DISK
                    ));
                }
                return false;
            });

            web_view.show();

            notebook.set_current_page(neighbor ?
                notebook.insert_page(web_view, label, notebook.page + 1) :
                notebook.append_page(web_view, label));

            web_view.grab_focus();

            return web_view;
        }
    }
}