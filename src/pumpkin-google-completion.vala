namespace Pumpkin {
    public class GoogleCompletion : Gtk.EntryCompletion {
        public GoogleCompletion() {
            model = new Gtk.ListStore(1, typeof(string));
            text_column = 0;
            inline_completion = true;

            set_match_func((completion, key, iter) => {
                var suggestion_value = Value(typeof(string));
                completion.model.get_value(iter, completion.text_column, out suggestion_value);
                var suggestion = suggestion_value.get_string();
                return suggestion != null &&
                    suggestion.index_of(key) == 0 ||
                    suggestion.index_of(Util.Uri.normalize(key)) == 0;
            });
        }

        public void clear_model() {
            var model = (Gtk.ListStore) model;
            model.clear();
        }

        public void load_model() {
            var entry = (Gtk.Entry) get_entry();
            var model = (Gtk.ListStore) model;
            var session = new Soup.Session();
            var message = new Soup.Message(
                "GET",
                "http://suggestqueries.google.com/complete/search?client=pumpkin&q=%s"
                    .printf(Soup.URI.encode(entry.text, null))
            );

            session.queue_message(message, (session, message) => {
                Gtk.TreeIter iter;
                var parser = new Json.Parser();
                model.clear();
                
                try {
                    parser.load_from_data((string) message.response_body.flatten().data);
                    var root = parser.get_root().get_array();
                    var suggestion_list = root.get_array_element(1).get_elements();

                    foreach (var suggestion in suggestion_list) {
                        model.append(out iter);
                        model.set(iter, 0, suggestion.get_string());
                    }
                } catch {} finally {
                    if (!/^https?:/.match(entry.text)) {
                        model.append(out iter);
                        model.set(iter, 0, Util.Uri.normalize(entry.text));
                    }
                }
            });
        }
    }
}