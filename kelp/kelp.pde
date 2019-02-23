final int nb = 20;
SeaWeed[] weeds;
PVector rootNoise = new PVector(random(123456), random(123456));
int mode = 0;
OPC opc;

void setup()
{
  size(100, 200);
  weeds = new SeaWeed[nb];
  for (int i = 0; i < nb; i++)
  {
    weeds[i] = new SeaWeed(random(0, width), height);
  }
  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledGrid(0, 15, 4, width*0.25, height/2, height/15, width/8, 4.712, true);
  opc.ledGrid(64, 15, 4, width*0.75, height/2, height/15, width/8, 4.712, true);
}

void draw()
{
  background(0);
  for (int i = 0; i < nb; i++)
  {
    weeds[i].update();
  }
  filter(BLUR, 3);
}

//void keyPressed()
//{
//  mode = (mode + 1) % 2;
//}

class SeaWeed
{
  final static float DIST_MAX = 5;//length of each segment
  final static float maxNbSeg = 50;//max number of segments
  final static float minNbSeg = 25;//min number of segments
  final static float maxWidth = 30;//max width of the base line
  final static float minWidth = 8;//min width of the base line
  final static float FLOTATION = 5;//flotation constant
  //float mouseDist;//mouse interaction distance
  int nbSegments = (int)random(minNbSeg, maxNbSeg);//number of segments
  PVector[] pos;//position of each segment
  color[] cols;//colors array, one per segment
  MyColor myCol = new MyColor();
  PVector rootNoise = new PVector(random(123456), random(123456));//noise water effect
  float x;//x origin of the weed
  
  SeaWeed(float p_x, float p_y)
  {
    pos = new PVector[nbSegments];
    cols = new color[nbSegments];
    x = p_x;
    //mouseDist = map(nbSegments, minNbSeg, maxNbSeg, 25, 60);
    for (int i = 0; i < nbSegments; i++)
    {
      pos[i] = new PVector(p_x, p_y - i * DIST_MAX);
      cols[i] = myCol.getColor();
    }
  }

  void update()
  {
    rootNoise.add(new PVector(.02, .02));
    //PVector mouse = new PVector(mouseX, mouseY);

    pos[0] = new PVector(x, height);
    for (int i = 1; i < nbSegments; i++)
    {
      float n = noise(rootNoise.x + .003 * pos[i].x, rootNoise.y + .003 * pos[i].y);
      float noiseForce = (.3 - n) * 4;
      pos[i].x += noiseForce;
      pos[i].y -= FLOTATION;

      //mouse interaction
      //float d = PVector.dist(mouse, pos[i]);
      //if (d < mouseDist)// && pmouseX != mouseX && abs(pmouseX - mouseX) < 12)
      //{
      //  PVector tmpPV = mouse.get();       
      //  tmpPV.sub(pos[i]);
      //  tmpPV.normalize();
      //  tmpPV.mult(mouseDist);
      //  tmpPV = PVector.sub(mouse, tmpPV);
      //  pos[i] = tmpPV.get();
      //}

      PVector tmp = PVector.sub(pos[i-1], pos[i]);
      tmp.normalize();
      tmp.mult(DIST_MAX);
      pos[i] = PVector.sub(pos[i-1], tmp);
    }

    myCol.update();
    cols[0] = myCol.getColor();
    for (int i = 0; i < nbSegments; i++)
    {
      if (i > 0)
      {         
        float t = atan2(pos[i].y - pos[i-1].y, pos[i].x - pos[i-1].x) + PI/2;
        float l = map(i, 0, nbSegments-1, map(nbSegments, minNbSeg, maxNbSeg, minWidth, maxWidth), 1);
        float c = cos(t) * l;
        float s = sin(t) * l;
      }
    }

    if(mode == 1) beginShape(LINES);
    for (int i = 0; i < nbSegments; i++)
    {
      if(mode == 0)
      {
        stroke(0, 100);
        fill(cols[i]);
        float r = (30 * cos(map(i, 0, nbSegments - 1, 0, HALF_PI)));
        ellipse(pos[i].x, pos[i].y + 10, r, r);
      }else
      {
        noFill();
        stroke(cols[i]);
        strokeWeight(nbSegments-i+int(30 * cos(map(i, 0, nbSegments - 1, 0, HALF_PI))));
        curveVertex(pos[i].x, pos[i].y + 10);
      }
    }
    if(mode == 1) endShape();    
  }
}


class MyColor
{
  float R, G, B, Rspeed, Gspeed, Bspeed;
  final static float minSpeed = .2;
  final static float maxSpeed = .8;
  final float minG = 120;
  MyColor()
  {
    init();
  }
  
  public void init()
  {
    R = random(0, minG);
    G = random(minG, 255);
    B = random(0, minG);
    Rspeed = (random(1) > .5 ? 1 : -1) * random(minSpeed, maxSpeed);
    Gspeed = (random(1) > .5 ? 1 : -1) * random(minSpeed, maxSpeed);
    Bspeed = (random(1) > .5 ? 1 : -1) * random(minSpeed, maxSpeed);
  }
  
  public void update()
  {
    Rspeed = ((R += Rspeed) > minG || (R < 0)) ? -Rspeed : Rspeed;
    Gspeed = ((G += Gspeed) > 255 || (G < minG)) ? -Gspeed : Gspeed;
    Bspeed = ((B += Bspeed) > minG || (B < 0)) ? -Bspeed : Bspeed;
  }
  
  public color getColor()
  {
    return color(R, G, B);
  }
}
