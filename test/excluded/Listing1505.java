/* Listing1505.java */

import java.util.*;

public class Listing1505
{
  public static void main(String[] args)
  {
    //Konstruieren des Sets
    TreeSet s = new TreeSet();
    s.add("Kiwi");
    s.add("Kirsche");
    s.add("Ananas");
    s.add("Zitrone");
    s.add("Grapefruit");
    s.add("Banane");
    //Sortierte Ausgabe
    Iterator it = s.iterator();
    while (it.hasNext()) {
      System.out.println((String)it.next());
    }
  }
}