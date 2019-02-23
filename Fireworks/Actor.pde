// This tab is dependent on Physics3D.pde and ObjectPool.pde

final class ActorSystem
{
  final ArrayList<Actor> liveActorList;
  final ArrayList<Actor> newActorList;
  final ArrayList<Actor> deadActorList;

  ActorSystem(int initialCapacity) {
    liveActorList = new ArrayList<Actor>(initialCapacity);
    newActorList = new ArrayList<Actor>(initialCapacity);
    deadActorList = new ArrayList<Actor>(initialCapacity);
  }
  ActorSystem() {
    this(16);
  }

  void registerNewActor(Actor obj) {
    newActorList.add(obj);
    obj.belongingActorSystem = this;
  }
  void registerDeadActor(Actor obj) {
    deadActorList.add(obj);
  }

  void run() {
    updateActorList();
    display();
  }

  void display() {
    for (Actor currentObject : liveActorList) {
      currentObject.act();
    }
  }

  void updateActorList() {
    for (Actor currentObject : deadActorList) {
      liveActorList.remove(currentObject);
      currentPhysicsSystem.removeBody(currentObject);
      currentObject.belongingPool.deallocate(currentObject);
    }
    deadActorList.clear();
    for (Actor currentObject : newActorList) {
      liveActorList.add(currentObject);
      currentPhysicsSystem.addBody(currentObject);
    }
    newActorList.clear();
  }
}



class Actor
  extends PhysicsBody
{
  ActorDisplayer displayer;
  ArrayList<Action> actionList = new ArrayList<Action>();
  int lifetimeFrameCount;
  int properFrameCount;
  ActorSystem belongingActorSystem;
  float scaleFactor = 1f;

  Actor(float x, float y) {
    super(x, y);
  }
  Actor() {
    this(0f, 0f);
  }

  void initialize() {
    super.initialize();
    displayer = null;
    actionList.clear();
    lifetimeFrameCount = 0;
    properFrameCount = 0;
    belongingActorSystem = null;
    scaleFactor = 1f;
  }

  void act() {
    displayer.display(this);
    for (Action currentObject : actionList) {
      currentObject.execute(this);
    }
    properFrameCount++;
    if (properFrameCount > lifetimeFrameCount) belongingActorSystem.registerDeadActor(this);
  }

  float getProgressRatio() {
    if (lifetimeFrameCount < 1f) return 0f;
    return min(properFrameCount / float(lifetimeFrameCount), 1f);
  }
  float getFadeRatio() {
    return 1f - getProgressRatio();
  }
}


class ActorDisplayer {
  final PImage actorImage;
  

  ActorDisplayer(PImage img) {
    actorImage = img;
  }

  void display(Actor parentActor) {
    image(actorImage, parentActor.xPosition, parentActor.yPosition);
  }
}


abstract class Action {
  Action() {
  }

  abstract void execute(Actor parentActor);
}

// Generates new actor(s);
abstract class FireAction extends Action {
  final ActorBuilder builder;

  FireAction(ActorBuilder b) {
    builder = b;
  }
}



final class ActorBuilder {
  ActorDisplayer displayer = null;
  final ArrayList<Action> actionList = new ArrayList<Action>();
  PhysicsBodyComponent component;
  int lifetimeFrameCount;

  float xPosition, yPosition;
  float xVelocity, yVelocity;

  ObjectPool pool;

  ActorBuilder() {
  }
  
  ActorBuilder clone() {
    ActorBuilder clonedBuilder = new ActorBuilder();
    clonedBuilder.displayer = this.displayer;
    for (Action currentObject : this.actionList) {
      clonedBuilder.actionList.add(currentObject);
    }
    clonedBuilder.component = this.component;
    clonedBuilder.lifetimeFrameCount = this.lifetimeFrameCount;

    clonedBuilder.xPosition = this.xPosition;
    clonedBuilder.yPosition = this.yPosition;
    clonedBuilder.xVelocity = this.xVelocity;
    clonedBuilder.yVelocity = this.yVelocity;

    clonedBuilder.pool = this.pool;
    
    return clonedBuilder;
  }

  Actor build() {
    return build(this.xPosition, this.yPosition, this.xVelocity, this.yVelocity);
  }  
  Actor build(float x, float y, float vx, float vy) {
    Actor newActor = (Actor)pool.allocate();
    newActor.displayer = this.displayer;
    for (Action currentObject : this.actionList) {
      newActor.actionList.add(currentObject);
    }
    newActor.component = this.component;
    newActor.lifetimeFrameCount = this.lifetimeFrameCount;

    newActor.xPosition = x;
    newActor.yPosition = y;
    newActor.xVelocity = vx;
    newActor.yVelocity = vy;
    return newActor;
  }
}
