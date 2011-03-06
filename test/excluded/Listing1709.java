/* Listing1709.java */

import java.util.*;
import java.text.*;

public class Listing1709
{
  public static void print(Calendar cal, int style)
  {
    DateFormat df;
    df = DateFormat.getDateInstance(style);
    System.out.print(df.format(cal.getTime()) + " / ");
    df = DateFormat.getTimeInstance(style);
    System.out.println(df.format(cal.getTime()));
  }

  public static void main(String[] args)
  {
    GregorianCalendar cal = new GregorianCalendar();
    print(cal, DateFormat.SHORT);
    print(cal, DateFormat.MEDIUM);
    print(cal, DateFormat.LONG);
    print(cal, DateFormat.FULL);
    print(cal, DateFormat.DEFAULT);
  }
}