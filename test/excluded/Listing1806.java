/* Listing1806.java */

import java.io.*;

public class Listing1806
{
  public static void main(String[] args)
  {
    FileReader f;
    int c;

    try {
      f = new FileReader("c:\\config.sys");
      while ((c = f.read()) != -1) {
         System.out.print((char)c);
      }
      f.close();
    } catch (IOException e) {
      System.out.println("Fehler beim Lesen der Datei");
    }
  }
}