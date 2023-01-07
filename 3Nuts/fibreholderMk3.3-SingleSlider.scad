use <./NutMaker.scad>
use <../UsefullBits/gearbox.scad>
use <../UsefullBits/utilities.scad>
use <../UsefullBits/hex-aperture.scad>


////Importing microscope riser and stepper motor for scaling

//translate([0,0,-25]) import ("../openscad/sample_riser_LS10 (1).stl");
//import ("../UsefullBits/28BYJ-48 stepper motor.STL");

////  PARAMETERS   ////

//The footprint size and height of the 'cubes' that hold the fibre
cubeSize = 20;
cubeHeight = 10;

//Cube seperation for visualisation - distance from the center of the aperture to the face of each  cube
apart = 0;

//Positions of cubes for a given size and seperation
cubePos=[[apart-cubeSize/2,apart+cubeSize/2,0],
    [apart+cubeSize/2,-apart+cubeSize/2,0],
    [-apart+cubeSize/2,-apart-cubeSize/2,0],
    [-cubeSize/2,-cubeSize/2,0]];


//Radius of the mounting holes on the sample riser
mountRad = 24.5;

//Positions of mounting holes on the microscope stage
mountPoints = [[17.3,17.3,0],[17.3,-17.3,0],[-17.3,-17.3,0],[-17.3,17.3,0]];

//Depth and width of dovetails on the holding cubes
doveDepth = 3;
doveWidth = 3;

//Width of mounting plate holding cube mechanism to microscope
squareSize = 45;
//Thickness of mounting plate
squareThickness = 4;
//Thickness of standoffs to help cubes slide
standoffThickness = 2;

//Bolt cutout diameter for M3 bolts that need to rotate/slide
m3Cutout = 3.2;

//Seperation of gears beyond perfect meshing to 
//give a bit of room for printing oversized
gearTol = 0.2;
//Number of teeth on gears that directly move the cubes
numTeeth = 13;
//Diameter of these gears - 5 is the tooth spacing used - set in "gearbox.scad"
gearDiam = numTeeth*5/PI;

//Sets length of threads on the bolts used to drive cubes
threadLengths = [40,40];

////The following section calls the functions for the design

//Creating the fibre holding 'cubes'
//Parameters can be changes for CAD visualising or 3D printing
//1st parameter shows the passively sliding cubes
//2nd is number of sliding cube: '0' for one cube, '1' for two
//Sliding cubes are the same as each other
//3rd shows the thread driven cubes
//4th selects which driven cube to show, e.g. [0,0] only shows the first, [0,1] shows both, [1,1] shows only 2nd 
//Driven cubes NOT the same as each other - DON'T print 2 of the same STL
//difference() used to see cross-section of cubes - comment out 1,3,4 of following lines to see full cubes
//difference(){
    cubes(true, true, false, 1);
  //  translate([-25,-25,0]) cube([50,50,10]);
//}


//Main body of the square moving mechanism which mounts to the microscope
mechBody();

movingBolts();

module cubes(fixed=true, driven=true, passive=true, number=1){
    //Fixed corner cube
    if (fixed==true){
        translate(cubePos[3]) rotate([0,0,90])
        difference(){
            union(){
                cube([cubeSize, cubeSize, cubeHeight], center=true);
                translate([cubeSize/2+doveDepth/2,0,0])
                    rotate([90,-90,0])
                        isoTriangle(doveDepth,doveWidth,cubeSize);
            }
            translate([0,-cubeSize/2+doveDepth/2,0.25*cubeHeight])
                    rotate([90,-90,90])
                        isoTriangle(doveDepth+0.7,doveWidth+0.3,cubeSize+0.01); 
           translate([0,-cubeSize/2+doveDepth/2,-0.25*cubeHeight])
                    rotate([90,-90,90])
                        isoTriangle(doveDepth+0.7,doveWidth+0.3,cubeSize+0.01);  
            
            //m3 center hole
            cylinder(d=2.9, h=cubeHeight+1, center=true, $fn=50);
        }
    }
    
    //Cube to be driven by bolt
    if (driven==true){
        translate(cubePos[1]) rotate([0,0,-90])
        difference(){
            union(){
                cube([cubeSize, cubeSize, cubeHeight], center=true);
                translate([cubeSize/2+doveDepth/2,0,0])
                    rotate([90,-90,0])
                        isoTriangle(doveDepth,doveWidth,cubeSize);
            }
            translate([0,-cubeSize/2+doveDepth/2,0.25*cubeHeight])
                    rotate([90,-90,90])
                        isoTriangle(doveDepth+0.7,doveWidth+0.3,cubeSize+0.01); 
           translate([0,-cubeSize/2+doveDepth/2,-0.25*cubeHeight])
                    rotate([90,-90,90])
                        isoTriangle(doveDepth+0.7,doveWidth+0.3,cubeSize+0.01);  
            
            //m3 center hole
            cylinder(d=2.9, h=cubeHeight+1, center=true, $fn=50);
        }
    }
    
    //Passive sliders
    if (passive==true){
    for (i=[0:number]){
        translate(cubePos[2*i]) rotate([0,0,180*i])
        difference(){
            union(){
                cube([cubeSize, cubeSize, cubeHeight], center=true);
                translate([cubeSize/2+doveDepth/2,0,0.25*cubeHeight])
                    rotate([90,-90,0])
                        isoTriangle(doveDepth,doveWidth,cubeSize);
                translate([cubeSize/2+doveDepth/2,0,-0.25*cubeHeight])
                    rotate([90,-90,0])
                        isoTriangle(doveDepth,doveWidth,cubeSize);
            }
            translate([0,-cubeSize/2+doveDepth/2,0])
                    rotate([90,-90,90])
                        isoTriangle(doveDepth+0.7,doveWidth+0.3,cubeSize+0.01); 
           
            //m3 center hole
            cylinder(d=2.9, h=cubeHeight+1, center=true, $fn=50);
        }
    }}
}

module movingBolts(){
    //Positions bolts at the correct position for cubes being fully closed

    //Right, Screwed out when closed
    translate([cubeSize/2,threadLengths[0]-8,0])
        rotate([90,0,45])
            M3cylinder(threadLengths[0],3);
    
}



//Main body which attaches to microscope, also holds the cubes and the gear frame
module mechBody(){
    difference(){
        union(){
            //Main flat square
            translate([0,0,-cubeHeight/2-squareThickness/2-standoffThickness])
                cube([squareSize,squareSize,squareThickness], center=true);
            //Slides to help moving squares stay level
            //Long flat
            translate([squareSize/2,squareSize/2,-cubeHeight/2-standoffThickness])
                rotate([90,0,0])
                    lSection(10,2,2,2,squareSize);
            //Single L length
            translate([-squareSize/2,squareSize/2,-cubeHeight/2-standoffThickness])
                rotate([90,0,90])
                    lSection(10,2,15,2,squareSize/2-2);
            //Corner walls to stop fixed sqaure rotating
            translate([-squareSize/2,-squareSize/2,-cubeHeight/2-standoffThickness])
                rotate([90,0,180])
                    lSection(20.5,2,10,2.5,squareSize/2-2);
            translate([-2,-squareSize/2,-cubeHeight/2-standoffThickness])
                rotate([90,0,-90])
                    lSection(2.5,2,10,2.5,squareSize/2-2);
          
        }
    //Mounting bolt holes
    for (i=[0:3]){
        translate(mountPoints[i]+[0,0,-cubeHeight+squareThickness/4])
            M3cylinder(10,5);
    }
    
    //Hole for fixing the stationary cube
    translate([-cubeSize/2, -cubeSize/2, -5])
        cylinder(d=2.8, h=20, center=true, $fn=50);
    
    //Center hole for fibre/microscope objective
    translate([0,0,-cubeHeight/2-squareThickness])
        cylinder(d=20,h=3*squareThickness, center=true);
    
    //Left hole for end of gear holding bolt
        translate([-threadLengths[0]+11,cubeSize/2-gearDiam-gearTol,0])
            rotate([0,90,0])
                cylinder(d=m3Cutout, h=20, center=true, $fn=50);
    
    //Right hole for end of gear holding bolt
        translate([cubeSize/2-gearDiam-gearTol,-threadLengths[0]+11,0])
            rotate([0,90,90])
                cylinder(d=m3Cutout, h=20, center=true, $fn=50);
    
    }
      
        //Gear Frame left mount
    translate([-17.5,40.5,-11])
       rotate([0,0,90])
            difference(){
                lSection(20,5,35,5,15);
                translate([-10,10,7.5])        
                    rotate([90,0,90])
                        slot(3.4, 23, 20);
            }
        
        //Gear Frame right mount
    translate([50,-17.5,-11])
        rotate([0,0,90])
            difference(){
                lSection(35,5,29,5,15);
                translate([-30,10,7.5])        
                    rotate([90,0,0])
                        slot(3.4, 23, 20);
            }
}






