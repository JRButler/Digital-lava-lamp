/*----------------------------------
       
 Copyright by Diana Lange 2014
 Don't use without any permission. Creative Commons: Attribution Non-Commercial.
       
 mail: kontakt@diana-lange.de
 web: diana-lange.de
 facebook: https://www.facebook.com/DianaLangeDesign
 flickr: http://www.flickr.com/photos/dianalange/collections/
 tumblr: http://dianalange.tumblr.com/
 twitter: http://twitter.com/DianaOnTheRoad
 vimeo: https://vimeo.com/dianalange/videos
      
 -----------------------------------*/
OPC opc;

ArrayList <Mover> bouncers;

Mover predator;
Mover leader;
int predatorvictim = 0;

boolean followLeader = true;
boolean hidefromPredator = true;

int bewegungsModus = 5;
// 0 = BOUNCE
// 1 = NOISE
// 2 = STEER
// 3 = SEEK
// 4 = RADIAL
// 5 = FLOCK

void setup ()
{
  size (100, 200);

  bouncers = new ArrayList ();
  predator = new Mover ();
  predator.setColor (#52A59D, #ffffff);
  predator.setFishSize (10);
  predator.speed = 2;
  predator.SPEED = 2;

  leader = new Mover();
  leader.setColor (#ffffff, #666666);
  leader.setFishSize (10);
  leader.speed = 6;
  leader.SPEED = 6;

  for (int i = 0; i < 50; i++)
  {
    Mover newMover = new Mover();
    bouncers.add (newMover);
  }

  frameRate (20);
  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledGrid(0, 15, 4, width*0.25, height/2, height/15, width/8, 4.712, true);
  opc.ledGrid(64, 15, 4, width*0.75, height/2, height/15, width/8, 4.712, true);
}

void draw ()
{
  background(0);

  // SCHWARM -----------

  for (int i = 0; i < bouncers.size (); i++)
  {
    Mover m = bouncers.get (i);

    if (bewegungsModus != 5) m.update (bewegungsModus);
    else
    {
      m.flock (bouncers);
      m.move();
      m.checkEdges();
      m.display();

      // SWARM PREDATOR REACTION -----------------------

      if (hidefromPredator)
      {
        float distance = dist (predator.getLocation().x, predator.getLocation().y, m.getLocation().x, m.getLocation().y);

        if (distance < predator.getSize() * 3)
        {
          float angle = atan2 (m.getLocation().y-predator.getLocation().y, m.getLocation().x-predator.getLocation().x);

          m.seperation (new PVector (cos (angle), sin (angle)), 5);
        }
      }

      // SWARM LEADER REACTION ---------------------------

      if (followLeader)
      {
        float distance = dist (leader.getLocation().x, leader.getLocation().y, m.getLocation().x, m.getLocation().y);

        if (distance <  70)
        {
          m.steer (leader.getLocation().x, leader.getLocation().y, 1);
        }
      }
    }
  }

  // PREDATOR MOVEMENT ---------------------

  if (hidefromPredator)
  {
    predator.move ();
    PVector target = bouncers.get(predatorvictim).getLocation();
    predator.steer (target.x, target.y);
    predator.checkEdges ();
    predator.display();

    if (PVector.dist (bouncers.get(predatorvictim).getLocation(), predator.getLocation()) < predator.getSize() * 5)
    {
      predatorvictim = (int) random (bouncers.size());
    }
  }

  // LEADER  MOVEMENT ---------------------
  if (followLeader)
  {
    leader.move ();
    leader.flock (bouncers);
    leader.checkEdges();
    leader.display();
  }
  filter(BLUR, 4);
}

class Fish
{
  PVector [] location;
  float ellipseSize; 

  color c1;
  color c2;

  Fish (float x, float y)
  {
    setRandomColor ();

    location = new PVector [round (random (8, 15))];
    location[0] = new PVector (x, y);

    for (int i = 1; i < location.length; i++)
    {
      location[i] = location[0].get ();
    }
    ellipseSize = random (16, 40);
  }

  // GET ------------------------------

  float getSize () 
  {
    return ellipseSize;
  }

  PVector getHead ()
  {
    return location [location.length-1].get();
  }

  PVector getTail ()
  {
    return location [0].get();
  }

  // SET ---------------------

  void setColor (color c)
  {
    c1 = c2 = c;
  }

  void setColor (color C1, color C2)
  {
    c1 = C1;
    c2 = C2;
  }

  void setRandomColor ()
  {
    int colorDice = (int) random (4);

    if (colorDice == 0) c1 = #ffedbc;
    else if (colorDice == 1) c1 = #A75265;
    else if (colorDice == 2) c1 = #ec7263;
    else c1 = #febe7e;

    float dice = random (100);
    if (dice < 25)
    {
      colorDice = (int) random (4);

      if (colorDice == 0) c2 = #ffedbc;
      else if (colorDice == 1) c2 = #A75265;
      else if (colorDice == 2) c2 = #ec7263;
      else c2 = #febe7e;
    }
    else c2 = c1;
  }

  void setHead (PVector pos)
  {
    location [location.length-1]= pos.get();

    updateBody ();
  }

  // HELPERS ---------------

  void updateBody ()
  {
    for (int i = 0; i < location.length-1; i++)
    {
      location [i] = location [i+1];
    }
  }

  void resetBody ()
  {
    for (int i = 0; i < location.length-1; i++)
    {
      location [i] = location [location.length-1].get();
    }
  }

  // DISPLAY --------------------

  void display ()
  {
    noStroke();
    for (int i = 0; i < location.length; i++)
    {
      color c = lerpColor (c1, c2, map (i, 0, location.length, 1, 0 ) );
      float s = map (i, 0, location.length, 1, ellipseSize  );

      fill (c);
      ellipse (location[i].x, location [i].y, s, s);
    }
  }
}

class Mover
{
  PVector direction;

  float speed;
  float SPEED;

  float noiseScale;
  float noiseStrength;
  float forceStrength;

  Fish f;

  Mover () // Konstruktor = setup der Mover Klasse
  {
    setRandomValues();
  }

  Mover (float x, float y) // Konstruktor = setup der Mover Klasse
  {
    setRandomValues ();
    f.setHead (new PVector (x, y));
    f.resetBody();
  }

  // SET ---------------------------

  void setRandomValues ()
  {
    f = new Fish (random (width), random (height));
    f.ellipseSize = random (4, 15);

    float angle = random (TWO_PI);
    direction = new PVector (cos (angle), sin (angle));

    speed = random (1, 4);
    SPEED = speed;
    noiseScale = 80;
    noiseStrength = 1;
    forceStrength = random (0.1, 0.2);
  }

  void setColor (color c)
  {
    f.setColor (c);
  }

  void setColor (color c1, color c2)
  {
    f.setColor (c1, c2);
  }

  void setFishSize (float s)
  {
    f.ellipseSize = s;
  }

  // GET --------------------------------

  float getSize ()
  {
    return f.getSize();
  }

  PVector getLocation ()
  {
    return f.getHead();
  }

  // GENEREL ------------------------------

  void update ()
  {
    update (0);
  }

  void update (int mode)
  {
    if (mode == 0) // bouncing ball
    {
      speed = SPEED * 0.7;
      move();
      checkEdgesAndBounce();
    } 
    else if (mode == 1) // noise
    {
      speed = SPEED * 0.7;
      addNoise ();
      move();
      checkEdgesAndRelocate ();
    }
    else if (mode == 2) // steer
    {
      steer (mouseX, mouseY);
      move();
    }
    else if (mode == 3) // seek
    {
      speed = SPEED * 0.7;
      seek (mouseX, mouseY);
      move();
    }
    else // radial
    {
      speed = SPEED * 0.7;
      addRadial ();
      move();
      checkEdges();
    }

    display();
  }

  // FLOCK ------------------------------

  void flock (ArrayList <Mover> boids)
  {
    PVector location = f.getHead();

    PVector other;
    float otherSize ;

    PVector cohesionSum = new PVector (0, 0);
    float cohesionCount = 0;

    PVector seperationSum = new PVector (0, 0);
    float seperationCount = 0;

    PVector alignSum = new PVector (0, 0);
    float speedSum = 0;
    float alignCount = 0;

    for (int i = 0; i < boids.size(); i++)
    {
      other = boids.get(i).f.getHead();
      otherSize = boids.get(i).f.getSize();

      float distance = PVector.dist (other, location);
 

      if (distance > 0 && distance <70) //align + cohesion
      {
        cohesionSum.add (other);
        cohesionCount++;

        alignSum.add (boids.get(i).direction);
        speedSum += boids.get(i).speed;
        alignCount++;
      }

     if (distance > 0 && distance < (f.getSize()+otherSize)*1.2) // seperate bei collision
      {
        float angle = atan2 (location.y-other.y, location.x-other.x);

        seperationSum.add (cos (angle), sin (angle), 0);
        seperationCount++;
      }

      if (alignCount > 10 || seperationCount > 10) break;
    }

    // cohesion: bewege dich in die Mitte deiner Nachbarn
    // seperation: renne nicht in andere hinein
    // align: bewege dich in die Richtung deiner Nachbarn

    if (cohesionCount > 0)
    {
      cohesionSum.div (cohesionCount);
      cohesion (cohesionSum, 1);
    }

    if (alignCount > 0)
    {
      speedSum /= alignCount;
      alignSum.div (alignCount);
      align (alignSum, speedSum, 1.3);
    }

    if (seperationCount > 0)
    {
      seperationSum.div (seperationCount);
      seperation (seperationSum, 2);
    }
  }

  void cohesion (PVector force, float strength)
  {
    steer (force.x, force.y, strength);
  }

  void seperation (PVector force, float strength)
  {
    force.limit (strength*forceStrength);

    direction.add (force);
    direction.normalize();

    speed *= 1.1;
    speed = constrain (speed, 0, SPEED * 1.5);
  }

  void align (PVector force, float forceSpeed, float strength)
  {
    speed = lerp (speed, forceSpeed, strength*forceStrength);

    force.normalize();
    force.mult (strength*forceStrength);

    direction.add (force);
    direction.normalize();
  }

  // HOW TO MOVE ----------------------------

  void steer (float x, float y)
  {
    steer (x, y, 1);
  }

  void steer (float x, float y, float strength)
  {
    PVector location = f.getHead();

    float angle = atan2 (y-location.y, x -location.x);

    PVector force = new PVector (cos (angle), sin (angle));
    force.mult (forceStrength * strength);

    direction.add (force);
    direction.normalize();

    float currentDistance = dist (x, y, location.x, location.y);

    if (currentDistance < 70)
    {
      speed = map (currentDistance, 0, 70, 0, SPEED);
    }
    else speed = SPEED;
  }

  void seek (float x, float y)
  {
    seek (x, y, 1);
  }

  void seek (float x, float y, float strength)
  {
    PVector location = f.getHead();

    float angle = atan2 (y-location.y, x -location.x);

    PVector force = new PVector (cos (angle), sin (angle));
    force.mult (forceStrength * strength);

    direction.add (force);
    direction.normalize();
  }
  
  void addRadial ()
  {
    PVector location = f.getHead();
    
    float m = noise (frameCount / (2*noiseScale));
    m = map (m,0, 1, - 1.2, 1.2);
    
    float maxDistance = m * dist (0, 0, width/2, height/2);
    float distance = dist (location.x, location.y, width/2, height/2);
    
    float angle = map (distance, 0, maxDistance, 0, TWO_PI);
    
    PVector force = new PVector (cos (angle), sin (angle));
    force.mult (forceStrength);
    
    direction.add (force);
    direction.normalize();
  }

  void addNoise ()
  {
    PVector location = f.getHead();

    float noiseValue = noise (location.x /noiseScale, location.y / noiseScale, frameCount / noiseScale);
    noiseValue*= TWO_PI * noiseStrength;

    PVector force = new PVector (cos (noiseValue), sin (noiseValue));
    //Processing 2.0:
    //PVector force = PVector.fromAngle (noiseValue);
    force.mult (forceStrength);
    direction.add (force);
    direction.normalize();
  }

  // MOVE ----------------------------------------- 

  void move ()
  {
    PVector location = f.getHead();

    PVector velocity = direction.get();
    velocity.mult (speed);
    location.add (velocity);

    f.setHead (location);
  }

  // CHECK --------------------------------------------------------

  void checkEdgesAndRelocate ()
  {
    PVector location = f.getTail();
    float diameter = f.getSize();

    if (location.x < -diameter/2)
    {
      location.x = random (-diameter/2, width+diameter/2);
      location.y = random (-diameter/2, height+diameter/2);

      f.setHead (location);
      f.resetBody ();
    } 
    else if (location.x > width+diameter/2)
    {
      location.x = random (-diameter/2, width+diameter/2);
      location.y = random (-diameter/2, height+diameter/2);

      f.setHead (location);
      f.resetBody ();
    }

    if (location.y < -diameter/2)
    {
      location.x = random (-diameter/2, width+diameter/2);
      location.y = random (-diameter/2, height+diameter/2);
      f.setHead (location);
      f.resetBody ();
    } 
    else if (location.y > height + diameter/2)
    {
      location.x = random (-diameter/2, width+diameter/2);
      location.y = random (-diameter/2, height+diameter/2);
      f.setHead (location);
      f.resetBody ();
    }
  }


  void checkEdges ()
  {
    PVector location = f.getTail();
    float diameter = f.getSize();

    if (location.x < -diameter / 2)
    {
      location.x = width+diameter /2;
      f.setHead (location);
    } 
    else if (location.x > width+diameter /2)
    {
      location.x = -diameter /2;
      f.setHead (location);
    }

    if (location.y < -diameter /2)
    {
      location.y = height+diameter /2;
      f.setHead (location);
    } 
    else if (location.y > height+diameter /2)
    {
      location.y = -diameter /2;
      f.setHead (location);
    }
  }

  void checkEdgesAndBounce ()
  {
    PVector location = f.getHead();
    float radius = f.getSize() / 2;

    if (location.x < radius )
    {
      location.x = radius ;
      f.setHead (location);
      direction.x = direction.x * -1;
    } 
    else if (location.x > width-radius )
    {
      location.x = width-radius ;
      f.setHead (location);
      direction.x *= -1;
    }

    if (location.y < radius )
    {
      location.y = radius ;
      f.setHead (location);
      direction.y *= -1;
    } 
    else if (location.y > height-radius )
    {
      location.y = height-radius ;
      f.setHead (location);
      direction.y *= -1;
    }
  }

  // DISPLAY ---------------------------------------------------------------

  void display ()
  {
    f.display();
  }
}



void keyPressed ()
{
  if ( key == 'l') followLeader = !followLeader;
  if ( key == 'p') hidefromPredator = !hidefromPredator;
  if (key == ' ')
  {
    bewegungsModus++;
    if (bewegungsModus > 5) bewegungsModus = 0;
  }
}
