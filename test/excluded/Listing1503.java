/* Listing1503.java */

import java.util.*;

public class Listing1503
{
  public static void main(String[] args)
  {
    HashSet set = new HashSet(10);
    int doubletten = 0;
    //Lottozahlen erzeugen
    while (set.size() < 6) {
      int num = (int)(Math.random() * 49) + 1;
      if (!set.add(new Integer(num))) {
        ++doubletten;
      }
    }
    //Lottozahlen ausgeben
    Iterator it = set.iterator();
    while (it.hasNext()) {
      System.out.println(((Integer)it.next()).toString());
    }
    System.out.println("Ignorierte Doubletten: " + doubletten);
  }
}