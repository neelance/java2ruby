/* Listing1702.java */

import java.util.regex.*;

public class Listing1702
{
  public static void main(String[] args)
  {
    // Testet die Zeichenkette auf das Pattern
    boolean b = Pattern.matches("a*b", "aaaaab");
  }
}