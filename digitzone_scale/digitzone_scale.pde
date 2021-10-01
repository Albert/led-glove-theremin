import processing.video.*;
import processing.sound.*;

ArrayList<SawOsc> oscs = new ArrayList<SawOsc>();

Capture cam;
ArrayList<Blob> blobs = new ArrayList<Blob>();
ArrayList<Integer> targets = new ArrayList<Integer>();
ArrayList<Integer> biggestBlobIndices = new ArrayList<Integer>();
String[] cameras = Capture.list();

ArrayList<Float> cmaj = new ArrayList<Float>();
ArrayList<String> cmajnames = new ArrayList<String>();

int baseNoteIdx = -1;

void setup() {
  size(640,480);
  cam = new Capture(this, cameras[1]);
  //cam = new Capture(this, "pipeline:autovideosrc");
  cam.start();
  colorMode(HSB,1);
  
  // create and start the sine oscillator.
  for (int i = 0; i<4; i++) {
    oscs.add(new SawOsc(this));
  }
  cmaj.add(196.00); cmajnames.add("G");
  cmaj.add(220.00); cmajnames.add("A");
  cmaj.add(246.94); cmajnames.add("B");
  cmaj.add(261.63); cmajnames.add("C");
  cmaj.add(293.66); cmajnames.add("D");
  cmaj.add(329.63); cmajnames.add("E");
  cmaj.add(349.23); cmajnames.add("F");
  cmaj.add(392.00); cmajnames.add("G");
  cmaj.add(440.00); cmajnames.add("A");
  cmaj.add(493.88); cmajnames.add("B");
  cmaj.add(523.25); cmajnames.add("C");
  cmaj.add(587.33); cmajnames.add("D");
  cmaj.add(659.25); cmajnames.add("E");
  cmaj.add(698.46); cmajnames.add("F");
  cmaj.add(783.99); cmajnames.add("G");
  
  targets.add(-12853515); // blue
  targets.add(-697489);  // red
  targets.add(-9122158);  // green
  targets.add(-1191498);   // yellow
  targets.add(-19202);   // pink
}

void mouseClicked() {
  targets.add(cam.get(width-mouseX,mouseY));
  if (targets.size() > 5) {
    targets.remove(0);
  }
}

void keyPressed() {
  if (key==' ') {
    for (int i = 0; i < targets.size(); i++){
      println(targets.get(i));
    }
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
    for(int x=0;x<width;x+=2){
      for(int y=0;y<height;y+=2){ // TODO consider optimizing to single: for int i<width*height
        color c = cam.pixels[x + y * cam.width];
        if (dist(hue(c),saturation(c),brightness(c),hue(t),saturation(t),brightness(t))<0.15) {
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

  for (int i=0; i<5; i++) {
    if (biggestBlobIndices.get(i) != -1){
      blobs.get(biggestBlobIndices.get(i)).display();
    }
  }
  for(int i=0;i<15;i++){
    push();
    scale( -1, 1 );
    float x = float(i)/cmaj.size()*float(width);
    translate(-cam.width + x, 0);
    stroke(0,.3);
    if(i==baseNoteIdx){
      fill(1,1,1,0.3);
    } else {
      fill(1,0);
    }

    rect(0,0,float(width)/cmaj.size(),height);
    fill(1,1);
    text(cmajnames.get(i), 15, height-50);
    pop();
  }
  if (biggestBlobIndices.get(0) != -1){
    float frequency = map(width-blobs.get(biggestBlobIndices.get(0)).center().x, 0, width, 180.0, 750.0);
    if (biggestBlobIndices.get(0) != -1) {
      Blob b = blobs.get(biggestBlobIndices.get(0));
      baseNoteIdx = floor((float(width) - b.center().x)/(float(width)/cmaj.size()));
    } else {
      baseNoteIdx = -1;
    }
  }
} 
    /*
          rect(mouseX,0,100,100);
      rect(blobs.get(biggestBlobIndices.get(0)).center().x, blobs.get(biggestBlobIndices.get(0)).center().y, 10, 10);
      push();
      scale( -1, 1 );
      translate(-cam.width, 0);
      pop();
    */
    
    
    /*
    oscs.get(0).freq(frequency);
    if (biggestBlobIndices.get(1) != -1) {
      float amplitude = map(blobs.get(biggestBlobIndices.get(0)).center().dist(blobs.get(biggestBlobIndices.get(1)).center()), 0, 100, 1.0, 0.0);
      amplitude = constrain(amplitude, 0, 1);
      if (amplitude == 0) {
        oscs.get(0).stop();
      } else {
        oscs.get(0).play();
        oscs.get(0).amp(amplitude);
      }
    } else {
      oscs.get(0).stop();
    }
    oscs.get(1).freq(frequency*1.25);
    if (biggestBlobIndices.get(2) != -1) {
      float amplitude = map(blobs.get(biggestBlobIndices.get(0)).center().dist(blobs.get(biggestBlobIndices.get(2)).center()), 0, 100, 1.0, 0.0);
      amplitude = constrain(amplitude, 0, 1);
      if (amplitude == 0) {
        oscs.get(1).stop();
      } else {
        oscs.get(1).play();
        oscs.get(1).amp(amplitude);
      }
    } else {
      oscs.get(1).stop();
    }
    oscs.get(2).freq(frequency*1.5);
    if (biggestBlobIndices.get(3) != -1) {
      float amplitude = map(blobs.get(biggestBlobIndices.get(0)).center().dist(blobs.get(biggestBlobIndices.get(3)).center()), 0, 100, 1.0, 0.0);
      amplitude = constrain(amplitude, 0, 1);
      if (amplitude == 0) {
        oscs.get(2).stop();
      } else {
        oscs.get(2).play();
        oscs.get(2).amp(amplitude);
      }
    } else {
      oscs.get(2).stop();
    }
    oscs.get(3).freq(frequency*2);
    if (biggestBlobIndices.get(4) != -1) {
      float amplitude = map(blobs.get(biggestBlobIndices.get(0)).center().dist(blobs.get(biggestBlobIndices.get(4)).center()), 0, 100, 1.0, 0.0);
      amplitude = constrain(amplitude, 0, 1);
      if (amplitude == 0) {
        oscs.get(3).stop();
      } else {
        oscs.get(3).play();
        oscs.get(3).amp(amplitude);
      }
    } else {
      oscs.get(3).stop();
    }
    */
