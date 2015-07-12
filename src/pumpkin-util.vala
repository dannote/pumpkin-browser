namespace Pumpkin.Util {
    namespace Uri {
        public static bool is_valid(string uri) {
            return new Soup.URI(uri) != null;
        }

        public static string normalize(string text) {
            var uri = new Soup.URI(text);
            if (uri == null) {
                uri = new Soup.URI(null);
                uri.set_scheme("http");
                uri.set_host(text);
                uri.set_path("");
            }
            return uri.to_string(false);
        }
    }
}