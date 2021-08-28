class Blob {
  PVector min = new PVector();
  PVector max = new PVector();
  int threshold = 15;

  Blob(int x, int y){
    min = new PVector(x,y);
    max = new PVector(x,y);
  }
  
  boolean isNear(int x, int y){
    return (
      x > min.x - threshold &&
      y > min.y - threshold &&
      x < max.x + threshold &&
      y < max.y + threshold
    );
  }
  
  void add(float x, float y) {
    min.x = min(min.x, x);
    min.y = min(min.y, y);
    max.x = max(max.x, x);
    max.y = max(max.y, y);
  }
  void display() {
    fill(1,0);
    stroke(1,1,1);
    rect(min.x, min.y, max.x-min.x, max.y-min.y);
    stroke(.5,1,1);
    rect(min.x-threshold, min.y-threshold, max.x-min.x+threshold*2, max.y-min.y+threshold*2);
  }
  void mergeWith(Blob otherBlob){
    // this OR the other blob need to be removed from the arraylist
    //println(otherBlob.min.x);
  }
}
