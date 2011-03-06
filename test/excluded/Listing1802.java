/* Listing1802.java */

import java.io.*;

public class Listing1802
{
  public static void main(String[] args)
  {
     Writer f1;
     BufferedWriter f2;
     String s;

     try {
       f1 = new FileWriter("buffer.txt");
       f2 = new BufferedWriter(f1);
       for (int i = 1; i <= 10000; ++i) {
         s = "Dies ist die " + i + ". Zeile";
         f2.write(s);
         f2.newLine();
       }
       f2.close();
       f1.close();
    } catch (IOException e) {
      System.out.println("Fehler beim Erstellen der Datei");
    }
  }
}