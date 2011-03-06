/* Listing1701.java */

import java.util.regex.*;

public class Listing1701
{
  public static void main(String[] args)
  {
    // Erzeugen eines Pattern-Objektes für den Ausdruck a*b
    Pattern p = Pattern.compile("a*b");

    // Erzeugen eines Matcher-Objektes für die Zeichenkette
    Matcher m = p.matcher("aaaaab");
		
    // Test, ob die Zeichenkette vom Ausdruck beschrieben wird
    boolean b = m.matches();  
  }
}