/* Listing1017.java */

class MenuEntry1
{
  protected String name;

  public MenuEntry1(String name)
  {
    this.name = name;
  }

  public String toString()
  {
    return name;
  }
}

class IconizedMenuEntry1
extends MenuEntry1
{
  private String iconName;

  public IconizedMenuEntry1(String name, String iconName)
  {
    super(name);
    this.iconName = iconName;
  }
}

class CheckableMenuEntry1
extends MenuEntry1
{
  private boolean checked;

  public CheckableMenuEntry1(String name, boolean checked)
  {
    super(name);
    this.checked = checked;
  }
}

class Menu1
extends MenuEntry1
{
  MenuEntry1[] entries;
  int          entryCnt;

  public Menu1(String name, int maxElements)
  {
    super(name);
    this.entries = new MenuEntry1[maxElements];
    entryCnt = 0;
  }

  public void add(MenuEntry1 entry)
  {
    entries[entryCnt++] = entry;
  }

  public String toString()
  {
    String ret = "(";
    for (int i = 0; i < entryCnt; ++i) {
      ret += (i != 0 ? "," : "") + entries[i].toString();
    }
    return ret + ")";
  }
}

public class Listing1017
{
  public static void main(String[] args)
  {
    Menu1 filemenu = new Menu1("Datei", 5);
    filemenu.add(new MenuEntry1("Neu"));
    filemenu.add(new MenuEntry1("Laden"));
    filemenu.add(new MenuEntry1("Speichern"));

    Menu1 confmenu = new Menu1("Konfiguration", 3);
    confmenu.add(new MenuEntry1("Farben"));
    confmenu.add(new MenuEntry1("Fenster"));
    confmenu.add(new MenuEntry1("Pfade"));
    filemenu.add(confmenu);

    filemenu.add(new MenuEntry1("Beenden"));

    System.out.println(filemenu.toString());
  }
}