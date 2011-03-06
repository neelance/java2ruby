/* Listing1705.java */

import java.math.*;

public class Listing1705
{
  public static void printFaculty(int n)
  {
    BigInteger bi = new BigInteger("1");
    for (int i = 2; i <= n; ++i) {
      bi = bi.multiply(new BigInteger("" + i));
    }
    System.out.println(n + "! is " + bi.toString());
  }

  public static void main(String[] args)
  {
    for (int i = 30; i <= 40; ++i) {
      printFaculty(i);
    }
  }
}