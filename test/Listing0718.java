/* Listing0718.java */

public class Listing0718
{
  public static String getAndPrint(String s)
  {
    System.out.println(s);
    return s;
  }

  public static void main(String[] args)
  {
    Son son = new Son();
  }
}

class Father
{
  private String s1 = Listing0718.getAndPrint("Father.s1");

  public Father()
  {
    Listing0718.getAndPrint("Father.<init>");
  }
}

class Son
extends Father
{
  private String s1 = Listing0718.getAndPrint("Son.s1");

  public Son()
  {
    Listing0718.getAndPrint("Son.<init>");
  }
}