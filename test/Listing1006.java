/* Listing1006.java */

class IntWrapper
{
  public int value;

  public IntWrapper(int value)
  {
    this.value = value;
  }
}

public class Listing1006
{
  public static void inc1(IntWrapper w)
  {
    ++w.value;
  }

  public static void inc2(int[] i)
  {
    ++i[0];
  }

  public static void main(String[] args)
  {
    //Variante 1: Übergabe in einem veränderlichen Wrapper
    IntWrapper i = new IntWrapper(10);
    System.out.println("i = " + i.value);
    inc1(i);
    System.out.println("i = " + i.value);
    //Variante 2: Übergabe als Array-Element
    int[] j = new int[] {10};
    System.out.println("j = " + j[0]);
    inc2(j);
    System.out.println("j = " + j[0]);
  }
}
