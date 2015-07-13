namespace Pumpkin {
    [GtkTemplate(ui = "/net/dannote/pumpkin/ui/notebook.ui")]
    public class Notebook : Gtk.Notebook {
        [GtkChild] public Gtk.Button new_tab_button;
        public bool can_go_back { get; private set; }
        public bool can_go_forward { get; private set; }
        public Gdk.Pixbuf icon { get; private set; }
        public string title { get; private set; }
        public string uri { get; private set; }
        public double progress { get; private set; }

        construct {
            group_name = "pumpkin";

            page_added.connect((notebook, child, page_num) => {
                var web_view = (WebKit.WebView) child;
                var label = (Pumpkin.TabLabel) get_tab_label(web_view);

                set_tab_reorderable(web_view, true);
                set_tab_detachable(web_view, true);

                label.close.connect(() => {
                    this.remove_page(this.page_num(web_view));
                    label.destroy();
                    web_view.destroy();
                });

                //TODO: probably move to custom WebView class 
                web_view.notify["title"].connect(() => {
                    if (web_view.title != null) {
                        label.text = web_view.title;
                    }
                });
                web_view.notify["favicon"].connect(() => {
                     if (web_view.favicon != null) {
                        var favicon = web_view.get_favicon();
                        var context = new Cairo.Context(favicon);
                        double width, height;
                        context.clip_extents(null, null, out width, out height);
                        label.icon = Gdk.pixbuf_get_from_surface(
                            favicon, 0, 0, (int) width, (int) height
                        ).scale_simple(ICON_SIZE, ICON_SIZE, Gdk.InterpType.BILINEAR);
                    } else {
                        label.icon = null;
                    }
                });
            });

            switch_page.connect((new_page) => {
                if (page >= 0) {
                    //TODO: move as private method to ApplicationWindow.
                    var old_page = get_nth_page(page);
                    var old_label = (Pumpkin.TabLabel) get_tab_label(old_page);
                    old_label.notify["text"].disconnect(update_title);
                    old_label.notify["icon"].disconnect(update_icon);
                    old_page.notify["uri"].disconnect(update_uri);
                    old_page.notify["estimated-load-progress"].disconnect(update_progress);
                    old_page.notify["is-loading"].disconnect(update_progress);
                }
                var new_label = (Pumpkin.TabLabel) get_tab_label(new_page);
                new_label.notify["text"].connect(update_title);
                new_label.notify["icon"].connect(update_icon);
                var new_web_view = (WebKit.WebView) new_page;
                new_web_view.notify["uri"].connect(update_uri);
                new_web_view.notify["estimated-load-progress"].connect(update_progress);
                new_web_view.notify["is-loading"].connect(update_progress);
                title = new_label.text;
                icon = new_label.icon;
                if (new_web_view.uri != null) {
                    uri = new_web_view.uri;
                }
                progress = new_web_view.is_loading ? new_web_view.estimated_load_progress : 0;
                can_go_back = new_web_view.can_go_back();
                can_go_forward = new_web_view.can_go_forward();
            });
        }

        protected void update_icon() {
            var label = (Pumpkin.TabLabel) get_tab_label(get_nth_page(page));
            icon = label.icon;
        }

        protected void update_title() {
            var label = (Pumpkin.TabLabel) get_tab_label(get_nth_page(page));
            title = label.text;
        }

        protected void update_uri() {
            var web_view = (WebKit.WebView) get_nth_page(page);
            
            if (web_view.uri != null) {
                uri =  web_view.uri;
            }
            can_go_back = web_view.can_go_back();
            can_go_forward = web_view.can_go_forward();
        }

        protected void update_progress() {
            var web_view = (WebKit.WebView) get_nth_page(page);
            progress = web_view.is_loading ? web_view.estimated_load_progress : 0;
            can_go_back = web_view.can_go_back();
            can_go_forward = web_view.can_go_forward();
        }

        public void go_back() {
            if (page >= 0) {
                ((WebKit.WebView) get_nth_page(page)).go_back();
            }
        }

        public void go_forward() {
            if (page >= 0) {
                ((WebKit.WebView) get_nth_page(page)).go_forward();
            }
        }

        public void reload() {
            if (page >= 0) {
                ((WebKit.WebView) get_nth_page(page)).reload();
            }
        }
    }
}