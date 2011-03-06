/* Listing0813.java */

class SingleValue
{
  protected int value1;

  public SingleValue(int value1)
  {
    this.value1 = value1;
    print();
  }

  public void print()
  {
    System.out.println("value = " + value1);
  }
}

class ValuePair
extends SingleValue
{
  protected int value2;

  public ValuePair(int value1, int value2)
  {
    super(value1);
    this.value2 = value2;
  }

  public void print()
  {
    System.out.println(
      "value = (" + value1 + "," + value2 + ")"
    );
  }
}

public class Listing0813
{
  public static void main(String[] args)
  {
    new ValuePair(10,20);
  }
}