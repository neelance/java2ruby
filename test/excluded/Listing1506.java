/* Listing1506.java */

import java.util.*;

public class Listing1506
{
  public static void main(String[] args)
  {
    //Konstruieren des Sets
    TreeSet s = new TreeSet(new ReverseStringComparator());
    s.add("Kiwi");
    s.add("Kirsche");
    s.add("Ananas");
    s.add("Zitrone");
    s.add("Grapefruit");
    s.add("Banane");
    //Rückwärts sortierte Ausgabe
    Iterator it = s.iterator();
    while (it.hasNext()) {
      System.out.println((String)it.next());
    }
  }
}

class ReverseStringComparator
implements Comparator
{
  public int compare(Object o1, Object o2)
  {
    return ((String)o2).compareTo((String)o1);
  }
}