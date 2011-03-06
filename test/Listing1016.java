/* Listing1016.java */

class Delegate
{
  private Delegator delegator;

  public Delegate(Delegator delegator)
  {
    this.delegator = delegator;
  }

  public void service1()
  {
  }

  public void service2()
  {
  }
}

interface Delegator
{
  public void commonDelegatorServiceA();
  public void commonDelegatorServiceB();
}

class Client1
implements Delegator
{
  private Delegate delegate;

  public Client1()
  {
    delegate = new Delegate(this);
  }

  public void service1()
  {
    //implementiert einen Service und benutzt
    //dazu eigene Methoden und die des
    //Delegate-Objekts
  }

  public void commonDelegatorServiceA()
  {
  }

  public void commonDelegatorServiceB()
  {
  }
}

class Client2
implements Delegator
{
  private Delegate delegate;

  public Client2()
  {
    delegate = new Delegate(this);
  }

  public void commonDelegatorServiceA()
  {
  }

  public void commonDelegatorServiceB()
  {
  }
}

public class Listing1016
{
  public static void main(String[] args)
  {
    Client1 client = new Client1();
    client.service1();
  }
}