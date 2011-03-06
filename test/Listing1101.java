/* Listing1101.java */

public class Listing1101
{
  public static void main(String[] args)
  {
    String s1;
    s1 =  "Auf der Mauer";
    s1 += ", auf der Lauer";
    s1 += ", sitzt \'ne kleine Wanze";
    System.out.println(s1);

    for (int i = 1; i <= 5; ++i) {
      s1 = s1.substring(0,s1.length()-1);
      System.out.println(s1);
    }
  }
}