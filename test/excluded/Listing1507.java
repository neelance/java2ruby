/* Listing1507.java */

import java.util.*;

public class Listing1507
{
  public static void main(String[] args)
  {
    //Konstruieren des Sets
    List l = new ArrayList();
    l.add("Kiwi");
    l.add("Kirsche");
    l.add("Ananas");
    l.add("Zitrone");
    l.add("Grapefruit");
    l.add("Banane");
    //Unsortierte Ausgabe
    Iterator it = l.iterator();
    while (it.hasNext()) {
      System.out.println((String)it.next());
    }
    System.out.println("---");
    //Sortierte Ausgabe
    Collections.sort(l);
    it = l.iterator();
    while (it.hasNext()) {
      System.out.println((String)it.next());
    }
  }
}