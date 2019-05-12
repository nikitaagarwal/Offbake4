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
  } else {
    // phase 2
    if (targets.get(index).action==0){
      fill(0, 255, 0);
    } else {
      fill(180, 180, 180);
    }
    triangle(0.0, 0.0, 0.0, height/3.0, width/2.5, 0.0); 
    if (targets.get(index).action==1){
      fill(0, 255, 0);
    } else {
      fill(180, 180, 180);
    }
    triangle(width, 0.0, width, height/3.0, width-width/2.5, 0.0);
  }

  fill(255);//white
  text("Trial " + (index+1) + " of " +trialCount, width/2, 50);
  //text("Target #" + (targets.get(index).target), width/2, 100);

  
}


void onAccelerometerEvent(float accelerometerX, float accelerometerY, float accelerometerZ)
{
  if (phase1) {
    if (userDone || trialIndex>=targets.size()) return;
    Target t = targets.get(trialIndex);
    if (t==null) return;
    
    if (accelerometerX  >= 5 && targets.get(trialIndex).target==3) {trialIndex++; phase1=false; }//left
    else if (accelerometerX  <= -5 && targets.get(trialIndex).target==1) {trialIndex++; phase1=false; } //right
    else if (accelerometerY  >= 4 && targets.get(trialIndex).target==2) {trialIndex++; phase1=false; } //bottom
    else if (accelerometerY  <= -4 && targets.get(trialIndex).target==0) {trialIndex++; phase1=false; } //top
    else if (accelerometerX  >= 5 || accelerometerX  <= -5 || accelerometerY  >= 4 || accelerometerY  <= -4) {
      if (trialIndex>0) {trialIndex--; phase1=false;}
    }
    
  }
}

//void onAccelerometerEvent(float accelerometerX, float accelerometerY, float accelerometerZ)
//{
  
//  if (phase1) {
    
//    if (userDone || trialIndex>=targets.size()) return;
//    Target t = targets.get(trialIndex);
//    if (t==null) return;
    
//    if (accelerometerX  >= 5 && targets.get(trialIndex).target==4) trialIndex++; //left
//    else if (accelerometerX  <= -5 && targets.get(trialIndex).target==2) trialIndex++; //right
//    else if (accelerometerY  >= 4 && targets.get(trialIndex).target==3) trialIndex++; //bottom
//    else if (accelerometerY  <= -4 && targets.get(trialIndex).target==1) trialIndex++; //top
//    else if (accelerometerX  >= 5 || accelerometerX  <= -5 || accelerometerY  >= 4 || accelerometerY  <= -4) {
//      if (trialIndex>0) trialIndex--;
     
//    }
//    //phase1=false;
//  }
  
//}
