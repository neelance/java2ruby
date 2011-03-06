/* Listing1401.java */

import java.util.*;

public class Listing1401
{
  public static void main(String[] args)
  {
    Vector v = new Vector();

    v.addElement("eins");
    v.addElement("drei");
    v.insertElementAt("zwei",1);
    for (Enumeration el=v.elements(); el.hasMoreElements(); ) {
      System.out.println((String)el.nextElement());
    }
  }
}