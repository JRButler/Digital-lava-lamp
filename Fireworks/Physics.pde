// This tab is dependent on ObjectPool.pde

class PhysicsBody extends PoolableObject
{
  PhysicsBodyComponent component;
  
  float xPosition, yPosition;
  float xVelocity, yVelocity;
  float xAcceleration, yAcceleration;
  
  PhysicsBody(float x, float y) {
    xPosition = x;
    yPosition = y;
  }
  PhysicsBody() {
    this(0f, 0f);
  }
  
  void initialize() {
    component = null;
    xPosition = 0f;
    yPosition = 0f;
    xVelocity = 0f;
    yVelocity = 0f;
    xAcceleration = 0f;
    yAcceleration = 0f;
  }
  
  float getMass() {
    return component.getMass();
  }
  float getRadius() {  // Body is regarded as a simple sphere
    return component.getRadius();
  }

  void applyForce(float xForce, float yForce) {
    xAcceleration += xForce / getMass();
    yAcceleration += yForce / getMass();
  }
  
  void update() {
    component.update(this);
    xVelocity += xAcceleration;
    xAcceleration = 0;
    yVelocity += yAcceleration;
    yAcceleration = 0;
    xPosition += xVelocity;
    yPosition += yVelocity;
  }
}

abstract class PhysicsBodyComponent
{
  PhysicsBodyComponent(float m, float r) {
  }
  
  abstract void update(PhysicsBody body);
  
  abstract float getMass();
  abstract float getRadius();
}

class ImmutablePhysicsBodyComponent extends PhysicsBodyComponent
{
  final float mass;
  final float radius;  // regard as a simple sphere
  
  ImmutablePhysicsBodyComponent(float m, float r) {
    super(m, r);
    mass = m;
    radius = r;
  }
  
  float getMass() {
    return mass;
  }
  float getRadius() {
    return radius;
  }

  void update(PhysicsBody body) {
  }
}

class PropellantPhysicsBodyComponent extends PhysicsBodyComponent
{
  float mass;
  final float radius;  // regard as a simple sphere
  final float massChangeRate;
  final float thrustMagnitude;  // Thrust |T| = v * (dm/dt) = exaustGasSpeed * massChangeRate

  PropellantPhysicsBodyComponent(float m, float r, float exaustGasSpeed, float massChgRate) {
    super(m, r);
    mass = m;
    radius = r;
    massChangeRate = massChgRate;
    thrustMagnitude = exaustGasSpeed * massChgRate;
  }
  PropellantPhysicsBodyComponent(float m, float r) {
    this(m, r, 1f, 1f);
  }
  
  float getMass() {
    return mass;
  }
  float getRadius() {
    return radius;
  }

  void update(PhysicsBody body) {
    mass -= massChangeRate;

    float xTUnit, yTUnit, zTUnit;
    if(body.xVelocity == 0f && body.xVelocity == 0f) {
      xTUnit = 0f;
      yTUnit = -1f;
    }
    else {
      float bodyAbsV = sqrt(sq(body.xVelocity) + sq(body.yVelocity));
      xTUnit = body.xVelocity / bodyAbsV;
      yTUnit = body.yVelocity / bodyAbsV;
    }
    body.applyForce(thrustMagnitude * xTUnit, thrustMagnitude * yTUnit);
    
    if (mass < 0f) ;  // should be fixed
  }
}



abstract class PhysicsForceField
{
  final ArrayList<PhysicsBody> bodyList;
  
  PhysicsForceField(ArrayList<PhysicsBody> bodies) {
    bodyList = bodies;
  }
  
  abstract void update();
}

final class GravityForceField
  extends PhysicsForceField
{
  final float gravityAcceleration;
  
  GravityForceField(ArrayList<PhysicsBody> bodies, float g) {
    super(bodies);
    gravityAcceleration = g;
  }
  GravityForceField(ArrayList<PhysicsBody> bodies) {
    this(bodies, 9.80665f / sq(IDEAL_FRAME_RATE));
  }
  
  void update() {
    for(PhysicsBody currentBody : bodyList) {
      currentBody.yAcceleration += gravityAcceleration;
    }
  }
}

abstract class DragForceField
  extends PhysicsForceField
{
  final float dencity;
  final float coefficient;
  final float factor;
  
  DragForceField(ArrayList<PhysicsBody> bodies, float d, float c) {
    super(bodies);
    dencity = d;
    coefficient = c;
    
    // drag force = 1/2 * dencity * |relative velocity|^2 * (frontal projected area = r^2 * PI) * (drag coefficient) * (unit vector of relative velocity)
    //            = v^2 * r^2 * factor * (unit vector of relative velocity)
    // relative velocity = velocity of the fluid in the rest frame of the body
    factor = 0.5f * dencity * PI * coefficient;
  }
  DragForceField(ArrayList<PhysicsBody> bodies) {
    this(bodies, 1f, 1f);
  }
  
  abstract void update();
  
  abstract float getXFluidVelocity();
  abstract float getYFluidVelocity();

  float getXRelativeVelocity(PhysicsBody body) {
    return getXFluidVelocity() - body.xVelocity;
  }
  float getYRelativeVelocity(PhysicsBody body) {
    return getYFluidVelocity() - body.yVelocity;
  }

  void applyDragForce(PhysicsBody body) {
    final float xRelVel = getXRelativeVelocity(body);
    final float yRelVel = getYRelativeVelocity(body);
    
    if(xRelVel == 0f && yRelVel == 0f) return;
    
    // v = relative velocity of the fluid
    final float vPow2 = sq(xRelVel) + sq(yRelVel);
    final float vMag = sqrt(vPow2);
    final float rPow2 = sq(body.getRadius());
    final float forceMag = vPow2 * rPow2 * factor;
    final float xVUnit = xRelVel / vMag;
    final float yVUnit = yRelVel / vMag;
    body.applyForce(forceMag * xVUnit, forceMag * yVUnit);
  }
}

final class StableAtmosphereDragForceField
  extends DragForceField
{
  StableAtmosphereDragForceField(ArrayList<PhysicsBody> bodies, float d, float c) {
    super(bodies, d, c);
  }
  StableAtmosphereDragForceField(ArrayList<PhysicsBody> bodies) {
    this(bodies, 1f, 1f);
  }
  
  void update() {
    for(PhysicsBody currentBody : bodyList) {
      applyDragForce(currentBody);
    }
  }
  
  float getXFluidVelocity() {
    return 0f;
  }
  float getYFluidVelocity() {
    return 0f;
  }
}



class PhysicsJoint
{
  final PhysicsBody body1;
  final PhysicsBody body2;
  
  PhysicsJoint(PhysicsBody b1, PhysicsBody b2) {
    body1 = b1;
    body2 = b2;
  }
  
  void update() {
    // Omitted
  }
}



final class PhysicsSystem
{
  final float idealFrameRate;
  final ArrayList<PhysicsBody> bodyList;
  final ArrayList<PhysicsJoint> jointList;
  final ArrayList<PhysicsForceField> forceFieldList;
  
  PhysicsSystem(float fr, int initialCapacity) {
    idealFrameRate = fr;
    bodyList = new ArrayList<PhysicsBody>(initialCapacity);
    jointList = new ArrayList<PhysicsJoint>(initialCapacity);
    forceFieldList = new ArrayList<PhysicsForceField>(initialCapacity);
  }
  PhysicsSystem() {
    this(60f, 1024);
  }
  
  void update() {
    for(PhysicsForceField currentObject : forceFieldList) {
      currentObject.update();
    } 
    for(PhysicsJoint currentObject : jointList) {
      currentObject.update();
    }    
    for(PhysicsBody currentObject : bodyList) {
      currentObject.update();
    }
  }
  
  void addBody(PhysicsBody obj) {
    bodyList.add(obj);
  }
  void removeBody(PhysicsBody obj) {
    bodyList.remove(obj);
  }
  void addJoint(PhysicsJoint obj) {
    jointList.add(obj);
  }
  void removeJoint(PhysicsJoint obj) {
    jointList.remove(obj);
  }
  void addForceField(PhysicsForceField obj) {
    forceFieldList.add(obj);
  }
  void removeForceField(PhysicsForceField obj) {
    forceFieldList.remove(obj);
  }
}
