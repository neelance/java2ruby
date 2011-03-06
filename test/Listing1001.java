/* Listing1001.java */

class Outer
{
  String name;
  int    number;

  public void createAndPrintInner(String iname)
  {
    Inner inner = new Inner();
    inner.name = iname;
    System.out.println(inner.getQualifiedName());
  }

  class Inner
  {
    private String name;

    private String getQualifiedName()
    {
      return number + ":" + Outer.this.name + "." + name;
    }
  }
}

public class Listing1001
{
  public static void main(String[] args)
  {
    Outer outer = new Outer(); 
    outer.name = "OuterInstance";
    outer.number = 77;
    outer.createAndPrintInner("InnerInstance");
  }
}
