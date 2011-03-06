/* Listing1504.java */

import java.util.*;

public class Listing1504
{
  public static void main(String[] args)
  {
    HashMap h = new HashMap();

    //Pflege der Aliase
    h.put("Fritz","f.mueller@test.de");
    h.put("Franz","fk@b-blabla.com");
    h.put("Paula","user0125@mail.uofm.edu");
    h.put("Lissa","lb3@gateway.fhdto.northsurf.dk");

    //Ausgabe
    Iterator it = h.entrySet().iterator(); 
    while (it.hasNext()) {
      Map.Entry entry = (Map.Entry)it.next();
      System.out.println(
        (String)entry.getKey() + " --> " +
        (String)entry.getValue()
      );
    } 
  }
}