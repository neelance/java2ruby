/* Listing1104.java */

public class Listing1104
{
  public static void main(String[] args)
  {
    String a, b, c;

    //Konventionelle Verkettung
    a = "Hallo";
    b = "Welt";
    c = a + ", " + b;
    System.out.println(c);

    //So könnte es der Compiler übersetzen
    a = "Hallo";
    b = "Welt";
    c =(new StringBuilder(a)).append(", ").append(b).toString();
    System.out.println(c);
  }
}
