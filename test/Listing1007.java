/* Listing1007.java */

public class Listing1007
{
  public static void mitAutoboxing(int arg)
  {
    Integer i = arg;
    int j = i + 1;
    System.out.println(i + " " + j);
  }

  public static void main(String[] args)
  {
    mitAutoboxing(new Integer(17));
  }
}