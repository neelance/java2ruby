/* Listing1610.java */

import java.util.*;

public class Listing1610
{
  public static void main(String[] args)
  {
    final int SIZE = 20;
    int[] values = new int[SIZE];
    Random rand = new Random();
    //Erzeugen und Ausgeben des unsortierten Arrays
    for (int i = 0; i < SIZE; ++i) {
      values[i] = rand.nextInt(10 * SIZE);
    }
    for (int i = 0; i < SIZE; ++i) {
      System.out.println(values[i]);
    }
    //Sortieren des Arrays
    Arrays.sort(values);
    //Ausgeben der Daten
    System.out.println("---");
    for (int i = 0; i < SIZE; ++i) {
      System.out.println(values[i]);
    }
  }
}