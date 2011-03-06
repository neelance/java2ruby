/* Listing1603.java */

import java.util.*;

public class Listing1603
{
  public static void main(String[] args)
  {
    GregorianCalendar cal   = new GregorianCalendar();
    cal.set(Calendar.DATE, 30);
    cal.set(Calendar.MONTH, 10 - 1);
    cal.set(Calendar.YEAR, 1908);
    showDate(cal);
    addOne(cal, Calendar.DATE);
    addOne(cal, Calendar.DATE);
    addOne(cal, Calendar.MONTH);
    addOne(cal, Calendar.MONTH);
    addOne(cal, Calendar.YEAR);
    addOne(cal, Calendar.YEAR);

    cal.add(Calendar.DATE, -2);
    cal.add(Calendar.MONTH, -2);
    cal.add(Calendar.YEAR, -2);
    showDate(cal);
  }

  public static void addOne(Calendar cal, int field)
  {
    cal.add(field,1);
    showDate(cal);
  }

  public static void showDate(Calendar cal)
  {
    String ret = "";
    int    value = cal.get(Calendar.DAY_OF_WEEK);

    switch (value) {
    case Calendar.SUNDAY:
      ret += "Sonntag";
      break;
    case Calendar.MONDAY:
      ret += "Montag";
      break;
    case Calendar.TUESDAY:
      ret += "Dienstag";
      break;
    case Calendar.WEDNESDAY:
      ret += "Mittwoch";
      break;
    case Calendar.THURSDAY:
      ret += "Donnerstag";
      break;
    case Calendar.FRIDAY:
      ret += "Freitag";
      break;
    case Calendar.SATURDAY:
      ret += "Samstag";
      break;
    }
    ret += ", den ";
    ret += cal.get(Calendar.DATE) + ".";
    ret += (cal.get(Calendar.MONTH)+1) + ".";
    ret += cal.get(Calendar.YEAR);
    System.out.println(ret);
  }
}