/* Listing0907.java */

public class Listing0907
{
  public static Object getSmallest(Comparable[] objects)
  {
    Object smallest = objects[0];
    for (int i = 1; i < objects.length; ++i) {
      if (objects[i].compareTo(smallest) < 0) {
        smallest = objects[i];
      }
    }
    return smallest;
  }

  public static void bubbleSort(Comparable[] objects)
  {
    boolean sorted;
    do {
      sorted = true;
      for (int i = 0; i < objects.length - 1; ++i) {
        if (objects[i].compareTo(objects[i + 1]) > 0) {
          Comparable tmp = objects[i];
          objects[i] = objects[i + 1];
          objects[i + 1] = tmp;
          sorted = false;
        }
      }
    } while (!sorted);
  }

  public static void main(String[] args)
  {
    //Erzeugen eines String-Arrays
    Comparable[] objects = new Comparable[4];
    objects[0] = "STRINGS";
    objects[1] = "SIND";
    objects[2] = "PAARWEISE";
    objects[3] = "VERGLEICHBAR";
    //Ausgeben des kleinsten Elements
    System.out.println((String)getSmallest(objects));
    System.out.println("--");
    //Sortieren und Ausgaben
    bubbleSort(objects);
    for (int i = 0; i < objects.length; ++i) {
      System.out.println((String)objects[i]);
    }
  }
}