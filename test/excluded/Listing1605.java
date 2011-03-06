/* Listing1605.java */

public class Listing1605
{
  public static void main(String[] args)
  {
    long t1, t2;
    int  actres, sumres = 0, i = 0;
    while (true) {
      ++i;
      t1 = System.currentTimeMillis();
      while (true) {
        t2 = System.currentTimeMillis();
        if (t2 != t1) {
          actres = (int)(t2 - t1);
          break;
        }
      }
      sumres += actres;
      System.out.print("it="+i+", ");
      System.out.print("actres="+actres+" msec., ");
      System.out.print("avgres="+(sumres/i)+" msec.");
      System.out.println("");
      try {
        Thread.sleep(500);
      } catch (InterruptedException e) {
        //nichts
      }
    }
  }
}