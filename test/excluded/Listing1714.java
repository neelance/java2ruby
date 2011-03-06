/* Listing1714.java */

import java.util.*;

public class Listing1714
{
  public static void sayHello(Locale locale)
  {
    System.out.print(locale + ": ");
    ResourceBundle textbundle = ResourceBundle.getBundle(
      "MyTextResource",
      locale
    );
    if (textbundle != null) {
      System.out.print(textbundle.getString("Hi") + ", ");
      System.out.println(textbundle.getString("To"));
    }
  }

  public static void main(String[] args)
  {
    sayHello(Locale.getDefault());
    sayHello(new Locale("de", "CH"));
    sayHello(Locale.US);
    sayHello(Locale.FRANCE);
  }
}