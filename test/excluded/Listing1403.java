/* Listing1403.java */

import java.util.*;

public class Listing1403
{
  public static void main(String[] args)
  {
    Hashtable h = new Hashtable();

    //Pflege der Aliase
    h.put("Fritz","f.mueller@test.de");
    h.put("Franz","fk@b-blabla.com");
    h.put("Paula","user0125@mail.uofm.edu");
    h.put("Lissa","lb3@gateway.fhdto.northsurf.dk");

    //Ausgabe
    Enumeration e = h.keys();
    while (e.hasMoreElements()) {
      String alias = (String)e.nextElement();
      System.out.println(
        alias + " --> " + h.get(alias)
      );
    }
  }
}