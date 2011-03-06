/* Listing1608.java */

import java.io.*;

public class Listing1608
{
  public static void main(String[] args)
  {
    try {
      Runtime.getRuntime().exec("notepad");
    } catch (Exception e) {
      System.err.println(e.toString());
    }
  }
}