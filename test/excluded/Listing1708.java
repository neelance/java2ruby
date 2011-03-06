/* Listing1708.java */

import java.text.*;

public class Listing1708
{
  public static void print(double value, String format)
  {
    DecimalFormat df = new DecimalFormat(format);
    System.out.println(df.format(value));
  }
  public static void main(String[] args)
  {
    double value = 1768.3518;
    print(value, "#0.0");
    print(value, "#0.000");
    print(value, "000000.000");
    print(value, "#.000000");
    print(value, "#,###,##0.000");
    print(value, "0.000E00");
  }
}