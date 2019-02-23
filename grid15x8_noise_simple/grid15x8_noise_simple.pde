// A simple example of using Processing's noise() function to draw LED clouds

OPC opc;

PImage clouds;

void setup()
{
  size(120 , 120);
  colorMode(HSB, 100);
  noiseDetail(5, 0.4);
  loadPixels();

  // Render the noise to a smaller image, it's faster than updating the entire window.
  clouds = createImage(128, 128, RGB);

  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledGrid(0, 15, 4, width*0.25, height/2, height/15, width/8, 4.712, true);
  opc.ledGrid(64, 15, 4, width*0.75, height/2, height/15, width/8, 4.712, true);
}

void draw()
{
  float hue = (noise(millis() * 0.0001) * 200) % 100;
  float z = millis() * 0.0001;
  float dx = millis() * 0.0001;

  for (int x=0; x < clouds.width; x++) {
    for (int y=0; y < clouds.height; y++) {
      float n = 500 * (noise(dx + x * 0.01, y * 0.01, z) - 0.4);
      color c = color(hue, 80 - n, n);
      clouds.pixels[x + clouds.width*y] = c;
    }
  }
  clouds.updatePixels();

  image(clouds, 0, 0, width, height);
}
