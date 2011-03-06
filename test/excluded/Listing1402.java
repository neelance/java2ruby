/* Listing1402.java */

import java.util.*;

public class Listing1402
{
  public static void main(String[] args)
  {
    Stack s = new Stack();

    s.push("Erstes Element");
    s.push("Zweites Element");
    s.push("Drittes Element");
    while (true) {
      try {
        System.out.println(s.pop());
      } catch (EmptyStackException e) {
        break;
      }
    }
  }
}