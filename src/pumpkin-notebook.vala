namespace Pumpkin {
    [GtkTemplate(ui = "/net/dannote/pumpkin/ui/notebook.ui")]
    public class Notebook : Gtk.Notebook {
        [GtkChild] public Gtk.Button new_page_button;
        public bool can_go_back { get; private set; }
        public bool can_go_forward { get; private set; }
        public Gdk.Pixbuf icon { get; private set; }
        public string title { get; private set; }
        public string uri { get; private set; }
        public double progress { get; private set; }

        construct {
            group_name = "pumpkin";

            page_added.connect((notebook, child, page_num) => {
                var page = (Pumpkin.Page) child;

                this.set_tab_reorderable(page, true);
                this.set_tab_detachable(page, true);

                page.label.close.connect(() => {
                    this.remove_page(this.page_num(page));
                    page.destroy();
                });
            });

            switch_page.connect((page) => {
                if (this.page >= 0) {
                    //TODO: move as private method to ApplicationWindow.
                    disconnect_page_signals(get_nth_page(get_current_page()));
                }
                var new_page = (Pumpkin.WebPage) page;
                connect_page_signals(new_page);
                title = new_page.label.text;
                icon = new_page.label.icon;
                if (new_page.uri != null) {
                    uri = new_page.uri;
                }
                progress = new_page.is_loading ? new_page.estimated_load_progress : 0;
                can_go_back = new_page.can_go_back();
                can_go_forward = new_page.can_go_forward();
            });
        }

        protected void connect_page_signals(Pumpkin.Page page) {
            page.label.notify["text"].connect(update_title);
            page.label.notify["icon"].connect(update_icon);
            page.notify["uri"].connect(update_uri);
            page.notify["estimated-load-progress"].connect(update_progress);
            page.notify["is-loading"].connect(update_progress);
        }

        protected void disconnect_page_signals(Pumpkin.Page page) {
            page.label.notify["text"].disconnect(update_title);
            page.label.notify["icon"].disconnect(update_icon);
            page.notify["uri"].disconnect(update_uri);
            page.notify["estimated-load-progress"].disconnect(update_progress);
            page.notify["is-loading"].disconnect(update_progress);
        }

        public new Pumpkin.Page get_nth_page(int page_num) {
            return (Pumpkin.Page) base.get_nth_page(page_num);
        }

        public new int append_page(Pumpkin.Page page) {
            return base.append_page(page, page.label);
        }

        public new int insert_page(Pumpkin.Page page, int position) {
            return base.insert_page(page, page.label, position);
        }

        protected void update_icon() {
            icon = get_nth_page(page).label.icon;
        }

        protected void update_title() {
            title = get_nth_page(page).label.text;
        }

        protected void update_uri() {
            var web_page = (Pumpkin.WebPage) get_nth_page(page);
            
            if (web_page.uri != null) {
                uri =  web_page.uri;
            }
            can_go_back = web_page.can_go_back();
            can_go_forward = web_page.can_go_forward();
        }

        protected void update_progress() {
            var web_page = (Pumpkin.WebPage) get_nth_page(page);
            progress = web_page.is_loading ? web_page.estimated_load_progress : 0;
            can_go_back = web_page.can_go_back();
            can_go_forward = web_page.can_go_forward();
        }

        public void go_back() {
            if (page >= 0) {
                ((Pumpkin.WebPage) get_nth_page(page)).go_back();
            }
        }

        public void go_forward() {
            if (page >= 0) {
                ((Pumpkin.WebPage) get_nth_page(page)).go_forward();
            }
        }

        public void reload() {
            if (page >= 0) {
                ((Pumpkin.WebPage) get_nth_page(page)).reload();
            }
        }
    }
}