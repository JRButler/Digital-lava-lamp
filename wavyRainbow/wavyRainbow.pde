int N_THREADS = 50;
OPC opc;

void setup() {
  size(60, 120);
  //fullScreen();

  //background(0);
  //noFill();
  //5stroke(255);
  colorMode(HSB, 360, 100, 100);
  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledGrid(0, 15, 4, width*0.25, height/2, height/15, width/8, 4.712, true);
  opc.ledGrid(64, 15, 4, width*0.75, height/2, height/15, width/8, 4.712, true);

}

void draw() {
  background(0);
  //fill(270, 0, 100, 8);
  noStroke();
  rect(0, 0, width, height);
  noFill();
  strokeWeight(5);

  for (int i = 0; i < N_THREADS; i++) {
    float hue = map(i, 0, N_THREADS, 0, 360);
    stroke(hue, 100, 100, 128);
    
    beginShape();
    for (int x = -10; x < width + 11; x += 10) {
      float n = noise(x * 0.0001, frameCount * 0.01, i * 0.02);
      float y = map(n, 0, 1, 0, height*1.05);
      curveVertex(x, y);
    }
    endShape();
  }
  filter(BLUR, 3);
}
