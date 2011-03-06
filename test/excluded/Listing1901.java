/* Listing1901.java */

import java.io.*;

public class Listing1901
{
  public static void main(String[] args)
  {
    try {
      FileOutputStream out = new FileOutputStream(
        args[0],
        true
      );
      for (int i = 0; i < 256; ++i) {
        out.write(i);
      }
      out.close();
    } catch (Exception e) {
      System.err.println(e.toString());
      System.exit(1);
    }
  }
}