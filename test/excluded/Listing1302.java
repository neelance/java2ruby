/* Listing1302.java */

public class Listing1302
{
  private int cnt = 0;

  public void printNext()
  {
    int value = cnt;
    System.out.println("value = " + value);
    int cnt = value + 1; 
  }

  public static void main(String[] args)
  {
    Listing1302 obj = new Listing1302();
    obj.printNext();
    obj.printNext();
    obj.printNext();
  }
}