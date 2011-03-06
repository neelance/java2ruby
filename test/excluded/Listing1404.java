/* Listing1404.java */

import java.util.*;

public class Listing1404
{
  private final static int MAXNUM = 20;

  public static void main(String[] args)
  {
    BitSet  b;
    boolean ok;

    System.out.println("Die Primzahlen <= " + MAXNUM + ":");
    b = new BitSet();
    for (int i = 2; i <= MAXNUM; ++i) {
      ok = true;
      for (int j = 2; j < i; ++j) {
        if (b.get(j) && i % j == 0) {
          ok = false;
          break;
        }
      }
      if (ok) {
        b.set(i);
      }
    }
    for (int i = 1; i <= MAXNUM; ++i) {
      if (b.get(i)) {
        System.out.println("  " + i);
      }
    }
  }
}