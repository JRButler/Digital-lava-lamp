// This tab is independent.
// Required: colorMode(HSB, 360f, 100f, 100f, 100f);

abstract class AbstractBackground {
  final float xSize, ySize;

  AbstractBackground(int x, int y) {
    xSize = x;
    ySize = y;
  }
  AbstractBackground() {
    this(width, height);
  }

  abstract void display();
}

class SolidBackground extends AbstractBackground {
  final color backgroundColor;

  SolidBackground(int x, int y, color c) {
    backgroundColor = c;
  }
  SolidBackground(int x, int y) {
    this(x, y, color(0f, 0f, 100f));
  }
  SolidBackground() {
    this(width, height);
  }

  void display() {
    pushStyle();
    fill(backgroundColor);
    noStroke();
    rect(0f, 0f, xSize, ySize);
    popStyle();
  }
}

abstract class PreRenderedBackground extends AbstractBackground {
  final PImage graphics;

  PreRenderedBackground(int x, int y) {
    graphics = createImage(x, y, ARGB);
  }
  PreRenderedBackground() {
    this(width, height);
  }

  void display() {
    image(graphics, 0f, 0f);
  }
}

abstract class FogBackground extends PreRenderedBackground {
  FogBackground(int x, int y, color baseColor, float baseBrightness, float noiseBrightness, float noiseIncrement) {
    super(x, y);
    createFog(x, y, baseColor, baseBrightness, noiseBrightness, noiseIncrement);
  }
  FogBackground(int x, int y) {
    this(x, y, color(0f, 0f, 0f), 70f, 30f, 0.01f);
  }
  FogBackground() {
    this(width, height);
  }

  void createFog(int x, int y, color baseColor, float baseBrightness, float noiseBrightness, float noiseIncrement) {
    graphics.loadPixels();
    float xoff = 0.0;
    for (int xp = 0; xp < x; xp++) {
      xoff += noiseIncrement;
      float yoff = 0.0;
      for (int yp = 0; yp < y; yp++) {
        yoff += noiseIncrement;
        float bright = constrain(baseBrightness + noise(xoff, yoff) * noiseBrightness, 0f, 100f);
        graphics.pixels[xp + yp * x] = getPixelColor(baseColor, bright);
      }
    }
    graphics.updatePixels();
  }

  abstract color getPixelColor(color baseColor, float bright);
}

class OpaqueFogBackground extends FogBackground {
  OpaqueFogBackground(int x, int y, color baseColor, float baseBrightness, float noiseBrightness, float noiseIncrement) {
    super(x, y, baseColor, baseBrightness, noiseBrightness, noiseIncrement);
  }
  OpaqueFogBackground(int x, int y) {
    this(x, y, color(0f, 0f, 0f), 70f, 30f, 0.01f);
  }
  OpaqueFogBackground() {
    this(width, height);
  }

  color getPixelColor(color baseColor, float bright) {
    return color(hue(baseColor), saturation(baseColor), bright);
  }
}

class AlphaFogBackground extends FogBackground {
  AlphaFogBackground(int x, int y, color baseColor, float baseBrightness, float noiseBrightness, float noiseIncrement) {
    super(x, y, baseColor, baseBrightness, noiseBrightness, noiseIncrement);
  }
  AlphaFogBackground(int x, int y) {
    this(x, y, color(0f, 0f, 100f), 70f, 30f, 0.01f);
  }
  AlphaFogBackground() {
    this(width, height);
  }

  color getPixelColor(color baseColor, float bright) {
    return color(baseColor, bright);
  }
}

class GradationBackground extends PreRenderedBackground {
  GradationBackground(int x, int y, color aboveColor, color belowColor, float gradient) {
    super(x, y);
    graphics.loadPixels();
    for (int xp = 0; xp < x; xp++) {
      for (int yp = 0; yp < y; yp++) {
        graphics.pixels[xp + yp * x] = lerpColor(aboveColor, belowColor, pow(float(yp) / y, gradient));
      }
    }
    graphics.updatePixels();
  }
  GradationBackground(int x, int y) {
    this(x, y, color(0f, 0f, 100f), color(240f, 20f, 100f), 1f);
  }
  GradationBackground() {
    this(width, height);
  }
}
