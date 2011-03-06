/* Listing0712.java */

public class Listing0712
{
  public static void registrierKasse(Object... args)
  {
    double zwischensumme = 0;
    double gesamtsumme   = 0;
    for (int i = 0; i < args.length; ++i) {
      if (args[i] instanceof Number) {
        zwischensumme += ((Number)args[i]).doubleValue();
      } else {
        System.out.println(args[i] + ": " + zwischensumme);
        gesamtsumme += zwischensumme;
        zwischensumme = 0;
      }
    }
    System.out.println("Gesamtsumme: " + gesamtsumme);
  }

  public static void main(String[] args)
  {
    registrierKasse(
      1.45, 0.79, 19.90, "Ware",
      -3.00, 1.50, "Pfand",
      -10, "Gutschein"
    );
  }
}