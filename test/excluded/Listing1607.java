/* Listing1607.java */

public class Listing1607
{
  public static void main(String[] args)
  {
    int[] ar = {0,0,0,0,0,0,0,0,0,0};

    for (int i = 0; i < 10; ++i) {
      System.arraycopy(ar,0,ar,1,9);
      ar[0] = i;
    }
    System.out.print("ar = ");
    for (int i = 0; i < 10; ++i) {
      System.out.print(ar[i] + " ");
    }
    System.out.println("");
  }
}