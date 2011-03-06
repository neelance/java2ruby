/* Listing1704.java */

import java.util.regex.*;

public class Listing1704
{
  public static void main(String[] args)
  {
    // Der zu verwendende Testsatz
    String satz = "Dies ist nur ein Test";
    
    // Jedes Whitespace-Zeichen soll zur 
    // Trennung verwendet werden
    Pattern p = Pattern.compile("\\s");
    
    // Verwendung der Methode split
    String[] result = p.split(satz);
    for (int x=0; x<result.length; x++) {
      System.out.println(result[x]);
    }
  }
}