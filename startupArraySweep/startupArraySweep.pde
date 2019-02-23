OPC opc;
PImage imRainbow;
PImage imBlank;

void setup()
{
  size(100, 50);

  // Load a sample image
  imRainbow = loadImage("pixelRainbowStartup.jpg");
  imBlank = loadImage("blank.jpg");

  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

  // Map 8 15LED strips to the window
  opc.ledGrid(0, 15, 4, width*0.25, height/2, height/15, width/8, 4.712, true);
  opc.ledGrid(64, 15, 4, width*0.75, height/2, height/15, width/8, 4.712, true);
}

void draw()
{
  background(0);
  // Scale the image so that it matches the width of the window
  //int imWidth = im.height * width / im.width;
  int imWidth = 800;
  int imHeight = 45;

  // Scroll across slowly, and wrap around
  float speed = 0.1;
  float x = (millis() * +speed) % imWidth;
  
  // Use two copies of the image, so it seems to repeat infinitely
  // there's a tiny vertical offset of 3 in place to shift the array downwards into the OPC grid better.
  image(imBlank, x - imWidth*2, 3, imWidth, imHeight);
  image(imRainbow, x - imWidth, 3, imWidth, imHeight);
}
