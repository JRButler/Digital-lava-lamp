ParticleSystem ps;
OPC opc;
PImage bg;

void setup() {
  //size(25, 50);
  size(100, 200);
  // uncomment the below when you get the settling working
  ps = new ParticleSystem(new PVector(30, -75));
  //ps = new ParticleSystem(new PVector(30, 0));
  loadPixels();

  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledGrid(0, 15, 4, width*0.25, height/2, height/15, width/8, 4.712, true);
  opc.ledGrid(64, 15, 4, width*0.75, height/2, height/15, width/8, 4.712, true);

  bg = loadImage("fallBackgroundDim.png");

}

void draw() {
  background(bg);
  //background(0);
  ps.addParticle();
  ps.run();
  filter(BLUR, 2);
}


// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;

  ParticleSystem(PVector position) {
    origin = position.copy();
    particles = new ArrayList<Particle>();
  }

  void addParticle() {
    particles.add(new Particle(origin));
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
        
      }
    }
  }
}


// A simple Particle class - copied from the processing.org tutorials

class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector accelerationSmall;
  float lifespan;

  Particle(PVector l) {
    acceleration = new PVector(0, 0.0035);
    accelerationSmall = new PVector(0, 0.0001);
    velocity = new PVector(random(-0.75, 0.75), random(-0.1, 0.1));
    position = l.copy();
    lifespan = 700.0;
  }

  void run() {
    update();
    display();
  }

  // Method to update position - can this be modded so that if the particle is below a certain Y value it recieves no more acceleration? YES
  void update() {   
   if (position.y > 20){
      velocity.add(accelerationSmall);
      position.add(velocity);
   }
   else {
      velocity.add(acceleration);
      position.add(velocity);
   }
    lifespan -= 1.0;
  }

  // Method to display
  void display() {
    blendMode(ADD); 
    fill(100, (position.y-35)*-1, position.y+35, lifespan*0.22);
    //fill(100, 0, 0, lifespan*0.22);
    //image(dot, position.x, position.y, 50, 50);
    ellipse(position.x+30, position.y+30, 20, 20);
    tint(75, 156);
  }

  // Is the particle still useful?
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
