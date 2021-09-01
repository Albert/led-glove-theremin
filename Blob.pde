class Blob {
  PVector min = new PVector();
  PVector max = new PVector();
  int threshold = 15;
  color t;

  Blob(int x, int y, color in_t){
    min = new PVector(x,y);
    max = new PVector(x,y);
    t = in_t;
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
    stroke(.33,1,1);
    rect(min.x-threshold, min.y-threshold, max.x-min.x+threshold*2, max.y-min.y+threshold*2);
    stroke(.66,1,1);
    rect(center().x-5, center().y-5, 10, 10);
  }
  void engulf(Blob otherBlob){
    min.x = min(min.x, otherBlob.min.x);
    min.y = min(min.y, otherBlob.min.y);
    max.x = max(max.x, otherBlob.max.x);
    max.y = max(max.y, otherBlob.max.y);
  }
  float area(){
    return (max.x-min.x)*(max.y-min.y);
  }
  PVector center(){
    return new PVector((min.x+max.x)*.5, (min.y+max.y)*.5);
  }
}
