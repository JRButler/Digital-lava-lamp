int N_THREADS = 50;
OPC opc;

import ddf.minim.*;
Minim minim;
AudioInput in;

void setup() {
  size(200, 60);
  //fullScreen();

  //background(0);
  //noFill();
  //stroke(255);
  frameRate(20);
  colorMode(HSB, 360, 100, 100);

  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, 512);
  
  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledGrid(0, 15, 4, width*0.25, height/2, height/15, width/8, 4.712, true);
  opc.ledGrid(64, 15, 4, width*0.75, height/2, height/15, width/8, 4.712, true);
}

void stop()
{
  // always close Minim audio classes when you finish with them
  in.close();
  // always stop Minim before exiting
  minim.stop();
  super.stop();
}

void draw() {
  background(0);
  //fill(270, 0, 100, 8);
  noStroke();
  //rect(0, 0, width, height);
  //noFill();
  strokeWeight(15);

  for (int i = 0; i < N_THREADS; i++) {
    float hue = map(i, 0, N_THREADS, 0, 240+(30*(in.left.level()*250)));
    stroke(hue, 100, 100, 128);
    
    beginShape();
    for (int x = -10; x < height + 11; x += 10) {
      //tint(50-(in.left.level()*650), 155, 125);

      //float n = noise((x * 0.00065)*(in.left.level()*350), frameCount * 0.0075, i * 0.06);
      float n = noise(x * 0.00035, frameCount * 0.0065, i * 0.06);
      float y = map(n, 0, 1, 1, width);
      curveVertex(y, x);
    }
    endShape();
  }
  filter(BLUR, 7);
}
