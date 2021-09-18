import processing.video.*;
import processing.sound.*;

SawOsc sine;

Capture cam;
ArrayList<Blob> blobs = new ArrayList<Blob>();
ArrayList<Integer> targets = new ArrayList<Integer>();
ArrayList<Integer> biggestBlobIndices = new ArrayList<Integer>();
String[] cameras = Capture.list();

ArrayList<PVector> sts = new ArrayList<PVector>(); //screen targets
int currentStep = 0;
int direction = 1;
boolean flash = false;
ArrayList<Float> notes = new ArrayList<Float>();
ArrayList<Float> cmaj = new ArrayList<Float>();
boolean theremin = true;
boolean autotune = false;
boolean scaleOnly = false;


void setup() {
  size(640,480);
  cam = new Capture(this, cameras[1]);
  //cam = new Capture(this, "pipeline:autovideosrc");
  cam.start();
  colorMode(HSB,1);
  for (int i=0; i<4; i++) {
    sts.add(new PVector(85+150*i, 15+150*i));
  }
  
  // create and start the sine oscillator.
  sine = new SawOsc(this);
  sine.play();
  notes.add(196.00); cmaj.add(196.00);
  notes.add(207.65);
  notes.add(220.00); cmaj.add(220.00);
  notes.add(233.08);
  notes.add(246.94); cmaj.add(246.94);
  notes.add(261.63); cmaj.add(261.63);
  notes.add(277.18);
  notes.add(293.66); cmaj.add(293.66);
  notes.add(311.13);
  notes.add(329.63); cmaj.add(329.63);
  notes.add(349.23); cmaj.add(349.23);
  notes.add(369.99);
  notes.add(392.00); cmaj.add(392.00);
  notes.add(415.30);
  notes.add(440.00); cmaj.add(440.00);
  notes.add(466.16);
  notes.add(493.88); cmaj.add(493.88);
  notes.add(523.25); cmaj.add(523.25);
  notes.add(554.37);
  notes.add(587.33); cmaj.add(587.33);
  notes.add(622.25);
  notes.add(659.25); cmaj.add(659.25);
  notes.add(698.46); cmaj.add(698.46);
  notes.add(739.99);


  
  targets.add(-197893);
  targets.add(-4851204);
}

void mouseClicked() {
  targets.add(cam.get(width-mouseX,mouseY));
  if (targets.size() > 2) {
    targets.remove(0);
  }
}

void keyPressed() {
  if (key=='1') {
    theremin = true;
    autotune = false;
  } else if (key=='2') {
    theremin = true;
    autotune = true;
    scaleOnly= false;
  } else if (key=='3') {
    theremin = true;
    autotune = true;
    scaleOnly= true;
  } else if (key=='4') {
    theremin = false;
  }
}

void draw() {
  translate(cam.width, 0);
  scale( -1, 1 );
  
  clear();
  if (cam.available()) { cam.read(); cam.loadPixels(); }
  // TODO test if cam.loadPixels() is necessary

  blobs.clear();
  biggestBlobIndices.clear();
  for(int targetIndex = 0; targetIndex < targets.size(); targetIndex++) {
    color t = targets.get(targetIndex);
    for(int x=0;x<width;x+=1){
      for(int y=0;y<height;y+=1){ // TODO consider optimizing to single: for int i<width*height
        color c = cam.pixels[x + y * cam.width];
        if (dist(hue(c),saturation(c),brightness(c),hue(t),saturation(t),brightness(t))<0.2) {
          int previousMatch = -1;
          int toMerge = -1;
          for(int i=0;i<blobs.size();i++){
            Blob b = blobs.get(i);
            if (b.t == t && b.isNear(x,y)) {
              b.add(x,y);
              if (previousMatch != -1) {
                toMerge = i;
              }
              previousMatch = i;
            }
          }
          if (previousMatch == -1) {
            blobs.add(new Blob(x,y,t));
          } else if (toMerge != -1) {
            blobs.get(toMerge).engulf(blobs.get(previousMatch));
            blobs.remove(previousMatch);
          }
        }
      }
    }
    biggestBlobIndices.add(-1);
    float biggestArea = 0;
    for(int i=0;i<blobs.size();i++){
      if(blobs.get(i).t == t && biggestArea < blobs.get(i).area()) {
        biggestBlobIndices.set(targetIndex, i);
        biggestArea = blobs.get(i).area();
      }
    }
  }
  image(cam,0,0);
  stroke(1);

  if (biggestBlobIndices.size() == 2){
    int targetsHit = 0;
    for (int i=0; i<2; i++) {
      if (biggestBlobIndices.get(i) != -1){
        int tindex;
        if (currentStep%2==0){
          tindex = currentStep+i;
        } else {
          tindex = (i==0) ? currentStep+1 : currentStep;
        }
        if (PVector.sub(blobs.get(biggestBlobIndices.get(i)).center(), sts.get(tindex)).mag() < 50) {
          targetsHit++;
        }
        blobs.get(biggestBlobIndices.get(i)).display();
      }
    }
    
    if (theremin == true){
      if (biggestBlobIndices.get(0) != -1){
        float frequency = map(width-blobs.get(biggestBlobIndices.get(0)).center().x, 0, width, 180.0, 750.0);
        if (autotune == true) {
          int n = 0;
          if (scaleOnly==true) {
            while(n < cmaj.size()) {
              if (frequency < cmaj.get(n)){
                frequency = cmaj.get(n);
                n = cmaj.size();
              } else {
                n++;
              }
            }
          } else {
            while(n < notes.size()) {
              if (frequency < notes.get(n)){
                frequency = notes.get(n);
                n = notes.size();
              } else {
                n++;
              }
            }
          }
        }
        sine.freq(frequency);
        if (biggestBlobIndices.get(1) != -1) {
          float amplitude = map(blobs.get(biggestBlobIndices.get(0)).center().dist(blobs.get(biggestBlobIndices.get(1)).center()), 0, 100, 1.0, 0.0);
          amplitude = constrain(amplitude, 0, 1);
          if (amplitude == 0) {
            sine.stop();
          } else {
            sine.play();
            sine.amp(amplitude);
          }
        }
      }
    } else {
      sine.stop();
    }
    
    if (targetsHit==2){
      flash = true;
      currentStep+=direction;
      if (currentStep==3){
        direction = -1;
        currentStep = 1;
      } else if (currentStep==-1){
        direction = 1;
        currentStep = 1;
      }
    }
    for (int i=0; i<2; i++){
      if (theremin==false) {
        push();
        int cindex;
        if (currentStep%2==0){
          cindex = i;
        } else {
          cindex = (i==0) ? 1 : 0;
        }
        fill(targets.get(cindex));
        rect(sts.get(currentStep+i).x, sts.get(currentStep+i).y, 10, 10);
        pop();
      }
    }
  } else {
    push();
    scale( -1, 1 );
    translate(-cam.width, 0);
    text("Pick two color points",100,100);
    pop();
  }
  if (flash==true) {
    clear();
    flash = false;
  }
  if (theremin == true) {
    if (scaleOnly == true) {
      for (int i = 0; i < cmaj.size(); i++){
        push();
        float n = cmaj.get(i);
        
        fill(0,255,0);
        if (n==440) {
          fill(0,0,255);
        }
        //float frequency = map(width-blobs.get(biggestBlobIndices.get(0)).center().x, 0, width, 180.0, 750.0);
  
        float l = map(n, 180, 750, width,0);
        stroke(1,.25);
        line(l,0,l,height);
        pop();
      }
    } else {
      for (int i = 0; i < notes.size(); i++){
        push();
        float n = notes.get(i);
        
        fill(0,255,0);
        if (n==440) {
          fill(0,0,255);
        }
        //float frequency = map(width-blobs.get(biggestBlobIndices.get(0)).center().x, 0, width, 180.0, 750.0);
  
        float l = map(n, 180, 750, width,0);
        stroke(1,.25);
        line(l,0,l,height);
        pop();
      }

    }
  }
}
