int n = 1800;
float mass = 10;
float radius = 3;
float G = 0.08;
float friction = 0.03;

PVector pos[] = new PVector[n];
PVector force[] = new PVector[n];
PVector vel[] = new PVector[n];
float temp[] = new float[n] ;

OPC opc;

void setup() {
  size(120, 120);

  frameRate(40);
  noStroke();
  fill(255, 100, 0, 100) ;
  //noSmooth() ;
  rectMode(CENTER);
  for ( int i = 0; i < n; i++ ) {
    float x = random(radius, width-radius);
    float y = random(radius, height-radius);
    pos[i] = new PVector(x, y);
    vel[i] = new PVector(0, 0);
    force[i] = new PVector(0, 0);
    temp[i] = 1;
  }
  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledGrid(0, 15, 4, width*0.25, height/2, height/15, width/8, 4.712, true);
  opc.ledGrid(64, 15, 4, width*0.75, height/2, height/15, width/8, 4.712, true);
} // setup()

void draw() {
  background(0) ;

  for (int i = 0; i < n-1; i++) {
    for (int j = i+1; j < n; j++) {
      float dist = PVector.dist(pos[i], pos[j]);
      float overlap = constrain(2*radius-dist, 0, 2*radius);
      if ( overlap > 0 ) { 
        force[i].x -= (((pos[j].x -pos[i].x)/dist) *overlap);
        force[i].y -= (((pos[j].y -pos[i].y)/dist) *overlap);
        force[j].x += (((pos[j].x-pos[i].x)/dist) *overlap);
        force[j].y += (((pos[j].y-pos[i].y)/dist) *overlap);
        float TD = (temp[i] -temp[j]) /500;
        temp[i] -= TD;
        temp[j] += TD;
      }
    }
  }
  for (int i = 0; i < n; i++) {
    bounceEdges(i);
    force[i].y += (mass*G) - (temp[i]/100) ;
    if (pos[i].y > height-radius*2) {
      if (pos[i].x > width*0.1 && pos[i].x < width*0.9) temp[i] += 0.5;
    }
    temp[i] *= 0.998;
    vel[i].x += force[i].x /mass;
    vel[i].y += force[i].y /mass;
    vel[i].div(1 +friction);
    force[i].x = 0 ; 
    force[i].y = 0 ;
    pos[i].x = pos[i].x + vel[i].x ; 
    pos[i].y = pos[i].y + vel[i].y ;
    fill(colorTemp(temp[i]));
    //float d = temp[i]/20 +5;
    rect(pos[i].x, pos[i].y, radius, radius);
  }
  filter(BLUR, 2);
} // draw()

void bounceEdges(int i) {
  if ( pos[i].x < radius ) { 
    force[i].x += (radius-pos[i].x);
  }
  if ( pos[i].x > width-radius ) { 
    force[i].x -= (pos[i].x-width+radius);
  }
  if ( pos[i].y < radius ) { 
    force[i].y += (radius-pos[i].y);
  }
  if ( pos[i].y > height-radius ) { 
    force[i].y -= (pos[i].y-height+radius);
  }
}

color colorTemp(float t) {
  float r = constrain(4*t-  0, 5, 255);
  float g = constrain(4*t- 80, 15, 255);
  float b = constrain(4*t-160, 20, 255);
  return color(r, g, b);
}

void mousePressed() {
} // mousePressed()
