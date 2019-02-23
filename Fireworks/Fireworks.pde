// Title: Fireworks
// Author: FAL
// Date: 13. Sep. 2017
// Made with Processing 3.3.6

private static final float IDEAL_FRAME_RATE = 25f;

OPC opc;


ActorSystem currentActorSystem;
PhysicsSystem currentPhysicsSystem;
ObjectPool<Actor> actorPool;

AbstractBackground gradationBackground;
// AbstractBackground fogBackground;    // does not work in processing.js

ActorBuilder fireworksBallBuilder;

void setup() {
  size(150, 200);
  frameRate(IDEAL_FRAME_RATE);
  background(0f);
  
  initialize();          // Should be called BEFORE defineActorTypes()
  defineActorTypes();    // Should be called BEFORE colorMode()
  
  colorMode(HSB, 360f, 100f, 100f, 100f);
  gradationBackground = new GradationBackground(width, height, color(240f, 100f, 10f, 30f), color(240f, 100f, 40f, 30f), 2f);
//  fogBackground = new AlphaFogBackground(width, height, color(0f, 0f, 100f), 0f, 30f, 0.005f);

  noStroke();

  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledGrid(0, 15, 4, width*0.25, height/2, height/15, width/8, 4.712, true);
  opc.ledGrid(64, 15, 4, width*0.75, height/2, height/15, width/8, 4.712, true);


}

void draw() {
  imageMode(CORNER);
  gradationBackground.display();
//  fogBackground.display();
  
  imageMode(CENTER);
  translate(width * 0.5f, 0f);
  currentPhysicsSystem.update();
  currentActorSystem.run();

  actorPool.update();

  // after 60 frames, get going?
  if (frameCount % 240 == 30) launchFireworks();

  //if (mousePressed) drawDebugInfo(); 
  filter(BLUR, 1);

}


void initialize() {
  initializeObjectPool();

  currentActorSystem = new ActorSystem();
  currentPhysicsSystem = new PhysicsSystem();
  
  // Define environment
  currentPhysicsSystem.addForceField(new GravityForceField(currentPhysicsSystem.bodyList));
  currentPhysicsSystem.addForceField(new StableAtmosphereDragForceField(currentPhysicsSystem.bodyList));
}

void initializeObjectPool() {
  actorPool = new ObjectPool<Actor>(4096);
  for (int i = 0; i < actorPool.poolSize; i++) {
    Actor newObject = new Actor();
    newObject.belongingPool = actorPool;
    actorPool.add(newObject);
  }
}

void launchFireworks() {
  // NOTE - change the - 65f / IDEAL_FRAME_RATE to control launch height
  Actor ball = fireworksBallBuilder.build(random(-40f, 40f), height, 0f, - 65f / IDEAL_FRAME_RATE);
  // NOTE - change int((4f  <-- to control launch height too
  ball.lifetimeFrameCount = int((4f + random(-0.5f, 0.5f)) * IDEAL_FRAME_RATE);
  currentActorSystem.registerNewActor(ball);
}

//void drawDebugInfo() {
//  fill(0f, 0f, 100f);
//  text(round(frameRate) + " FPS", 10f, 20f);
//  text(actorPool.index + " particles", 10f, 40f);
//}



void defineActorTypes() {
  // Defining actor type: "BurningGunpowder"
  ActorBuilder burningGunpowderBuilder = new ActorBuilder();
  burningGunpowderBuilder.pool = actorPool;
  burningGunpowderBuilder.displayer = new ShrinkActorDisplayer(createLightImage(1f, 1f, 0.9f, 1f, 1f, 10));
  burningGunpowderBuilder.component = new ImmutablePhysicsBodyComponent(0.005f, 0.02f);
  burningGunpowderBuilder.lifetimeFrameCount = int(IDEAL_FRAME_RATE * 0.5f);

  // Defining actor type: "FlashingGunpowder"
  ActorBuilder flashingGunpowderBuilder = new ActorBuilder();
  flashingGunpowderBuilder.pool = actorPool;
  flashingGunpowderBuilder.component = new ImmutablePhysicsBodyComponent(0.005f, 0.02f);
  flashingGunpowderBuilder.lifetimeFrameCount = int(IDEAL_FRAME_RATE * 2.5f);
  
  // Defining actor type: "GunpowderBall"
  ActorBuilder gunpowderBallBuilder = new ActorBuilder();
  gunpowderBallBuilder.pool = actorPool;
  // the numbers in the next argument represent the mass and the radius, lower the radius with a higher number strangely
  gunpowderBallBuilder.component = new ImmutablePhysicsBodyComponent(0.2f, 0.065f);
  // this one adjusts how long they hang in the air burning
  gunpowderBallBuilder.lifetimeFrameCount = int(IDEAL_FRAME_RATE * 3.5f);  
  gunpowderBallBuilder.actionList.add(new LeaveGunpowderFireAction(flashingGunpowderBuilder));
  
  ArrayList<ActorDisplayer> displayerCandidateList = new ArrayList<ActorDisplayer>();
  displayerCandidateList.add(new FlashActorDisplayer(createLightImage(1f, 1f, 1f, 1f, 1f, 20)));  // White
  displayerCandidateList.add(new FlashActorDisplayer(createLightImage(1f, 0.5f, 0.5f, 1f, 1f, 20)));  // Red
  displayerCandidateList.add(new FlashActorDisplayer(createLightImage(1f, 0.75f, 0.5f, 1f, 1f, 20)));  // Orange
  displayerCandidateList.add(new FlashActorDisplayer(createLightImage(1f, 1f, 0.5f, 1f, 1f, 20)));  // Yellow
  displayerCandidateList.add(new FlashActorDisplayer(createLightImage(0.75f, 1f, 0.5f, 1f, 1f, 20)));  // Yellowgreen
//  displayerCandidateList.add(new FlashActorDisplayer(createLightImage(0.5f, 1f, 0.5f, 1f, 1f, 20)));  // Green
  displayerCandidateList.add(new FlashActorDisplayer(createLightImage(0.5f, 1f, 0.75f, 1f, 1f, 20)));  // Cyan Green
  displayerCandidateList.add(new FlashActorDisplayer(createLightImage(0.5f, 1f, 1f, 1f, 1f, 20)));  // Cyan blue
  displayerCandidateList.add(new FlashActorDisplayer(createLightImage(0.5f, 0.75f, 1f, 1f, 1f, 20)));  // Sky blue
//  displayerCandidateList.add(new FlashActorDisplayer(createLightImage(0.5f, 0.5f, 1f, 1f, 1f, 20)));  // Blue
  displayerCandidateList.add(new FlashActorDisplayer(createLightImage(0.75f, 0.5f, 1f, 1f, 1f, 20)));  // Blue purple
  displayerCandidateList.add(new FlashActorDisplayer(createLightImage(1f, 0.5f, 1f, 1f, 1f, 20)));  // Purple
  displayerCandidateList.add(new FlashActorDisplayer(createLightImage(1f, 0.5f, 6f, 1f, 1f, 20)));  // Magenta
  
  
  // Define actor type: "FireworksBall" (global builder)
  fireworksBallBuilder = new ActorBuilder();
  fireworksBallBuilder.pool = actorPool;
  fireworksBallBuilder.displayer = new ShrinkActorDisplayer(createLightImage(1f, 1f, 0.9f, 1f, 4f, 20));
  fireworksBallBuilder.component = new ImmutablePhysicsBodyComponent(70f, 0.03f);
  ExplodeFireAction explode = new ExplodeFireAction(gunpowderBallBuilder);
  for(ActorDisplayer currentObject : displayerCandidateList) {
    explode.displayerCandidateList.add(currentObject);
  }
  fireworksBallBuilder.actionList.add(explode);
  fireworksBallBuilder.actionList.add(new BurnFireAction(burningGunpowderBuilder));
}



final PImage createLightImage(float redFactor, float greenFactor, float blueFactor, float alphaFactor, float lightRadius, int graphicsSize) {
  // Required: default colorMode(RGB, 255, 255, 255, 255);
  
  float halfSideLength = graphicsSize / 2f;
  PImage newImage = createImage(graphicsSize, graphicsSize, ARGB);
  
  for (int pixelYPosition = 0; pixelYPosition < graphicsSize; pixelYPosition++) {
    for (int pixelXPosition = 0; pixelXPosition < graphicsSize; pixelXPosition++) {
      // alphaRatio will be calculated from:
      float distanceFromCenter = max(sqrt(sq(halfSideLength - pixelXPosition) + sq(halfSideLength - pixelYPosition)), 1f);  // should be 1 or more
      // Required conditions are:
      // (1) alphaRatio = factor / (distanceFromCenter ^ exponent)
      // (2) alphaRatio = 1 where distance = lightRadius
      // (3) alphaRatio = 1/255 where distance = halfSideLength (= border of this graphics screen)
      // Therefore,
      float exponent = ((log(255)) / log(halfSideLength)) / (1f - log(lightRadius) / log(halfSideLength));
      // and factor = (lightRadius ^ exponent)
      // Therefore alphaRatio = (lightRadius / distanceFromCenter) ^ exponent

      float alphaRatio = pow(lightRadius / distanceFromCenter, exponent);
      newImage.pixels[pixelXPosition + pixelYPosition * graphicsSize] = color(255f * redFactor, 255f * greenFactor, 255f * blueFactor, 255f * alphaFactor * alphaRatio);
    }
  }
  return newImage;
}
