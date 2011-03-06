/* Listing1601.java */

import java.util.*;

public class Listing1601
{
  public static void main(String[] args)
  {
    BitSet b = new BitSet();
    Random r = new Random();

    System.out.print("Mein Lottotip: ");
    int cnt = 0;
    while (cnt < 6) {
      int num = 1 + Math.abs(r.nextInt()) % 49;
      if (!b.get(num)) {
        b.set(num);
        ++cnt;
      }
    }
    for (int i = 1; i <= 49; ++i) {
      if (b.get(i)) {
        System.out.print(i + " ");
      }
    }
    System.out.println("");
  }
}