/* Listing1809.java */

import java.io.*;

public class Listing1809
{
  public static void main(String[] args)
  {
    LineNumberReader f;
    String line;

    try {
      f = new LineNumberReader(
          new FileReader("c:\\config.sys"));
      while ((line = f.readLine()) != null) {
        System.out.print(f.getLineNumber() + ": ");
        System.out.println(line);
      }
      f.close();
    } catch (IOException e) {
      System.out.println("Fehler beim Lesen der Datei");
    }
  }
}