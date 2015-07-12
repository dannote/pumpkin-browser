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
                if (suggestion != null) {
                    return suggestion.index_of(key) == 0 ||
                        suggestion.index_of(Util.Uri.normalize(key)) == 0;
                }
                return false;
            });
        }

        public void clear_model() {
            var model = (Gtk.ListStore) model;
            model.clear();
        }

        public void load_model() {
            var entry = (Gtk.Entry) get_entry();

            if (entry.text.length == 0) {
                return;
            }

            var model = (Gtk.ListStore) model;
            var session = new Soup.Session();
            var message = new Soup.Message(
                "GET",
                "http://suggestqueries.google.com/complete/search?client=firefox&q=%s"
                    .printf(Soup.URI.encode(entry.text, null))
            );

            session.queue_message(message, (session, message) => {
                Gtk.TreeIter iter;
                var parser = new Json.Parser();
                model.clear();
                
                try {
                    var response = (string) message.response_body.flatten().data;

                    if (response.length == 0) {
                        throw new Json.ParserError.UNKNOWN("Got empty response");
                    }

                    parser.load_from_data(response);
                    
                    var root = parser.get_root();

                    if (root == null) {
                        throw new Json.ParserError.UNKNOWN("Response is not JSON");
                    }

                    if (root.get_node_type() != Json.NodeType.ARRAY) {
                        throw new Json.ParserError.UNKNOWN(
                            "Unexpected root element of type %s", root.type_name());
                    }

                    var suggestion_array = root.get_array().get_element(1);

                    if (suggestion_array.get_node_type() != Json.NodeType.ARRAY) {
                        throw new Json.ParserError.UNKNOWN(
                            "Unexpected inner element of type %s", suggestion_array.type_name());
                    }

                    var suggestion_list = suggestion_array.get_array().get_elements();

                    foreach (var suggestion in suggestion_list) {
                        model.append(out iter);
                        model.set(iter, 0, suggestion.get_string());
                    }
                } catch {
                    GLib.warning("Failed to parse response from Google");
                } finally {
                    if (!/^https?:/.match(entry.text)) {
                        model.append(out iter);
                        model.set(iter, 0, Util.Uri.normalize(entry.text));
                    }
                }
            });
        }
    }
}