/* Listing1808.java */

import java.io.*;

public class Listing1808
{
  public static void main(String[] args)
  {
    BufferedReader f;
    String line;

    try {
      f = new BufferedReader(
          new FileReader("c:\\config.sys"));
      while ((line = f.readLine()) != null) {
        System.out.println(line);
      }
      f.close();
    } catch (IOException e) {
      System.out.println("Fehler beim Lesen der Datei");
    }
  }
}