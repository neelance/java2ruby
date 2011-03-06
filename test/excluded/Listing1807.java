/* Listing1807.java */

import java.io.*;

public class Listing1807
{
  public static void main(String[] args)
  {
    Reader f;
    int c;
    String s;

    s =  "Das folgende Programm zeigt die Verwendung\r\n";
    s += "der Klasse StringReader am Beispiel eines\r\n";
    s += "Programms, das einen Reader konstruiert, der\r\n";
    s += "den Satz liest, der hier an dieser Stelle steht:\r\n";
    try {
      f = new StringReader(s);
      while ((c = f.read()) != -1) {
        System.out.print((char)c);
      }
      f.close();
    } catch (IOException e) {
      System.out.println("Fehler beim Lesen des Strings");
    }
  }
}