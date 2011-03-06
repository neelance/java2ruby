/* Listing1206.java */

public class Listing1206
{
  public static void main(String[] args)
  {
    int i, j, base = 0;
    String[] numbers = new String[3];

    numbers[0] = "10";
    numbers[1] = "20";
    numbers[2] = "30";
    try {
      for (base = 10; base >= 2; --base) {
        for (j = 0; j <= 3; ++j) {
          i = Integer.parseInt(numbers[j],base);
          System.out.println(
            numbers[j]+" base "+base+" = "+i
          );
        }
      }
    } catch (IndexOutOfBoundsException e1) {
      System.out.println(
        "***IndexOutOfBoundsException: " + e1.toString()
      );
    } catch (NumberFormatException e2) {
      System.out.println(
        "***NumberFormatException: " + e2.toString()
      );
    }
  }
}