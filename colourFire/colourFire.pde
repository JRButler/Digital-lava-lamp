ParticleSystem ps;
OPC opc;
//PImage dot;

void setup() {
  //size(30, 60, P2D);
  size(60, 120);
  //frameRate(30);
  ps = new ParticleSystem(new PVector(1, 120));
  loadPixels();
  colorMode(HSB, 360, 100, 100);

  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledGrid(0, 15, 4, width*0.25, height/2, height/15, width/8, 4.712, true);
  opc.ledGrid(64, 15, 4, width*0.75, height/2, height/15, width/8, 4.712, true);

  //dot = loadImage("purpleDot.png");
  //dot = loadImage("orangeDot.png");
  //dot = loadImage("mintyDot.png");

}

void draw() {
  background(0);
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
  float lifespan;

  Particle(PVector l) {
    acceleration = new PVector(0, -0.05);
    velocity = new PVector(random(-1, 1), random(-2, 0));
    position = l.copy();
    lifespan = 60.0;
  }

  void run() {
    update();
    display();
  }

  // Method to update position
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 1.0;
  }

  // Method to display
  void display() {
    blendMode(ADD);
    //image(dot, position.x, position.y, 60, 70);
    //tint(255, 150);
    //stroke(255, lifespan);
    //fill(255, lifespan);
    fill(position.y+35*5, 70, 100, lifespan);
    ellipse(position.x+30, position.y+30, 40, 40);
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
