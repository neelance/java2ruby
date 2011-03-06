/* Listing1018.java */

interface MenuVisitor
{
  abstract void visitMenuEntry(MenuEntry2 entry);
  abstract void visitMenuStarted(Menu2 menu);
  abstract void visitMenuEnded(Menu2 menu);
}

class MenuEntry2
{
  protected String name;

  public MenuEntry2(String name)
  {
    this.name = name;
  }

  public String toString()
  {
    return name;
  }

  public void accept(MenuVisitor visitor)
  {
    visitor.visitMenuEntry(this);
  }
}

class Menu2
extends MenuEntry2
{
  MenuEntry2[] entries;
  int         entryCnt;

  public Menu2(String name, int maxElements)
  {
    super(name);
    this.entries = new MenuEntry2[maxElements];
    entryCnt = 0;
  }

  public void add(MenuEntry2 entry)
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

  public void accept(MenuVisitor visitor)
  {
    visitor.visitMenuStarted(this);
    for (int i = 0; i < entryCnt; ++i) {
      entries[i].accept(visitor);
    }
    visitor.visitMenuEnded(this);
  }
}

class MenuPrintVisitor
implements MenuVisitor
{
  String indent = "";

  public void visitMenuEntry(MenuEntry2 entry)
  {
    System.out.println(indent + entry.name);
  }

  public void visitMenuStarted(Menu2 menu)
  {
    System.out.println(indent + menu.name);
    indent += " ";
  }

  public void visitMenuEnded(Menu2 menu)
  {
    indent = indent.substring(1);
  }
}

public class Listing1018
{
  public static void main(String[] args)
  {
    Menu2 filemenu = new Menu2("Datei", 5);
    filemenu.add(new MenuEntry2("Neu"));
    filemenu.add(new MenuEntry2("Laden"));
    filemenu.add(new MenuEntry2("Speichern"));
    Menu2 confmenu = new Menu2("Konfiguration", 3);
    confmenu.add(new MenuEntry2("Farben"));
    confmenu.add(new MenuEntry2("Fenster"));
    confmenu.add(new MenuEntry2("Pfade"));
    filemenu.add(confmenu);
    filemenu.add(new MenuEntry2("Beenden"));

    filemenu.accept(new MenuPrintVisitor());
  }
}