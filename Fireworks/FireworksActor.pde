// User defined actions

final class BurnFireAction extends FireAction {
  final float burningTimeRatio = 0.6f;

  BurnFireAction(ActorBuilder b) {
    super(b);
  }
  
  void execute(Actor parentActor) {
    if (parentActor.getProgressRatio() > burningTimeRatio) return;
    final float burnRatio = (burningTimeRatio - parentActor.getProgressRatio()) / burningTimeRatio;
    
    final float xOff = 3f * sin(3f * frameCount * TWO_PI / IDEAL_FRAME_RATE) * burnRatio;
    final Actor newActor = builder.build(parentActor.xPosition + xOff, parentActor.yPosition, parentActor.xVelocity - xOff, parentActor.yVelocity);
    newActor.scaleFactor = burnRatio;
    parentActor.belongingActorSystem.registerNewActor(newActor);
  }
}

final class ExplodeFireAction extends FireAction {
  final ArrayList<ActorDisplayer> displayerCandidateList = new ArrayList<ActorDisplayer>();
  
  ExplodeFireAction(ActorBuilder b) {
    super(b);
  }
  
  void execute(Actor parentActor) {
    if(parentActor.properFrameCount == int(parentActor.lifetimeFrameCount * 0.99f)) {
      explode(parentActor, 400f / IDEAL_FRAME_RATE);
    }
    if(parentActor.properFrameCount == parentActor.lifetimeFrameCount) {
      explode(parentActor, 150f / IDEAL_FRAME_RATE);
    }
  }
  
  void explode(Actor parentActor, float initialSpeed) {
    // Set the displayer of the child (GunpowderBall) randomly for the purpose of color variation
    final ActorDisplayer gunpowderBallDisplayer = displayerCandidateList.get(int(random(displayerCandidateList.size())));

    final int anglePartitionCount = 15;
    final float unitAngle = TWO_PI / anglePartitionCount;
    for (int i = 0; i < anglePartitionCount; i++) {
      for (int k = 0; k < anglePartitionCount; k++) {
        final Actor newActor = builder.build();
        newActor.displayer = gunpowderBallDisplayer;
        newActor.xPosition = parentActor.xPosition;
        newActor.yPosition = parentActor.yPosition;
    
        final float theta = (i + random(0.5f)) * unitAngle;
        final float phi = (k + random(0.5f)) * unitAngle;
        newActor.xVelocity = initialSpeed * cos(theta) * cos(phi);
        newActor.yVelocity = initialSpeed * cos(theta) * sin(phi);

        parentActor.belongingActorSystem.registerNewActor(newActor);
      }
    }
  }
}

final class LeaveGunpowderFireAction
  extends FireAction
{
  LeaveGunpowderFireAction(ActorBuilder b) {
    super(b);
  }
  
  void execute(Actor parentActor) {
    if (random(1f) < calculateFireProbability(parentActor)) {
      final Actor newActor = builder.build(parentActor.xPosition, parentActor.yPosition, parentActor.xVelocity, parentActor.yVelocity);
      newActor.displayer = parentActor.displayer;
      parentActor.belongingActorSystem.registerNewActor(newActor);
    }
  }
  
  float calculateFireProbability(Actor parentActor) {
    if (parentActor.getProgressRatio() < 0.2f) return 0.1f * parentActor.getProgressRatio() * 5f;
    return 0.1f * parentActor.getFadeRatio();
  }
}



// User defined displayers

final class FlashActorDisplayer extends ActorDisplayer {
  FlashActorDisplayer(PImage img) {
    super(img);
  }
  
  void display(Actor parentActor) {
    if(random(1f) < calculateDisplayProbability(parentActor)) {
      image(actorImage, parentActor.xPosition, parentActor.yPosition);
    }
  }
  
  float calculateDisplayProbability(Actor parentActor) {
    final float fadeRatio = parentActor.getFadeRatio();
    if (fadeRatio > 0.5f) return 0.9f;
    return fadeRatio * 2f * 0.9f;
  }
}

final class ShrinkActorDisplayer extends ActorDisplayer {
  float displayTimeRatio = 0.8f;
  
  ShrinkActorDisplayer(PImage img) {
    super(img);
  }
  
  void display(Actor parentActor) {
    if(parentActor.getProgressRatio() > displayTimeRatio) return;
    final float shrinkRatio = (displayTimeRatio - parentActor.getProgressRatio()) / displayTimeRatio;
    
    pushMatrix();
    translate(parentActor.xPosition, parentActor.yPosition);
    scale(parentActor.scaleFactor * pow(shrinkRatio, 0.5f));
    image(actorImage, 0f, 0f);
    popMatrix();
  }
}

final class FadeActorDisplayer extends ActorDisplayer {
  FadeActorDisplayer(PImage img) {
    super(img);
  }
  
  void display(Actor parentActor) {
    tint(color(0f, 0f, 100f, 100f * pow(parentActor.getFadeRatio(), 0.5f)));
    image(actorImage, parentActor.xPosition, parentActor.yPosition);
    noTint();
  }
}
