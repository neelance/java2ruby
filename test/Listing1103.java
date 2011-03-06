/* Listing1103.java */

public class Listing1103
{
  public static void main(String[] args)
  {
    String satz = "Dies ist nur ein Test";
    String[] result = satz.split("\\s");
    for (int x=0; x<result.length; x++) {
      System.out.println(result[x]);
    }
  }
}