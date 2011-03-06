/* Listing1005.java */

public class Listing1005
{
  public static void ohneAutoboxing(int arg)
  {
    Integer i = new Integer(arg);
    int j = i.intValue() + 1;
    System.out.println(i + " " + j);
  }

  public static void main(String[] args)
  {
    ohneAutoboxing(17);
  }
}