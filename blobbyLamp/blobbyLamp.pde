// Lava_Lamp_v4.0, by Damian
// a variation on https://www.openprocessing.org/sketch/381382 - Lava_Light_modoki_3.0 by KaijinQ

// variables to play with
int Nmax = 200 ; //number of particles
float M = 10 ; //M = mass of particle, default 10, affects how responds to gravity.
float R = 3 ; //R = particle radius, default 3
float R2 = R+2.5; // particle draw radius, default R+1.5
float G = 0.02; //G = general gravity, default 0.02, 1=lots, 0=none. 
float GG = 45 ; //GG = particle gravity, default 45 (2.5=particles loose, 22.5 particles clumpy)
float GGrad = R*1.0002; // default 10; radius of gravity of particle
float K = 3 ; //K = default 0.5, 0.1 very clumpy particles, 0.9 not. A spring constant.
float P = 0.015 ; //P = default 0.015, 0.9 highly sensitive to temperature changes. 0.001 doesn't rise.
float H = 0.935 ; //H = default 0.935, velocity factor, 0.005 does't do anything, 0.5 everything is slow.

float xsize = 70; //width of lava lamp
float ysize = 140; //height of lava lamp
float heatrate = 0.2; // default 0.2; rate at which heat is gained in the heatzone
float yheatzone = 65; // default 65; height of heatzone
float xheatzone = xsize/32; // default xsize/16; width of noheatzone (edges), creates a convection effect in centre if non-zero.
float coolrate = 0.2; //default 0.2; rate at which heat is lost in the coolzone
float heattransrate = 0.045; //default 0.045; rate at which heat shared between touching particles.
float heatloss = 0.012; //default 0.012; rate at which heat leaks from a particle in normal space.

float X[] = new float[Nmax+1] ; float Y[] = new float[Nmax+1] ; //position array
float T[] = new float[Nmax+1] ; //temperature array
float FX[] = new float[Nmax+1] ; float FY[] = new float[Nmax+1] ; //force array
float VX[] = new float[Nmax+1] ; float VY[] = new float[Nmax+1] ; //velocity array
float L = 0 ; 
int I = 0 ; int II = 0 ; 

//colour temperature
float cmin = -100; //dark blue; default -100
float clow = -40; //blue; default -40
float chigh = 40; //magenta; default 40
float chot = 60; //red; default 60
float cmax = 120; //yellow; default 120
float copq = 255; // fill opacity 0-255; default 100

OPC opc;

void setup(){
  size(70,140) ;
  background(0,0,0) ;
  stroke(255,0,0,100) ;
  fill(255,0,0,100) ;
  for ( I = 0 ; I <= Nmax ; I++ ){
    X[I] = random(0.00,xsize) ;
    Y[I] = random(0.8*ysize,ysize) ; //(0.8*ysize,ysize) particles start in bottom 1/5 of the column; (0.00, ysize) to appear everywhere.
    T[I] = -20 ; //default 0
  }
  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledGrid(0, 15, 4, width*0.25, height/2, height/15, width/8, 4.712, true);
  opc.ledGrid(64, 15, 4, width*0.75, height/2, height/15, width/8, 4.712, true);
} // setup()


void draw(){
  background(0,0,0) ;
  
  //I think this is looping through each particle for each other particle.
  for ( I = 0 ; I <= Nmax ; I++ ){
    for ( II = I+1 ; II <= Nmax ; II++ ){
        
        // l is the length of the line between two particles
        L = sqrt(((X[I]-X[II])*(X[I]-X[II]))+((Y[I]-Y[II])*(Y[I]-Y[II]))) ;
        
        //if distance between particles is less than twice the radius of the particle
        //then spring them apart as defined by the spring constant K
        if ( L < R*2 ){ 
          FX[I]  = FX[I] - (((X[II]-X[I])/L)*(K*(2*R-L))) ;
          FY[I]  = FY[I] - (((Y[II]-Y[I])/L)*(K*(2*R-L))) ;
          FX[II] = FX[II] + (((X[II]-X[I])/L)*(K*(2*R-L))) ;
          FY[II] = FY[II] + (((Y[II]-Y[I])/L)*(K*(2*R-L))) ;
          
          //heat transfer rate from one particle to the next.
          //for particles that are touching.
          if ( T[I] < T[II] ){ 
            T[I] = T[I] + heattransrate ; T[II] = T[II] - heattransrate ;  
            }else{
            T[I] = T[I] - heattransrate ; T[II] = T[II] + heattransrate ;  
          }         
        }
      
        // if distance is greater than twice the radius of the particle
        // and less than the gravity radius of the particle.
        // particles attract by a force of gravity
        if ( L >= R*2 && L < R*GGrad ){
          FX[I] = FX[I] + (((X[II]-X[I])/L)*(GG/(L*L))) ;
          FY[I] = FY[I] + (((Y[II]-Y[I])/L)*(GG/(L*L))) ;
          FX[II] = FX[II] - (((X[II]-X[I])/L)*(GG/(L*L))) ;
          FY[II] = FY[II] - (((Y[II]-Y[I])/L)*(GG/(L*L))) ; 
        }
    }
    
    // if position is less than particle radius, spring in the x direction
    if ( X[I] < R ){ FX[I] = FX[I] + (K*(R-X[I])) ; }
    
    //boundary condition for width
    if ( X[I] > xsize-R ){ FX[I] = FX[I] - (K*(X[I]-xsize+R)) ; }
    
    // if position is less than particle radius?, spring in the Y direction
    if ( Y[I] < R ){ FY[I] = FY[I] + (K*(R-Y[I])) ; }
    
    //boundary condition for height
    if ( Y[I] > ysize-R ){ FY[I] = FY[I] - (K*(Y[I]-ysize+R)) ; }
    
    // apply forces
    FY[I] = FY[I] + (M*G) - (P*T[I]) ;
    
    //heat zone
    if ( Y[I] > ysize-yheatzone && X[I] < xsize-xheatzone && X[I] > xheatzone){ T[I] = T[I] + heatrate ; }

  //cooling zone
    if ( Y[I] <= 75 ){ T[I] = T[I] - coolrate ; }
    
    //heatloss
    T[I] = T[I] - heatloss;
  }
  
  for ( I = 0 ; I <= Nmax ; I++ ){
    //calculate new velocities from forces (times H factor)
    VX[I] = ( VX[I] + (FX[I]/M) ) * H ;
    VY[I] = ( VY[I] + (FY[I]/M) ) * H ;
    
    //velocity limits
    if ( sqrt((VX[I]*VX[I])+(VY[I]*VY[I])) < 0.1 && Y[I] < ysize-75 ){ T[I] = T[I] - 0.1 ; }
    
    //if speed exceeds 1.5, reduce to less than 1.5
    if ( sqrt((VX[I]*VX[I])+(VY[I]*VY[I])) > 1.5 ){ 
      VX[I] = VX[I]*(1.5/sqrt((VX[I]*VX[I])+(VY[I]*VY[I]))) ; 
      VY[I] = VY[I]*(1.5/sqrt((VX[I]*VX[I])+(VY[I]*VY[I]))) ; 
    } //if
    
    //clear the force matrix
    FX[I] = 0 ; FY[I] = 0 ;
    
    //calculate new positions of particles
    X[I] = X[I] + VX[I] ; 
    Y[I] = Y[I] + VY[I] ;
    
    //colour in the particles
    if ( T[I] > cmax )
    { stroke(255,255,0,0) ; fill(255,255,0,copq) ; }
    
    if ( T[I] <= cmax && T[I] >= chot )
    { stroke(255,255*(T[I]-chot)/(cmax-chot),0,0) ; 
     fill(255,255*(T[I]-chot)/(cmax-chot),0,copq) ; }
    
    if ( T[I] <= chot && T[I] >= chigh )
    { stroke(255,0,255-255*(T[I]-chigh)/(chot-chigh),0) ; 
     fill(255,0,255-255*(T[I]-chigh)/(chot-chigh),copq) ; }
    
    if ( T[I] < chigh && T[I] >= clow )
    { stroke(255*(T[I]-clow)/(chigh-clow),0,255,0) ; 
     fill(255*(T[I]-clow)/(chigh-clow),0,255,copq) ; }
    
    if ( T[I] < clow && T[I] >= cmin )
    { stroke(0,0,100+155*(T[I]-cmin)/(clow-cmin),0) ; 
     fill(0,0,100+155*(T[I]-cmin)/(clow-cmin),copq) ; }
    
    if ( T[I] < cmin )
    { stroke(0,0,100,0) ; fill(0,0,100,copq) ; }
    
    //draw the particles
    ellipse(X[I],Y[I],R2*2,R2*2) ;
  }
  filter(BLUR, 3);
 
} // draw()

void mousePressed(){
  //setup() ; //I turned this off
} // mousePressed()
