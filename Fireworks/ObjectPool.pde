abstract class PoolableObject
{
  public boolean isAllocated;
  public ObjectPool belongingPool;
  
  abstract void initialize();
}


final class ObjectPool<T extends PoolableObject>
{
  final int poolSize;
  final ArrayList<T> pool;  
  int index = 0;
  final ArrayList<T> temporalInstanceList;
  int temporalInstanceCount = 0;
    
  ObjectPool(int pSize) {
    poolSize = pSize;
    pool = new ArrayList<T>(pSize);
    temporalInstanceList = new ArrayList<T>(pSize);
  }
  
  ObjectPool() {
    this(256);
  }

  T allocate() {
    if (isAllocatable() == false) {
      println("Object pool allocation failed. Too many objects created!");
      // Need exception handling
      return null;
    }
    T allocatedInstance = pool.get(index);
    
    allocatedInstance.isAllocated = true;
    index++;  

    return allocatedInstance;
  }
  
  T allocateTemporal() {
    T allocatedInstance = allocate();
    setTemporal(allocatedInstance);
    return allocatedInstance;
  }
  
  void add(T obj) {
    pool.add(obj);
  }
  
  boolean isAllocatable() {
    return index < poolSize;
  }
  
  void deallocate(T killedObject) {
    if (!killedObject.isAllocated) {
      return;
    }
    killedObject.initialize();
    killedObject.isAllocated = false;
    index--;
    pool.set(index, killedObject);
  }
  
  void update() {
    while(temporalInstanceCount > 0) {
      temporalInstanceCount--;
      deallocate(temporalInstanceList.get(temporalInstanceCount));
    }
    temporalInstanceList.clear();    // not needed when array
  }
  
  void setTemporal(T obj) {
    temporalInstanceList.add(obj);    // set when array
    temporalInstanceCount++;
  }
}
