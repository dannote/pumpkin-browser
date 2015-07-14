namespace Pumpkin {
    public class Application : Gtk.Application {
        protected ApplicationWindow window;
        public WebKit.WebContext web_context;
        public WebKit.Settings web_settings;
        private string _data_path;
        private string _database_path;

        public string data_path {
            get { return _data_path; }
        }

        public string database_path {
            get { return _database_path; }
        }
        
        public Application() {
            Object(application_id: "net.dannote.pumpkin");
            
            _data_path = Path.build_path(Path.DIR_SEPARATOR_S, Environment.get_user_data_dir(),
                "pumpkin");
            DirUtils.create_with_parents(data_path, 0700);
            _database_path = Path.build_path(data_path, "browser.db");

            web_context = new WebKit.WebContext();
            web_context.set_favicon_database_directory(null);
            web_context.set_cache_model(WebKit.CacheModel.DOCUMENT_BROWSER);
            web_context.get_cookie_manager().set_persistent_storage(database_path,
                WebKit.CookiePersistentStorage.SQLITE);
            web_settings = new WebKit.Settings();
            web_settings.enable_smooth_scrolling = true;
            web_settings.enable_developer_extras = true;
        }

        protected override void activate() {
            window = new ApplicationWindow(this);
            window.create_page(false).load_html("", null);
            window.address_entry.grab_focus();
            window.address_entry.select_region(0, -1);
            window.present();
        }

        public override void open(File[] files, string hint) {
            stdout.printf("Open");
        }
    }
}

public static int main(string[] args) {
    var application = new Pumpkin.Application();
    return application.run(args);
}