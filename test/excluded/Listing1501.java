/* Listing1501.java */

import java.util.*;

public class Listing1501
{
  static void fillList(List list)
  {
    for (int i = 0; i < 10; ++i) {
      list.add("" + i);
    }
    list.remove(3);
    list.remove("5");
  }

  static void printList(List list)
  {
    for (int i = 0; i < list.size(); ++i) {
      System.out.println((String)list.get(i));
    }
    System.out.println("---");
  }

  public static void main(String[] args)
  {
    //Erzeugen der LinkedList
    LinkedList list1 = new LinkedList();
    fillList(list1);
    printList(list1);
    //Erzeugen der ArrayList
    ArrayList list2 = new ArrayList();
    fillList(list2);
    printList(list2);
    //Test von removeAll
    list2.remove("0");
    list1.removeAll(list2);
    printList(list1);
  }
}