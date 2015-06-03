namespace Pumpkin {
    [GtkTemplate(ui = "/net/dannote/pumpkin/ui/window.ui")]
    public class ApplicationWindow : Gtk.ApplicationWindow {
        [GtkChild] protected Gtk.Notebook notebook;
        [GtkChild] protected Gtk.Button new_tab_button;
        [GtkChild] protected Gtk.ToolButton back_button;
        [GtkChild] protected Gtk.ToolButton forward_button;
        [GtkChild] protected Gtk.ToolButton reload_button;
        [GtkChild] protected Gtk.Entry address_entry;
        protected Gtk.EntryCompletion address_entry_completion;
        protected WebKit.WebContext web_context;
        protected WebKit.Settings web_settings;

        public ApplicationWindow(Gtk.Application application) {
            GLib.Object(application: application);

            new_tab_button.clicked.connect(() => {
                create_tab();
                address_entry.grab_focus();
                address_entry.select_region(0, -1);
            });

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

            address_entry_completion = new Gtk.EntryCompletion();
            address_entry_completion.text_column = 0;
            address_entry_completion.inline_completion = true;
            address_entry_completion.set_model(new Gtk.ListStore(1, typeof(string)));
            address_entry_completion.set_match_func((completion, key, iter) => {
                var suggestion_value = Value(typeof(string));
                completion.get_model().get_value(iter, completion.text_column, out suggestion_value);
                var suggestion = suggestion_value.get_string();
                var key_uri = new Soup.URI(null);
                key_uri.set_scheme("http");
                key_uri.set_host(key);
                key_uri.set_path("");
                return suggestion.index_of(key) == 0 || suggestion.index_of(key_uri.to_string(false)) == 0;
            });

            address_entry_completion.match_selected.connect(() => {
                open_in_current_tab(address_entry.text);
                return true;
            });

            address_entry.completion = address_entry_completion;

            address_entry.key_release_event.connect((event) => {
                Gdk.EventKey event_key = (Gdk.EventKey) event;

                if (event_key.keyval == Gdk.Key.Return) {
                    open_in_current_tab(address_entry.text);
                } else if(event_key.keyval != Gdk.Key.Up &&
                          event_key.keyval != Gdk.Key.Down) {
                    var session = new Soup.Session();
                    var message = new Soup.Message(
                        "GET",
                        "http://suggestqueries.google.com/complete/search?client=firefox&q=%s"
                            .printf(Soup.URI.encode(address_entry.text, null))
                    );
                    session.queue_message(message, (session, message) => {
                        Gtk.TreeIter iter;
                        var completion_list = new Gtk.ListStore(1, typeof(string));
                        var parser = new Json.Parser();
                        
                        try {
                            parser.load_from_data((string) message.response_body.flatten().data);
                            var root = parser.get_root().get_array();
                            var suggestion_list = root.get_array_element(1).get_elements();

                            foreach (var suggestion in suggestion_list) {
                                completion_list.append(out iter);
                                completion_list.set(iter, 0, suggestion.get_string());
                            }
                        } catch (GLib.Error error) {
                        } finally {
                            if (!/^https?:/.match(address_entry.text)) {
                                var uri = new Soup.URI(null);
                                uri.set_scheme("http");
                                uri.set_host(address_entry.text);
                                uri.set_path("");
                                completion_list.append(out iter);
                                completion_list.set(iter, 0, uri.to_string(false));
                            }
                            
                            address_entry_completion.set_model(completion_list);
                        }
                    });
                }
                
                return true;
            });
            
            notebook.switch_page.connect((page) => {
                WebKit.WebView web_view = (WebKit.WebView) page;
                Pumpkin.TabLabel label = (Pumpkin.TabLabel) notebook.get_tab_label(page);
                title = label.text;
                icon = label.icon;
                address_entry.text = web_view.uri == null ? "" : web_view.uri;
                address_entry.progress_fraction = web_view.is_loading ? web_view.estimated_load_progress : 0;
                back_button.set_sensitive(web_view.can_go_back());
                forward_button.set_sensitive(web_view.can_go_forward());
            });

            web_context = new WebKit.WebContext();
            web_context.set_favicon_database_directory(null);
            web_settings = new WebKit.Settings();
            web_settings.enable_smooth_scrolling = true;

            create_tab().load_uri("http://google.com");
        }

        public void open_in_current_tab(string text) {
            if (notebook.page >= 0) {
                var uri = new Soup.URI(text);
                WebKit.WebView web_view = (WebKit.WebView) notebook.get_nth_page(notebook.page);
                web_view.grab_focus();
                web_view.load_uri(uri == null ?
                    "http://www.google.com/search?q=%s".printf(Soup.URI.encode(text, null)) :
                    uri.to_string(false));
            }
        }

        public WebKit.WebView create_tab() {
            var web_view = new WebKit.WebView.with_context(web_context);
            web_view.set_settings(web_settings);

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
                if (notebook.page_num(web_view) == notebook.page && !address_entry.has_focus) {
                    address_entry.text = web_view.uri;
                }
            });

            web_view.notify["estimated-load-progress"].connect(() => {
                if (notebook.page_num(web_view) == notebook.page) {
                    address_entry.progress_fraction = web_view.estimated_load_progress;
                    back_button.set_sensitive(web_view.can_go_back());
                    forward_button.set_sensitive(web_view.can_go_forward());
                }
            });

            web_view.load_changed.connect(() => {
                if (notebook.page_num(web_view) == notebook.page && !web_view.is_loading) {
                    address_entry.progress_fraction = 0;
                }
            });

            web_view.context_menu.connect((context_menu, event, hit_test_result) => {
                if (hit_test_result.context_is_link()) {
                    context_menu.remove_all();
                    var new_tab_menu_item = new WebKit.ContextMenuItem.from_stock_action_with_label(
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