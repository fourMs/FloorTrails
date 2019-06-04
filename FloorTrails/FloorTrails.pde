/**
 * 
 * FloorTrails by Alexander Refsum Jensenius
 * 
 * Based on: 
 * PixelFlow | Copyright (C) 2016 Thomas Diewald - http://thomasdiewald.com
 * 
 * A Processing/Java library for high performance GPU-Computing (GLSL).
 * MIT License: https://opensource.org/licenses/MIT
 * 
 */


import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.imageprocessing.DwOpticalFlow;
import com.thomasdiewald.pixelflow.java.imageprocessing.filter.DwFilter;

import processing.core.*;
import processing.opengl.PGraphics2D;
import processing.video.Capture;


  // Example, Optical Flow for Webcam capture.
  
  DwPixelFlow context;
  
  DwOpticalFlow opticalflow;
  
  PGraphics2D pg_cam;
  PGraphics2D pg_oflow;
  
  int cam_w = 640;
  int cam_h = 480;
  
  int view_w = 1024;
  int view_h = (int)(view_w * cam_h/(float)cam_w);
  
  Capture cam;

  // some state variables for the GUI/display
  int     BACKGROUND_COLOR  = 0;
  boolean DISPLAY_SOURCE   = false;
  boolean APPLY_GRAYSCALE = false;
  boolean APPLY_BILATERAL = true;
  int     VELOCITY_LINES  = 6;

//  public void settings() {
//    size(view_w, view_h, P2D);
//    smooth(4);
//  }

  public void setup() {
   fullScreen(P2D);
   background(0);
   noStroke();
   fill(102);

    // main library context
    context = new DwPixelFlow(this);
    context.print();
    context.printGL();
    
    // optical flow
    opticalflow = new DwOpticalFlow(context, cam_w, cam_h);

    // some flow parameters
    opticalflow.param.blur_input         = 5;
    opticalflow.param.blur_flow          = 15;
    opticalflow.param.flow_scale         = 90;
    opticalflow.param.temporal_smoothing = 0.95f;
    opticalflow.param.threshold          = 0.4f;
    //opticalflow.param.display_mode       = 0;
    // opticalflow.param.grayscale          = true;

    
    // webcam capture
    String[] cameras = Capture.list();
    printArray(cameras);
    // Need to set the right camera here!
    cam = new Capture(this, cam_w, cam_h, "Logitech Camera #2", 30);
    cam.start();
    
    pg_cam = (PGraphics2D) createGraphics(cam_w, cam_h, P2D);
    pg_cam.smooth(0);
    
    pg_oflow = (PGraphics2D) createGraphics(width, height, P2D);
    pg_oflow.smooth(4);
        
    background(0);
    frameRate(60);
  }
  

  public void draw() {
    
    if( cam.available() ){
      cam.read();
      
      // render to offscreenbuffer
      pg_cam.beginDraw();
      pg_cam.image(cam, 0, 0);
//      scale(-1,1);//flip on X axis
      pg_cam.endDraw();

      // update Optical Flow
      opticalflow.update(pg_cam); 
    }
    
    // rgba -> luminance (just for display)
//    DwFilter.get(context).luminance.apply(pg_cam, pg_cam);
    
    // render Optical Flow
    pg_oflow.beginDraw();
    pg_oflow.clear();
//    pg_oflow.image(pg_cam, 0, 0, width, height);
    pg_oflow.endDraw();
    
    // flow visualizations
    opticalflow.param.display_mode = 0;
//    opticalflow.renderVelocityShading(pg_oflow);
    opticalflow.renderVelocityStreams(pg_oflow, VELOCITY_LINES);
    
    // display result
    background(0);
    image(pg_oflow, 0, 0);
 
  }
  
  void keyPressed() {
  if (key == '1') {
    opticalflow.param.blur_input         = 5;
    opticalflow.param.blur_flow          = 0;
    opticalflow.param.flow_scale         = 0;
    opticalflow.param.temporal_smoothing = 0;
    opticalflow.param.threshold          = 0.9f;
} else if (key == '2') {
    opticalflow.param.blur_input         = 5;
    opticalflow.param.blur_flow          = 15;
    opticalflow.param.flow_scale         = 90;
    opticalflow.param.temporal_smoothing = 0.95f;
    opticalflow.param.threshold          = 0.4f;
} else if (key == '3') {
    opticalflow.param.blur_input         = 5;
    opticalflow.param.blur_flow          = 15;
    opticalflow.param.flow_scale         = 50;
    opticalflow.param.temporal_smoothing = 0.2f;
    opticalflow.param.threshold          = 0.2f;
  }
}
