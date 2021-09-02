import processing.video.*;
Capture cam;
ArrayList<Blob> blobs = new ArrayList<Blob>();
ArrayList<Integer> targets = new ArrayList<Integer>();
ArrayList<Integer> biggestBlobIndices = new ArrayList<Integer>();
String[] cameras = Capture.list();

ArrayList<PVector> sts = new ArrayList<PVector>(); //screen targets
PVector st;

void setup() {
  size(640,480);
  cam = new Capture(this, cameras[0]);
  //cam = new Capture(this, "pipeline:autovideosrc");
  cam.start();
  colorMode(HSB,1);
  st = new PVector(random(width), random(height));
}

void mouseClicked() {
  targets.add(cam.get(width-mouseX,mouseY));
  if (targets.size() > 2) {
    targets.remove(0);
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
        if (dist(hue(c),saturation(c),brightness(c),hue(t),saturation(t),brightness(t))<0.3) {
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
  rect(st.x, st.y, 20, 20);

  for (int i = 0; i < biggestBlobIndices.size(); i++) {
    if (biggestBlobIndices.get(i) != -1){
      if (PVector.sub(blobs.get(biggestBlobIndices.get(i)).center(), st).mag() < 50) {
        st = new PVector(random(width), random(height));
      }
      blobs.get(biggestBlobIndices.get(i)).display();
    }
  }
}
