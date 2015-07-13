namespace Pumpkin {
    class Application : Gtk.Application {
        protected ApplicationWindow window;
        
        public Application() {
            application_id = "net.dannote.pumpkin";
        }

        protected override void activate() {
            window = new ApplicationWindow(this);
            window.create_tab(false);
            window.address_entry.grab_focus();
            window.present();
        }

        public override void open(GLib.File[] files, string hint) {
            stdout.printf("Open");
        }
    }
}

public static int main(string[] args) {
    var application = new Pumpkin.Application();
    return application.run(args);
}