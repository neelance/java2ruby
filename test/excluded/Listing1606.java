/* Listing1606.java */

public class Listing1606
{
  public static long testSleep(int millis)
  {
    final int MINDURATION = 3000;
    int cnt = (millis >= MINDURATION ? 1 : MINDURATION/millis);
    long start = System.currentTimeMillis();
    for (int i = 0; i < cnt; ++i) {
      try {
        Thread.sleep(millis);
      } catch (InterruptedException e) {
      }
    }
    long end = System.currentTimeMillis();
    return (end - start) / cnt;
  }

  public static void main(String[] args)
  {
    final int DATA[] = {345, 27, 1, 1962, 2, 8111, 6, 89, 864};
    for (int i = 0; i < DATA.length; ++i) {
      System.out.println("Aufruf von sleep(" + DATA[i] + ")");
      long result = testSleep(DATA[i]);
      System.out.print("  Ergebnis: " + result);
      double prec = ((double)result / DATA[i] - 1.0) * 100;
      System.out.println(" (" + (prec > 0 ? "+": "") + prec + " %)");
    }
  }
}