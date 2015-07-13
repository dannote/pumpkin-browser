namespace Pumpkin {
    public class GoogleCompletion : Gtk.EntryCompletion {
        public GoogleCompletion() {
            model = new Gtk.ListStore(2, typeof(string), typeof(string));
            text_column = 1;
            inline_completion = true;

            var source_renderer = new Gtk.CellRendererText();
            source_renderer.style = Pango.Style.ITALIC;

            cell_area.pack_end(source_renderer, false);
            cell_area.add_attribute(source_renderer, "text", 0);

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
                        model.set(iter, 0, "Google", 1, suggestion.get_string());
                    }
                } catch {
                    GLib.warning("Failed to parse response from Google");
                } finally {
                    if (!/^https?:/.match(entry.text)) { //TODO: optional DNS resolution
                        model.append(out iter);
                        model.set(iter, 0, "URL", 1, Util.Uri.normalize(entry.text));
                    }
                }
            });
        }
    }
}