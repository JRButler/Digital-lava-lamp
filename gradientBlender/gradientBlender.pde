OPC opc;


color i1, i2, f1, f2, c1, c2;

int i =0;
int R = 255;
int v = 150;

void setup() {
  //size(100, 200, P2D);
  size(50, 100);

  // Define colors
 
  i1 = color(random(R), random(R), random(R));
  i2 = color(random(R), random(R), random(R));
  c1 = i1;
  c2 = f2;
  f1 = i1;
  f2 = i2;
  // noLoop();
  
  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledGrid(0, 15, 4, width*0.25, height/2, height/15, width/8, 4.712, true);
  opc.ledGrid(64, 15, 4, width*0.75, height/2, height/15, width/8, 4.712, true);

  
  
}

void draw() {
  //background(0);
  if ( red(c1) == red(f1) && green(c1) == green(f1) && blue(c1) == blue(f1) ) {
   pickNewColor();
 }
  
  i++;
  
  // make gradient
  float inter = map(i, 0, v, 0,1); 
  c1 = lerpColor(i1, f1, inter);
  c2 = lerpColor(i2, f2, inter);
  setGradient(0, 0, width, height, c1, c2);

}

void keyPressed(){
  
 if (key == 'a') R= R+30;
 if (key == 'z') R= R-30;
 
 if (key == 'l') v= v+50;
 if (key == ',') v= v-50;
 
 println("light = " + R + ", slow = " + v );
}
void pickNewColor(){
    
    i1 = f1;
    i2 = f2;
    
    f1 = color(random(R), random(R), random(R));
    f2 = lerpColor(i1, i2, 0.5);  
    
    i =0;
}

void setGradient(int x, int y, float w, float h, color c1, color c2 ) {
 
 for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
 }
 
}
