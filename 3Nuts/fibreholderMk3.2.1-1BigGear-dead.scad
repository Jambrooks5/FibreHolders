use <./NutMaker.scad>
use <../UsefullBits/gearbox.scad>
use <../UsefullBits/utilities.scad>
use <../UsefullBits/hex-aperture.scad>

//translate([0,0,-25]) import ("../openscad/sample_riser_LS10 (1).stl");
//import ("../UsefullBits/28BYJ-48 stepper motor.STL");

//  PARAMETERS
cubeSize = 20;
cubeHeight = 10;

legLength = 30;
legDiam = 2.8;
armLength = 20;
//effective finger length will be fingerLength-legDiam
fingerLength = 10;
//how much smaller the hole spacing in the fixed plate is compared
//to the nut spacing - smaller number, tighter grab
fixedPlateScale = 1;

//radius of the mounting holes on the sample riser
mountRad = 24.5;

//depth and width of dovetails locking cubes
doveDepth = 3;
doveWidth = 3;

//Width of mounting plate
squareSize = 45;
//Thickness of mounting plate
squareThickness = 4;
//Thickness of standoffs to help cubes slide
standoffThickness = 2;

//L section bolt cutout diameter
m3Cutout = 3.2;

t6=tan(60);

//The distance from the center of the aperture
//to the face of each  cube
apart = 0;

//Positions of mounting holes on the microscope stage
mountPoints = [[17.3,17.3,0],[17.3,-17.3,0],[-17.3,-17.3,0],[-17.3,17.3,0]];

cubePos=[[apart-cubeSize/2,apart+cubeSize/2,0],
    [apart+cubeSize/2,-apart+cubeSize/2,0],
    [-apart+cubeSize/2,-apart-cubeSize/2,0],
    [-apart-cubeSize/2,apart+-cubeSize/2,0]];


//creating the fibre holding 'cubes'
//Parameters can be changes for CAD visualising or 3D printing
//1st parameter shows the passively sliding cubes
//2nd show the thread driven cubes
//3rd: 0 gives a single cube of each slot number, 1 gives a pair
//e.g. true, false, 0 -> a single, 1 slot cube
//difference(){
    //rotate([0,0,90]) cubes(false, true, 0);
    //translate([-25,-25,0]) cube([50,50,10]);
//}


//Main body of the square moving mechanism
//color("lightGreen") mechBody();

//Shows bolts used to move cubes for visualisation
threadLengths = [30,40];
//movingBolts([40,40]);
gears([1,1,1,1]);
//translate([0,0,-1]) gearFrame();

module gearFrame($fn=50){
    difference(){
        union(){
            //Main L section
            translate([-threadLengths[0]-14,-threadLengths[0]-14,-10])
                rotate([0,0,-90])
                    lSection(80,5,90,5,15);
            
            //Flat corner
            translate([-threadLengths[0]-2,-threadLengths[0]-2,-2.5])
                rotate([0,0,-45])
                    cube([28, 5, 15], center=true);
            
            //Left mount to base
        translate([-17.5,40.5,-10])
            rotate([0,0,90])
                lSection(20,5,26.5,5,15);
            
            //Right mount to base
        translate([50,-17.5,-10])
            rotate([0,0,90])
                lSection(26.5,5,29,5,15);
        }
        //cutting off corner of L
        translate([-threadLengths[0]-10,-threadLengths[0]-10,0])
                rotate([0,0,-45])
                    cube([40, 18, 30], center=true);
        
        //Bolt holes from left to right
        //1st
        translate([-threadLengths[1]-2.5,cubeSize/2,0])
            rotate([0,-90,0])
                M3cylinder(10,3);
        //2nd
        translate([-threadLengths[0]-8,-cubeSize/2,0])
            rotate([0,90,0])
                cylinder(d=m3Cutout, h=20, center=true);
        //3rd
        translate([-threadLengths[0], -threadLengths[0],0])
            rotate([0,90,45])
                cylinder(d=m3Cutout, h=20, center=true);
        //4th
        translate([cubeSize/2,-threadLengths[0]-8,0])
            rotate([0,90,90])
                cylinder(d=m3Cutout, h=20, center=true);
        
   
            
    }
}

module gears(selection){
    numTeeth=13;
    //Gears on bolts
    if (selection[0]==1){
        //Left
        translate([-threadLengths[0]-8,cubeSize/2,0])
            rotate([-90,0,-90])
                 ourGear(numTeeth,3,5);
    }
    
    if (selection[1]==1){ 
        //Right
        translate([cubeSize/2,-threadLengths[0]-8,0])
                rotate([-90,180/(numTeeth),0])
        difference(){
            
                        ourGear(36,3,5);
            for (i=[0:6]){
                rotate([0,0,60*i])
                    translate([17,0,1])
                        cylinder(h=10, d=14, center=true);
            }
        }
    }
    
    if (selection[2]==1){
        //Left meshing gear
        translate([-threadLengths[0]-8,-cubeSize/2,0])
            rotate([-90,180/numTeeth,-90])
                    ourGear(numTeeth-1,3,5);
    }
    
    if (selection[3]==1){
        //Corner gear
        cornerShift = 0.91;
        translate([-threadLengths[0]*cornerShift, -threadLengths[0]*cornerShift,0])
            rotate([-90,90,-45])
                linear_extrude(5, scale=0.7, center=true)
                    ourGear(17,3,0);
    }
}

module movingBolts(threadLengths){
    //Positions bolts at the correct position for cubes being fully closed
    //Left, Screwed in when closed
    translate([-threadLengths[1]-2.5,cubeSize/2,0])
        rotate([90,0,-90])
            M3cylinder(threadLengths[1],3);
    //Right, Screwed out when closed
    translate([cubeSize/2,-threadLengths[0]-8,0])
        rotate([90,0,0])
            M3cylinder(threadLengths[0],3);
    
    
   //gears();
   //bigGears(threadLengths);
}

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
    
    }
}


module cubes(sliders=true, driven=true, number=1){
    
    ////2 sliding cubes////
    if (sliders==true){
    for (i=[0:number]){
        translate(cubePos[2*i]) rotate([0,0,180*i])
        color("cyan")
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
            cylinder(d=3.2, h=cubeHeight+1, center=true, $fn=50);
        }
    }}
    
    ///Driven cubes////
    for (i=[0:number]){
    if (driven==true){
        translate(cubePos[2*i+1]) rotate([0,0,-90+180*i])
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
           
            //m3 bolt and nut slot
            translate([0,0,0]) 
                rotate([90+180*i,0,90+90*i])
                    difference(){
                        linearMotionDriverInv(3.2,5.8,2.6);
                        translate([0,0,33])
                            cube([5,5,50], center=true);
                    }

        }   
    }}
}



module slot(diam,length,thickness, $fn=50){
    linear_extrude(thickness)
        hull(){
            circle(d=diam);
            translate([length-diam,0,0])
                circle(d=diam);
        }
}



module boltVisualiser(){
    for (i=[0:2]){
        translate(nutPos[i]+[0,0,1])
            M3cylinder(6);
    }
}


