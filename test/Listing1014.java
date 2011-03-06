/* Listing1014.java */

//------------------------------------------------------------------
//Abstrakte Produkte
//------------------------------------------------------------------
abstract class Product1
{
  public abstract String name();
}

abstract class Product2
{
  public abstract String name();
}

//------------------------------------------------------------------
//Abstrakte Factory
//------------------------------------------------------------------
abstract class ProductFactory
{
  public abstract Product1 createProduct1();

  public abstract Product2 createProduct2();

  public static ProductFactory getFactory(String variant)
  {
    ProductFactory ret = null;
    if (variant.equals("A")) {
      ret = new ConcreteFactoryVariantA();
    } else if (variant.equals("B")) {
      ret = new ConcreteFactoryVariantB();
    }
    return ret;
  }

  public static ProductFactory getDefaultFactory()
  {
    return getFactory("A");
  }
}

//------------------------------------------------------------------
//Konkrete Produkte für Implementierungsvariante A
//------------------------------------------------------------------
class Product1VariantA
extends Product1
{
  public String name() {
    return "foo";
  }
}

class Product2VariantA
extends Product2
{
  public String name() {
    return "bar";
  }}

//------------------------------------------------------------------
//Konkrete Factory für Implementierungsvariante A
//------------------------------------------------------------------
class ConcreteFactoryVariantA
extends ProductFactory
{
  public Product1 createProduct1()
  {
    return new Product1VariantA();
  }

  public Product2 createProduct2()
  {
    return new Product2VariantA();
  }
}

//------------------------------------------------------------------
//Konkrete Produkte für Implementierungsvariante B
//------------------------------------------------------------------
class Product1VariantB
extends Product1
{
  public String name() {
    return "rubbish";
  }
}

class Product2VariantB
extends Product2
{
  public String name() {
    return "waste";
  }
}

//------------------------------------------------------------------
//Konkrete Factory für Implementierungsvariante B
//------------------------------------------------------------------
class ConcreteFactoryVariantB
extends ProductFactory
{
  public Product1 createProduct1()
  {
    return new Product1VariantB();
  }

  public Product2 createProduct2()
  {
    return new Product2VariantB();
  }
}

//------------------------------------------------------------------
//Beispielanwendung
//------------------------------------------------------------------
public class Listing1014
{
  public static void main(String[] args)
  {
    ProductFactory fact = ProductFactory.getDefaultFactory();
    Product1 prod1 = fact.createProduct1();
    Product2 prod2 = fact.createProduct2();
    System.out.println(prod1.name());
    System.out.println(prod2.name());
  }
}
