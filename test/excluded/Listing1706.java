/* Listing1706.java */

import java.math.*;

public class Listing1706
{
  public static final BigDecimal ZERO = new BigDecimal("0");
  public static final BigDecimal ONE  = new BigDecimal("1");
  public static final BigDecimal TWO  = new BigDecimal("2");

  public static BigDecimal sqrt(BigDecimal x, int digits)
  {
    BigDecimal zero = ZERO.setScale(digits + 10);
    BigDecimal one  = ONE.setScale(digits + 10);
    BigDecimal two  = TWO.setScale(digits + 10);
    BigDecimal maxerr = one.movePointLeft(digits);
    BigDecimal lower = zero;
    BigDecimal upper = x.compareTo(one) <= 0 ? one : x;
    BigDecimal mid;
    while (true) {
      mid = lower.add(upper).divide(two, BigDecimal.ROUND_HALF_UP);
      BigDecimal sqr = mid.multiply(mid);
      BigDecimal error = x.subtract(sqr).abs();
      if (error.compareTo(maxerr) <= 0) {
        break;
      }
      if (sqr.compareTo(x) < 0) {
        lower = mid;
      } else {
        upper = mid;
      }
    }
    return mid;
  }

  public static void main(String[] args)
  {
    BigDecimal sqrtTwo = sqrt(TWO, 100);
    BigDecimal apxTwo  = sqrtTwo.multiply(sqrtTwo);
    System.out.println("sqrt(2): " + sqrtTwo.toString());
    System.out.println("check  : " + apxTwo.toString());
  }
}