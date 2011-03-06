/* Listing1906.java */

import java.io.*;
import java.util.zip.*;

public class Listing1906
{
  public static void main(String[] args)
  {
    if (args.length != 1) {
      System.out.println("Usage: java Listing1906 file");
      System.exit(1);
    }
    try {
      CheckedInputStream in = new CheckedInputStream(
        new FileInputStream(args[0]),
        new Adler32()
      );
      byte[] buf = new byte[4096];
      int len;
      while ((len = in.read(buf)) > 0) {
        //nichts
      }
      System.out.println(in.getChecksum().getValue());
      in.close();
    } catch (IOException e) {
      System.err.println(e.toString());
    }
  }
}