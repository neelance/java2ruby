/* Listing1902.java */

import java.io.*;

public class Listing1902
{
  public static void main(String[] args)
  {
    try {
      DataOutputStream out = new DataOutputStream(
                             new BufferedOutputStream(
                             new FileOutputStream("test.txt")));
      out.writeInt(1);
      out.writeInt(-1);
      out.writeDouble(Math.PI);
      out.writeUTF("h‰ﬂliches");
      out.writeUTF("Entlein");
      out.close();
    } catch (IOException e) {
      System.err.println(e.toString());
    }
  }
}