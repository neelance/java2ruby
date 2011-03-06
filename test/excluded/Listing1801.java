/* Listing1801.java */

import java.io.*;

public class Listing1801
{
  public static void main(String[] args)
  {
    String hello = "Hallo JAVA\r\n";
    FileWriter f1;

    try {
      f1 = new FileWriter("hallo.txt");
      f1.write(hello);
      f1.close();
    } catch (IOException e) {
      System.out.println("Fehler beim Erstellen der Datei");
    }
  }
}