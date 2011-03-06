/* Listing1905.java */

import java.io.*;

public class Listing1905
{
  public static void main(String[] args)
  {
    try {
      DataInputStream in = new DataInputStream(
                           new BufferedInputStream(
                           new FileInputStream("test.txt")));
      System.out.println(in.readInt());
      System.out.println(in.readInt());
      System.out.println(in.readDouble());
      System.out.println(in.readUTF());
      System.out.println(in.readUTF());
      in.close();
    } catch (IOException e) {
      System.err.println(e.toString());
    }
  }
}