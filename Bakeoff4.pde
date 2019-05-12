import java.util.ArrayList;
import java.util.Collections;
import ketai.sensors.*;

KetaiSensor sensor;
float angleCursor = 0;
float light = 0; 
float accel = 0;
float proxSensorThreshold = 20; //you will need to change this per your device.

private class Target
{
  int target = 0;
  int action = 0;
}

int trialCount = 5; //this will be set higher for the bakeoff
int trialIndex = 0;
ArrayList<Target> targets = new ArrayList<Target>();

int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
int countDownTimerWait = 0;
boolean phase1 = true;
float end_result = 1.0;
boolean waiting=true;
boolean ERROR_HAPPENED = false;
void setup() {
 // size(800, 800); //you can change this to be fullscreen
  //frameRate(30);
  orientation(PORTRAIT);
   
  sensor = new KetaiSensor(this);
  sensor.start();
  //sensor.enableMagenticField();
  //sensor.enableOrientation();
  
  rectMode(CENTER);
  textFont(createFont("Arial", 40)); //sets the font to Arial size 20
  textAlign(CENTER);
  noStroke(); //no stroke

  for (int i=0; i<trialCount; i++)  //don't change this!
  {
    Target t = new Target();
    t.target = ((int)random(1000))%4;
    t.action = ((int)random(1000))%2;
    targets.add(t);
    //println("created target with " + t.target + "," + t.action);
  }

  Collections.shuffle(targets); // randomize the order of the button;
}

void draw() {
  int index = trialIndex;

  //uncomment line below to see if sensors are updating
  //println("light val: " + light +", cursor accel vals: " + cursorX +"/" + cursorY);
  background(80); //background is light grey

  countDownTimerWait--;

  if (startTime == 0)
    startTime = millis();

  if (index>=targets.size() && !userDone)
  {
    userDone=true;
    finishTime = millis();
  }

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, 50);
    text("User took " + nfc((finishTime-startTime)/1000f/trialCount, 2) + " sec per target", width/2, 150);
    return;
  }

//code to draw four target dots in a grid
  if (phase1) {
    System.out.println("drawing phase1");
    // first box (top)
    if (targets.get(index).target==0) fill(0, 255, 0);
    else fill(180, 180, 180);
    rect(width/2, 0, width*(3.0/4.0), height*(1.0/5.0));
    // second box (right)
    if (targets.get(index).target==1) fill(0, 255, 0);
    else fill(180, 180, 180);
    rect(width, height/2.0, width/3.0, height/2.0);
    //// third box (bottom)
    if (targets.get(index).target==2) fill(0, 255, 0);
    else fill(180, 180, 180);
    rect(width/2, height, width*(3.0/4.0), height*(1.0/5.0));
    //// fourth box (left)
    if (targets.get(index).target==3) fill(0, 255, 0);
    else fill(180, 180, 180);
    rect(0, height/2.0, width/3.0, height/2.0);
  }
  
  if (!phase1) {
    // phase 2
    System.out.println("Drawing phase2");
    if (targets.get(index).action==0){  // PRESS DOWN
      fill(0, 255, 0);
    } else {
      fill(180, 180, 180);
    }
    rect(width/2, height/3.0, width*(3.0/4.0), height*(1.0/5.0));
    //fill(0);
    //text("press down", width/2+20, height/3.0+20);
    
    if (targets.get(index).action==1){ // DONT PRESS
      fill(0, 255, 0);
    } else {
      fill(180, 180, 180);
    }
    rect(width/2, height/3*2, width*(3.0/4.0), height*(1.0/5.0));
    //fill(0);
    //text("do nothing", width/2+20, height/3*2+20);

  }
  
  
  fill(255);//white
  text("Trial " + (index+1) + " of " +trialCount, width/2, 50);
  //text("Target #" + (targets.get(index).target), width/2, 100);
 
}

//void update() {
//  System.out.println("calling");
//  waitFunction();
//}


void onAccelerometerEvent(float accelerometerX, float accelerometerY, float accelerometerZ)
{
  
  if (phase1) {
    ERROR_HAPPENED = false;
    System.out.println("onAccelEvent");
    if (userDone || trialIndex>=targets.size()) return;
    Target t = targets.get(trialIndex);
    if (t==null) return;
    
    if (accelerometerX  >= 5 && targets.get(trialIndex).target==3) {System.out.println("1"); phase1=false; thread("waitFunction"); }//left
    else if (accelerometerX  <= -5 && targets.get(trialIndex).target==1) {System.out.println("2"); phase1=false; thread("waitFunction"); } //right
    else if (accelerometerY  >= 4 && targets.get(trialIndex).target==2) {System.out.println("3"); phase1=false; thread("waitFunction"); } //bottom
    else if (accelerometerY  <= -4 && targets.get(trialIndex).target==0) {System.out.println("4"); phase1=false; thread("waitFunction"); } //top
    else if (accelerometerX  >= 5 && targets.get(trialIndex).target!=3) {System.out.println("5"); phase1=false; ERROR_HAPPENED=true; thread("waitFunction"); }//wrong left
    else if (accelerometerX  <= -5 && targets.get(trialIndex).target!=1) {System.out.println("6"); phase1=false; ERROR_HAPPENED=true; thread("waitFunction"); } //wrong right
    else if (accelerometerY  >= 4 && targets.get(trialIndex).target!=2) {System.out.println("7"); phase1=false; ERROR_HAPPENED=true; thread("waitFunction"); } //wrong bottom
    else if (accelerometerY  <= -4 && targets.get(trialIndex).target!=0) {System.out.println("8"); phase1=false; ERROR_HAPPENED=true; thread("waitFunction");  }  // wrong top
  }
}

void waitFunction() {
  if (!phase1) {
    
    System.out.println("wait function in phase 2");
    int index = trialIndex;
    int now = millis(); 
    int end = millis() + 900;
    System.out.println("STARTING TO WAIT ");
    
    for (now = millis(); now <= end && end_result == 1.0 ; now = millis()) {
      waiting=true;
      System.out.println("waiting");
    }
    waiting=false;

    System.out.println("DONE WAITING");
    
    if (end_result == 1 && targets.get(index).action==0) {
      ERROR_HAPPENED = true;
    } else if (end_result == 0 && targets.get(index).action==1) {
      ERROR_HAPPENED = true;
    }
    
    if (ERROR_HAPPENED) {
      if (trialIndex != 0) {phase1=true; trialIndex--; end_result = 1.0;}
      else {phase1=true; trialIndex = 0; end_result = 1.0;}
    } else {
      phase1=true;
      trialIndex++;
      end_result = 1.0;
    }
    
  }
}

void onProximityEvent(float disstance)
{
  System.out.println("onProxEvent");
  if (waiting) {
    end_result = disstance;
  }
}
