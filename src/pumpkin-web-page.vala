namespace Pumpkin {
  public class WebPage : WebKit.WebView, Pumpkin.Page {
    protected Pumpkin.PageLabel _label;

    public Pumpkin.PageLabel label {
      get { return _label; }
      set { _label = value; }
    }

    public WebPage(Pumpkin.Application application) {
      var new_label = new Pumpkin.PageLabel();
      WebPage.with_label(application, new_label);
    }

    public WebPage.with_label(Pumpkin.Application application, Pumpkin.PageLabel label) {
      Object(web_context: application.web_context);
      set_settings(application.web_settings);
      
      _label = label;

      notify["title"].connect(() => {
        if (title != null) {
          label.text = title;
        }
      });
      
      notify["favicon"].connect(() => {
        if (favicon != null) {
          var favicon = get_favicon();
            var context = new Cairo.Context(favicon);
            double width, height;
            context.clip_extents(null, null, out width, out height);
            _label.icon = Gdk.pixbuf_get_from_surface(
              favicon, 0, 0, (int) width, (int) height
            ).scale_simple(ICON_SIZE, ICON_SIZE, Gdk.InterpType.BILINEAR);
        } else {
          _label.icon = null;
        }
      });
    }
  }
}