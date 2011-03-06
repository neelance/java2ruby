/* Listing1004.java */

class Outer3
{
  static class Inner3
  {
    public void print()
    {
      System.out.println("Inner3Instance");
    }
  }
}

public class Listing1004
{
  public static void main(String[] args)
  {
    Outer3.Inner3 inner = new Outer3.Inner3();
    inner.print();
  }
}
