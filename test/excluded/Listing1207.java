/* Listing1207.java */

public class Listing1207
{
  public static void main(String[] args)
  {
    int i, base = 0;

    try {
      for (base = 10; base >= 2; --base) {
        i = Integer.parseInt("40",base);
        System.out.println("40 base "+base+" = "+i);
      }
    } catch (NumberFormatException e) {
      System.out.println(
        "40 ist keine Zahl zur Basis "+base
      );
    } finally {
      System.out.println(
        "Sie haben ein einfaches Beispiel " +
        "sehr glücklich gemacht."
      );
    }
  }
}