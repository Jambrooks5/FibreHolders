use <./NutMaker.scad>
use <../UsefullBits/gearbox.scad>
use <../UsefullBits/utilities.scad>
use <../UsefullBits/hex-aperture.scad>
use <../UsefullBits/openscad/libs/utilities.scad>


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
    [-apart-cubeSize/2,apart+-cubeSize/2,0]];


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
numTeeth = 21;
//Diameter of these gears - 5 is the tooth spacing used - set in "gearbox.scad"
gearDiam = numTeeth*5/PI;

intNumTeeth=13;
intGearDiam = intNumTeeth*5/PI;

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
difference(){
    rotate([0,0,90]) cubes(true, [0,1], true, [0,1]);
    //translate([-25,-25,0]) cube([50,50,10]);
}


//Main body of the square moving mechanism which mounts to the microscope
mechBody();


//Shows bolts used to move cubes for visualisation
movingBolts();

//Sets which gears to render:
//1st is the gears attached to the driving bolts
//2nd intermediate meshing gears
//3rd corner meshing gear
gearSelection = [1,1];
//gears();

//The large frame which holds the gears in place
//color("lightGreen")
//gearFrame();

//Small adjustable post to hole the end of a rubber band to one corner of the main body
//bandPost();

//Post to stop right bolt from pulling back when unscrewing from cube
rightBoltRearStop();

module rightBoltRearStop(){
    translate([0,-50,-11])
        difference(){
            union(){
                //Main block
                cube([45,5,15]);
                translate([45,2.5,7.5])
                    rotate([0,0,90])
                        isoTriangle(10,10,15);
            }
            //Cylinder cutout for bolt to thread into
            translate([15.1,2.5,7.5])
                rotate([0,90,0])
                    cylinder(h=30,d=2.8, $fn=50);
        }
}

module bandPost($fn=50){
    length=40;
    difference(){
        slot(8,length,3);
        translate([0,0,-0.1])
            slot(3.2,length-8,3.2);
    }
    translate([length-8,0,0])
        cylinder(h=10,d=8);
}

//Corner extention to the gear holding fram

//Frame for holding gears
module gearFrame($fn=50){
    difference(){
        union(){
            //Main L section
            translate([-threadLengths[0]+7,-threadLengths[0]+7,-4])
                rotate([0,0,-90]) 
                    lSection(59.5,5,69,5,8);
            
            //Corner flat section
            translate([-threadLengths[0]+11,-threadLengths[0]+11,0])
                rotate([0,0,45])
                    cube([10, 10, 8], center=true);
            
            //Left end mounting chunk
            translate([-threadLengths[0]+5,threadLengths[0]-14.5,-11])
                cube([10,10,15]);
            //Right end mounting chunk
            translate([threadLengths[0]-10,-threadLengths[0]+4,-11])
                cube([15,10,15]);

        }
        //cutting off corner of L
        translate([-threadLengths[0]+4,-threadLengths[0]+4,0])
                rotate([0,0,45])
                    cube([20, 20, 30], center=true);
        
        //Bolt holes from left to right
        //1st
        translate([-threadLengths[1]-2.5,cubeSize/2,0])
            rotate([0,-90,0])
                cylinder(d=m3Cutout, h=20, center=true);
        //2nd
        translate([-threadLengths[0]-8,cubeSize/2-gearDiam/2-intGearDiam/2-gearTol,0])
            rotate([0,90,0])
        //-0.3 because these bolts are meant to thread into frame
                cylinder(d=m3Cutout-0.3, h=50, center=true);
        //3rd
        translate([cubeSize/2-gearDiam/2-intGearDiam/2-gearTol,-threadLengths[0]-8,0])
            rotate([0,90,90])
                cylinder(d=m3Cutout-0.3, h=50, center=true);
        //4th
        translate([cubeSize/2,-threadLengths[0]-8,0])
            rotate([0,90,90])
                cylinder(d=m3Cutout, h=20, center=true);
        
        //Left mounting bolt hole - a nut trap
        translate([-threadLengths[0]+10,30,-3.5])
            rotate([90,-90,180])
                difference(){
                    hexTrapInv(3.2,5.8,2.6);
                    //Cube to stop bolt cutout passing through whole frame
                    translate([-2,-2,-103.5])
                        cube([5,5,100]);
            
        }
        //Right mounting bolt hole
        translate([39,-threadLengths[0]+9.0,-3.5])
            rotate([90,-90,90])
                difference(){
                    hexTrapInv(3.2,5.8,2.6);   
                    //Cube to stop bolt cutout passing through whole frame
                    translate([-2,-2,-103.5])
                        cube([5,5,100]);
                }
    }
}




//Contains the driving and intermediate gears, which are called twice in 'gears()', once reflected
module gearPairs(){
    //numTeeth=17;
    //the meshing diameter of the gear is ~the teeth
    //spacing (currently 5mm) * the number of teeth / pi
    gearDiam = numTeeth*5/PI;
    
    //Bolt gear
    if (gearSelection[0]==1){
        translate([-threadLengths[0]-2,cubeSize/2,0])
            rotate([-90,0,-90])
                union(){
                    ourGear(numTeeth,3,5);
                    cylinder(h=0.2,d=gearDiam+5);
                }
    }
            
    //Intermediate gear
    if (gearSelection[1]==1){
        translate([-threadLengths[0]+4,cubeSize/2-gearDiam/2-intGearDiam/2-gearTol,0])
            rotate([-90,180/intNumTeeth,+90])
                difference(){
                    union(){
                        ourGear(intNumTeeth,0,5);
                        translate([0,0,0])
                            rotate([0,180,0])
                            linear_extrude(3,scale=1/((2*3*tan(45)/gearDiam)+1))
                                #ourGear(intNumTeeth+10,0,0, true);
                            
                            //translate([0,0,-3])
                              //  cylinder(h=0.2,d=intGearDiam+30);
                    }
                    cylinder(h=20, d=3.2, center=true, $fn=50);
                }
    }
}



//Calls the above gears, and creates the corner meshing gear
module gears(){
    gearPairs();
    mirror([1,-1,0]) gearPairs();
}


//Shows the bolts which will move the cubes
//NOT to be printed, use proper bolts
module movingBolts(){
    //Positions bolts at the correct position for cubes being fully closed
    //Left, Screwed in when closed
    translate([-threadLengths[1]-2.5,cubeSize/2,0])
        rotate([90,0,-90])
            M3cylinder(threadLengths[1],3);
    //Right, Screwed out when closed
    translate([cubeSize/2,-threadLengths[0]-13,0])
        rotate([90,0,0])
            M3cylinder(threadLengths[0],3);
    
    
   //gears();
   //bigGears(threadLengths);
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
        translate([-threadLengths[0]+11,cubeSize/2-gearDiam/2-intGearDiam/2-gearTol,0])
            rotate([0,90,0])
                cylinder(d=m3Cutout, h=20, center=true, $fn=50);
    
    //Right hole for end of gear holding bolt
        translate([cubeSize/2-gearDiam/2-intGearDiam/2-gearTol,-threadLengths[0]+11,0])
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


//The sliding cubes which form the aperture
module cubes(sliders=true, sliderSelection=[0,1], driven=true, drivenSelection=[0,1]){
    
    ////The fixed and passively sliding cubes - they're identical////
    if (sliders==true){
    for (i=sliderSelection){
        translate(cubePos[2*i]) rotate([0,0,180*i])
        color("cyan")
        difference(){
            union(){
                //Main body
                cube([cubeSize, cubeSize, cubeHeight], center=true);
                //Dovetail finger
                translate([cubeSize/2+doveDepth/2,0,0])
                    rotate([90,-90,0])
                        isoTriangle(doveDepth,doveWidth,cubeSize);
            }
            //2 Dovetail cutouts
            translate([0,-cubeSize/2+doveDepth/2,0.25*cubeHeight])
                    rotate([90,-90,90])
                        isoTriangle(doveDepth+0.7,doveWidth+0.3,cubeSize+0.01); 
            translate([0,-cubeSize/2+doveDepth/2,-0.25*cubeHeight])
                    rotate([90,-90,90])
                        isoTriangle(doveDepth+0.7,doveWidth+0.3,cubeSize+0.01);  
            
            //m3 center hole
            if (i==0){
                cylinder(d=3.2, h=cubeHeight+1, center=true, $fn=50);
            }
            else{
                trylinder_selftap(h=11, center=true, $fn=30);
            }
        }
    }}
    
    ///2 Driven cubes - NOT identical to each other////
    for (i=drivenSelection){
    if (driven==true){
        translate(cubePos[2*i+1]) rotate([0,0,-90+180*i])
        difference(){
            union(){
                //Main body
                cube([cubeSize, cubeSize, cubeHeight], center=true);
                //2 Dovetail fingers
                translate([cubeSize/2+doveDepth/2,0,0.25*cubeHeight])
                    rotate([90,-90,0])
                        isoTriangle(doveDepth,doveWidth,cubeSize);
                translate([cubeSize/2+doveDepth/2,0,-0.25*cubeHeight])
                    rotate([90,-90,0])
                        isoTriangle(doveDepth,doveWidth,cubeSize);
            }
            //Single dovetail cutout
            translate([0,-cubeSize/2+doveDepth/2,0])
                    rotate([90,-90,90])
                        isoTriangle(doveDepth+0.7,doveWidth+0.3,cubeSize+0.01); 
           
            //m3 bolt and nut slot
            translate([0,0,0]) 
                rotate([90+180*i,0,90+90*i])
                    difference(){
            //The +0.4*i is to make the nut slot in one of the driven cubes slightly taller, as the different print orientation causes slight collapsing of the slot
                        translate([0,0,-6])
                            //linearMotionDriverInv(3.2,5.8,2.6+0.4*i);
                            hexTrapInv(3.2,5.8,2.6+0.4*i);
                        translate([0,0,32.5])
                            cube([5,5,50], center=true);
                    }

        }   
    }}
}








