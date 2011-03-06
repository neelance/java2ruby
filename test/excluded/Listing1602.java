/* Listing1602.java */

import java.util.*;

public class Listing1602
{
  public static void main(String[] args)
  {
    //Zuerst Ausgabe des aktuellen Datums
    GregorianCalendar cal = new GregorianCalendar();
    //cal.setTimeZone(TimeZone.getTimeZone("ECT")); 
    printCalendarInfo(cal);
    System.out.println("---");

    //Nun Ausgabe der Informationen zum 22.6.1910,
    //dem Geburtstag von Konrad Zuse
    cal.set(Calendar.DATE, 22);
    cal.set(Calendar.MONTH, 6 - 1);
    cal.set(Calendar.YEAR, 1910);
    printCalendarInfo(cal);
    //cal.setTime(cal.getTime()); 
  }

  public static void printCalendarInfo(GregorianCalendar cal)
  {
    //Aera
    int value = cal.get(Calendar.ERA);
    if (value == cal.BC) {
      System.out.println("Aera.......: vor Christi Geburt");
    } else if (value == cal.AD) {
      System.out.println("Aera.......: Anno Domini");
    } else {
      System.out.println("Aera.......: unbekannt");
    }
    //Datum
    System.out.println(
      "Datum......: " +
      cal.get(Calendar.DATE) + "." +
      (cal.get(Calendar.MONTH)+1) + "." +
      cal.get(Calendar.YEAR)
    );
    //Zeit
    System.out.println(
      "Zeit.......: " +
      cal.get(Calendar.HOUR_OF_DAY) + ":" +
      cal.get(Calendar.MINUTE) + ":" +
      cal.get(Calendar.SECOND) + " (+" +
      cal.get(Calendar.MILLISECOND) + " ms)"
    );
    //Zeit, amerikanisch
    System.out.print(
      "Am.Zeit....: " +
      cal.get(Calendar.HOUR) + ":" +
      cal.get(Calendar.MINUTE) + ":" +
      cal.get(Calendar.SECOND)
    );
    value = cal.get(Calendar.AM_PM);
    if (value == cal.AM) {
      System.out.println(" AM");
    } else if (value == cal.PM) {
      System.out.println(" PM");
    }
    //Tag
    System.out.println(
      "Tag........: " +
      cal.get(Calendar.DAY_OF_YEAR) + ". im Jahr"
    );
    System.out.println(
      "             " +
      cal.get(Calendar.DAY_OF_MONTH) + ". im Monat"
    );
    //Woche
    System.out.println(
      "Woche......: " +
      cal.get(Calendar.WEEK_OF_YEAR) + ". im Jahr"
    );
    System.out.println(
      "             " +
      cal.get(Calendar.WEEK_OF_MONTH) + ". im Monat"
    );
    //Wochentag
    System.out.print(
      "Wochentag..: " +
      cal.get(Calendar.DAY_OF_WEEK_IN_MONTH) +
      ". "
    );
    value = cal.get(Calendar.DAY_OF_WEEK);
    if (value == cal.SUNDAY) {
      System.out.print("Sonntag");
    } else if (value == cal.MONDAY) {
      System.out.print("Montag");
    } else if (value == cal.TUESDAY) {
      System.out.print("Dienstag");
    } else if (value == cal.WEDNESDAY) {
      System.out.print("Mittwoch");
    } else if (value == cal.THURSDAY) {
      System.out.print("Donnerstag");
    } else if (value == cal.FRIDAY) {
      System.out.print("Freitag");
    } else if (value == cal.SATURDAY) {
      System.out.print("Samstag");
    } else {
      System.out.print("unbekannt");
    }
    System.out.println(" im Monat");
    //Zeitzone
    System.out.println(
      "Zeitzone...: " +
      cal.get(Calendar.ZONE_OFFSET)/3600000 +
      " Stunden"
    );
    System.out.println(
      "Sommerzeit.: " +
      cal.get(Calendar.DST_OFFSET)/3600000 +
      " Stunden"
    );
  }
}