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
    if (targets.get(index).target==1) fill(0, 255, 0);
    else fill(180, 180, 180);
    rect(width/2, height-(4.0/5.0)*height, width*(3.0/4.0), width*(4.0/5.0));
    // second box (right)
    if (targets.get(index).target==2) fill(0, 255, 0);
    else fill(180, 180, 180);
    rect(width-(4.0/5.0)*width, height/3.0, width/6.0, height/3.0);
    // third box (bottom)
    if (targets.get(index).target==3) fill(0, 255, 0);
    else fill(180, 180, 180);
    rect(width/2, height-(1.0/5.0)*height, width*(3.0/4.0), width*(4.0/5.0));
    // fourth box (left)
    if (targets.get(index).target==4) fill(0, 255, 0);
    else fill(180, 180, 180);
    rect(width-(1.0/5.0)*width, height/3.0, width/6.0, height/3.0);
  } else {
    // phase 2
    triangle(0,height,0,height/9.0,width/5.0,height);
    triangle(width,height,width,height/9.0,width*(4.0/5.0),height);
  }

  translate(width/2,height/2);
  rotate(radians(angleCursor));
  rect(140,0, 50, 50);
  popMatrix();

  fill(255);//white
  text("Trial " + (index+1) + " of " +trialCount, width/2, 50);
  //text("Target #" + (targets.get(index).target), width/2, 100);

//only show phase two if the finger is down
if (light<=proxSensorThreshold)
{
  if (targets.get(index).action==0)
    text("Action: UP", width/2, 150);
  else
    text("Action: DOWN", width/2, 150);
}
  
  //debug output only, slows down rendering
  //text("light level:" + int(light), width/2, height-100);
  //text("z-axis accel: " + nf(accel,0,1), width/2, height-50); //use this to check z output!
  //text("touching target #" + hitTest(), width/2, height-150); //use this to check z output!
  
}

int hitTest()
{
  if (angleCursor>330 || angleCursor<30)
     return 0;
  else if (angleCursor>60 && angleCursor<120)
     return 1;
  else if (angleCursor>150 && angleCursor<210)
     return 2;
  else if (angleCursor>240 && angleCursor<300)
     return 3;
  else
    return -1;
}

void onAccelerometerEvent(float x, float y, float z)
{
  accel = z-9.8;//update global variable and subtract gravity (9.8 newtons)
  
  if (userDone || trialIndex>=targets.size())
    return;
    
  Target t = targets.get(trialIndex);

  if (t==null)
    return;
     
  if (light<=proxSensorThreshold && abs(accel)>4 && countDownTimerWait<0) //possible hit event
  {
    if (hitTest()==t.target)//check if it is the right target
    {
      if (((accel)>4 && t.action==0) || ((accel)<-4 && t.action==1))
      {
        //println("Right target, right z direction!");
        trialIndex++; //next trial!
      } 
      else
      {
        if (trialIndex>0)
          trialIndex--; //move back one trial as penalty!
        //println("right target, WRONG z direction!");
      }
      countDownTimerWait=10; //wait roughly 0.5 sec before allowing next trial
    } 
  } 
  else if (light<=proxSensorThreshold && countDownTimerWait<0 && hitTest()!=t.target)
  { 
    //println("wrong round 1 action!"); 
    if (trialIndex>0)
      trialIndex--; //move back one trial as penalty!

    countDownTimerWait=10; //wait roughly 0.5 sec before allowing next trial
  }
}
