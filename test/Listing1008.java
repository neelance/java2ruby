/* Listing1008.java */

public class Listing1008
{
  enum Farbe {ROT, GRUEN, BLAU, GELB};

  public static void farbVergleich(Farbe f1, Farbe f2)
  {
    System.out.print(f1);
    System.out.print(f1.equals(f2) ? " = " : " != ");
    System.out.println(f2);
  }

  public static String toRGB(Farbe f)
  {
    String ret = "?";
    switch (f) {
      case ROT:   ret = "(255,0,0)"; break;
      case GRUEN: ret = "(0,255,0)"; break;
      case BLAU:  ret = "(0,0,255)"; break;
      case GELB:  ret = "(255,255,0)"; break;
    }
    return ret;
  }

  public static void main(String[] args)
  {
    //Aufzählungsvariablen
    Farbe f1 = Farbe.ROT;
    Farbe f2 = Farbe.BLAU;
    Farbe f3 = Farbe.ROT;
    //toString() liefert den Namen
    System.out.println("--");
    System.out.println(f1);
    System.out.println(f2);
    System.out.println(f3);
    //equals funktioniert auch
    System.out.println("--");
    farbVergleich(f1, f2);
    farbVergleich(f1, f3);
    farbVergleich(f2, f3);
    farbVergleich(f1, f1);
    //Die Methode values()
    System.out.println("--");
    for (Farbe f : Farbe.values()) {
      System.out.println(f + "=" + toRGB(f));
    }
  }
}
