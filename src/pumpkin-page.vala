namespace Pumpkin {
  public interface Page : Gtk.Widget {
    public abstract Pumpkin.PageLabel label {
      get { return (Pumpkin.PageLabel) null; }
      set {}
    }
  }
}