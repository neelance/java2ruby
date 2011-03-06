/* Listing1002.java */

class Outer2
{
  public void print()
  {
    final int value = 10;

    class Inner2
    {
      public void print()
      {
        System.out.println("value = " + value);
      }
    }

    Inner2 inner = new Inner2();
    inner.print();
  }
}

public class Listing1002
{
  public static void main(String[] args)
  {
    Outer2 outer = new Outer2();
    outer.print();
  }
}