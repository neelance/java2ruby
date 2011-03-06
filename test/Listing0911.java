/* Listing0911.java */

interface Debug
{
  public static final boolean FUNCTIONALITY1 = false;
  public static final boolean FUNCTIONALITY2 = true;
  public static final boolean FUNCTIONALITY3 = false;
  public static final boolean FUNCTIONALITY4 = false;
}

public class Listing0911
implements Debug
{
  public static void main(String[] args)
  {
    //...
    if (FUNCTIONALITY1) {
      System.out.println("...");
    }
    //...
    if (FUNCTIONALITY2) {
      System.out.println("...");
    }
    //...
  }
}