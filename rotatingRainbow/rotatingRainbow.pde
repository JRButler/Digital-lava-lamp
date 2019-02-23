OPC opc;
PImage im;

void setup()
{
  size(400, 100);

  // Load a sample image
  im = loadImage("rainbow.jpg");

  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

  // Map 8 15LED strips to the window
  opc.ledGrid(0, 15, 4, width*0.25, height/2, height/15, width/8, 4.712, true);
  opc.ledGrid(64, 15, 4, width*0.75, height/2, height/15, width/8, 4.712, true);
}

void draw()
{
  // Scale the image so that it matches the width of the window
  int imWidth = im.height * width / im.width;

  // Scroll across slowly, and wrap around
  float speed = 0.03;
  float x = (millis() * -speed) % imWidth;
  
  // Use two copies of the image, so it seems to repeat infinitely  
  image(im, x, 0, imWidth, height);
  image(im, x + imWidth, 0, imWidth, height);
}
