/* Listing1015.java */

interface StringIterator
{
  public boolean hasNext();
  public String next();
}

class StringArray
{
  String[] data;

  public StringArray(String[] data)
  {
    this.data = data;
  }

  public StringIterator getElements()
  {
    return new StringIterator()
    {
      int index = 0;
      public boolean hasNext()
      {
        return index < data.length;
      }
      public String next()
      {
        return data[index++];
      }
    };
  }
}

public class Listing1015
{
  static final String[] SAYHI = {"Hi", "Iterator", "Buddy"};

  public static void main(String[] args)
  {
    //Collection erzeugen
    StringArray strar = new StringArray(SAYHI);
    //Iterator beschaffen und Elemente durchlaufen
    StringIterator it = strar.getElements();
    while (it.hasNext()) {
      System.out.println(it.next());
    }
  }
}