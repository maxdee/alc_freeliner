// cvledcleaner
// clean up automatically mapped fixture files
// zap, 2018
// A!LC

XML xml;
ArrayList<PVector> leds = new ArrayList<PVector>();
ArrayList<PVector> startPoints = new ArrayList<PVector>();
ArrayList<PVector> endPoints = new ArrayList<PVector>();
// set these parameters for optimal result
float slack = 0.3;
float minDistanceRatio = 2.0;
float startStopMultiplier = 1.8;
int lineCounter = 0;

void setup() {
  // set up window
  size(800, 800);
  background(0);
  stroke(255);
  doShabang();
}

void draw() {
  // keep draw() here to continue looping while waiting for keys
}

void keyPressed() {

  if (key == 'w' ) {
    slack = slack + 0.05;
    lineCounter = 0;
    doShabang();
  } else if (key == 'q' ) {
    slack = slack - 0.05;
    lineCounter = 0;
    doShabang();
  }
  if (key == 'r' ) {
    minDistanceRatio = minDistanceRatio + 0.1;
    lineCounter = 0;
    doShabang();
  } else if (key == 'e' ) {
    minDistanceRatio = minDistanceRatio - 0.1;
    lineCounter = 0;
    doShabang();
  } if (key == 'y' ) {
    startStopMultiplier = startStopMultiplier + 0.1;
    lineCounter = 0;
    doShabang();
  } else if (key == 't' ) {
    startStopMultiplier = startStopMultiplier - 0.1;
    lineCounter = 0;
    doShabang();
  } else if (key == 's' ) {
    lineCounter = 0;
    doShabang();
    writeToFile();
  } else if (key == 'o' ) {
    lineCounter = 0;
    doShabang();
  } else {
  }
}
void doShabang () {
  println("===================================================");
  leds.clear();
  startPoints.clear();
  endPoints.clear();
  background(0);
  stroke(0, 255, 255);
  // read xml and write into arraylist
  println("Loading XML...");
  xml = loadXML("haha.xml");
  XML[] children = xml.getChildren("xyled");
  for (int i = 0; i < children.length; i++) {
    float x = children[i].getFloat("x");
    float y = children[i].getFloat("y");
    float a = children[i].getFloat("a");
    leds.add(new PVector(x, y, a));
  }
  println (children.length + " points loaded from XML.");
  println ("Points transfered to ArrayList.");

  // render points
  stroke(150, 150, 150);
  for (int i = 0; i < leds.size(); i++) {
    point(leds.get(i).x, leds.get(i).y );
  }

  // get all distances between points
  println("Calculating all distances...");
  float[] distances = new float[leds.size()];
  for (int i = 0; i < leds.size()-1; i++) {
    PVector led1 = leds.get(i);
    PVector led2 = leds.get(i+1);
    distances[i] = dist(led1.x, led1.y, led2.x, led2.y);
  }
  //println("Distances calculated. Determine median distance...");

  // determine median distance
  distances = sort(distances);
  float medianDistance = distances[distances.length /2];
  println("Median distance is " + medianDistance + " pixels.");

  // increase median distance by slack % to give some room to wiggle
  medianDistance = medianDistance + (medianDistance * slack);
  println ("Adding " + 100 * slack + "% slack to median distance. Is now "+ medianDistance);

  println ("Detecting outliers...");
  // check of there's a pixel missing between two pixels
  ArrayList<Float> outliers = new ArrayList<Float>();
  for (int i = 0; i < leds.size()-2; i++) {
    PVector led1 = leds.get(i);
    PVector led2 = leds.get(i+1);
    PVector led3 = leds.get(i+2);
    //if (dist(led1.x, led1.y, led3.x, led3.y) < medianDistance * 2 && dist(led1.x, led1.y, led3.x, led3.y) > medianDistance * 1.5) {
    if (dist(led1.x, led1.y, led3.x, led3.y) < medianDistance * startStopMultiplier && dist(led1.x, led1.y, led3.x, led3.y) > medianDistance * startStopMultiplier) {
      // assume that both are part of a strip and led 2 should be in between them
      if (dist(led1.x, led1.y, led2.x, led2.y) > medianDistance && dist(led2.x, led2.y, led3.x, led3.y) > medianDistance) {
        // most likely an outlier
        // put led 2 between led 1 and 3
        leds.set(i+1, new PVector((led1.x + led3.x)/2, (led1.y + led3.y)/2, led2.z));
        stroke (255, 255, 0);
        line (led1.x, led1.y, led3.x, led3.y);
        // put address into list of outliers
        outliers.add(new Float(i+1));
        stroke(0, 255, 255);
        point (leds.get(i+1).x, leds.get(i+1).y );
      }
    }
  }
  println(outliers.size() + " outliers detected and fixed.");

  // render points
  //background(0);
  //for (int i = 0; i < leds.size(); i++) {
  //  point(leds.get(i).x, leds.get(i).y );
  //}

  println ("Fitting segments into point clusters...");
  PVector startPoint = new PVector (leds.get(0).x, leds.get(0).y, leds.get(0).z);
  PVector endPoint = new PVector (0, 0, 0);
  lineCounter = 0;
  // fit lines into point clouds
  for (int i = 1; i < leds.size()-2; i++) {
    PVector led1 = leds.get(i);
    PVector led2 = leds.get(i+1);
    PVector led3 = leds.get(i+2);

    // if led1 is far away and led 3 is close: assume that led2 is the starting point
    if (dist(led1.x, led1.y, led2.x, led2.y) > medianDistance && dist(led2.x, led2.y, led3.x, led3.y) < medianDistance) {
      // most likely starting point
      startPoint.x = led2.x;
      startPoint.y = led2.y;
      startPoint.z = led2.z;
      // if led3 is far and led 1 is close: assume that led2 is an end point
    } else if (dist(led1.x, led1.y, led2.x, led2.y) < medianDistance && dist(led2.x, led2.y, led3.x, led3.y) > medianDistance) {
      endPoint.x = led2.x;
      endPoint.y = led2.y;
      endPoint.z = led2.z;
    }
    // we have a finished line
    if (startPoint.x > 0 && endPoint.x > 0) {
      // check if line is reasonably long
      if (dist(startPoint.x, startPoint.y, endPoint.x, endPoint.y) > minDistanceRatio * medianDistance) {
        lineCounter ++;
        stroke(255, 0, 0);
        line (startPoint.x, startPoint.y, endPoint.x, endPoint.y);
        // add points to lists
        startPoints.add(new PVector(startPoint.x, startPoint.y, startPoint.z));
        endPoints.add(new PVector(endPoint.x, endPoint.y, endPoint.z));
      }
      // reset points
      startPoint.x = 0;
      startPoint.y = 0;
      startPoint.z = 0;
      endPoint.x = 0;
      endPoint.y = 0;
      endPoint.z = 0;
    }
  }
  println(lineCounter + " Segments created.");
  println("Parameters: slack = "+slack+", minDistanceRatio = "+minDistanceRatio + ", startStopMultiplier = "+ startStopMultiplier );
  lineCounter = 0;
}

public void writeToFile() {
  // write geometry
  println ("Saving segments in geometry file...");
  saveGroups("geometry.xml");
  println ("File written, terminating...");
}

public void saveGroups(String _fn) {
  XML groupData = new XML("groups");

  groupData.setInt("width", width);
  groupData.setInt("height", height);

  //if (grp.isEmpty()) continue;
  XML xgroup = groupData.addChild("group");
  xgroup.setInt("ID", 2);
  xgroup.setString("text", "Hi, I'm an auto-mapped geometry!");


  xgroup.setString("type", "map");

  //xgroup.setFloat("centerX", xml.grp.getCenter().x);
  //xgroup.setFloat("centerY", grp.getCenter().y);
  //xgroup.setInt("centered", int(grp.isCentered()));
  xgroup.setString("tags", "A");
  for (int i = 0; i < startPoints.size(); i++) {

    XML xseg = xgroup.addChild("segment");
    xseg.setFloat("aX", startPoints.get(i).x);
    xseg.setFloat("aY", startPoints.get(i).y);
    xseg.setFloat("bX", endPoints.get(i).x);
    xseg.setFloat("bY", endPoints.get(i).y);
    // for leds and such
    xseg.setString("txt", "/led " + int(startPoints.get(i).z/3-1) + " " + int(endPoints.get(i).z/3-1));
  }
  // saveXML(groupData, dataDirectory(_fn));
}
