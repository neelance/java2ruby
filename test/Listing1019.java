/* Listing1019.java */

interface Observer
{
  public void update(Subject subject);
}

class Subject
{
  Observer[] observers   = new Observer[5];
  int        observerCnt = 0;

  public void attach(Observer observer)
  {
    observers[observerCnt++] = observer;
  }

  public void detach(Observer observer)
  {
    for (int i = 0; i < observerCnt; ++i) {
      if (observers[i] == observer) {
        --observerCnt;
        for (;i < observerCnt; ++i) {
          observers[i] = observers[i + 1];
        }
        break;
      }
    }
  }

  public void fireUpdate()
  {
    for (int i = 0; i < observerCnt; ++i) {
      observers[i].update(this);
    }
  }
}

class Counter
{
  int cnt = 0;
  Subject subject = new Subject();

  public void attach(Observer observer)
  {
    subject.attach(observer);
  }

  public void detach(Observer observer)
  {
    subject.detach(observer);
  }

  public void inc()
  {
    if (++cnt % 3 == 0) {
      subject.fireUpdate();
    }
  }
}

public class Listing1019
{
  public static void main(String[] args)
  {
    Counter counter = new Counter();
    counter.attach(
      new Observer()
      {
        public void update(Subject subject)
        {
          System.out.print("divisible by 3: ");
        }
      }
    );
    while (counter.cnt < 10) {
      counter.inc();
      System.out.println(counter.cnt);
    }
  }
}