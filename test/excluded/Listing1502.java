/* Listing1502.java */

import java.util.*;

public class Listing1502
{
  public static void main(String[] args)
  {
    //Füllen der Liste
    ArrayList list = new ArrayList();
    for (int i = 1; i <= 20; ++i) {
      list.add("" + i);
    }
    //Löschen von Elementen über Iterator
    Iterator it = list.iterator();
    while (it.hasNext()) {
      String s = (String) it.next();
      if (s.startsWith("1")) {
        it.remove();
      }
    }
    //Ausgeben der verbleibenden Elemente
    it = list.iterator();
    while (it.hasNext()) {
      System.out.println((String) it.next());
    }
  }
}