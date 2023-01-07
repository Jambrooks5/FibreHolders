use <./NutMaker.scad>
use <../UsefullBits/gearbox.scad>
use <../UsefullBits/utilities.scad>
use <../UsefullBits/hex-aperture.scad>

//translate([0,0,-15]) import ("../openscad/sample_riser_LS10 (1).stl");
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

//How far out to move motor mount because of small gear radius
smallGearOffset = 5;
//ratio between small and large gear
gearRatio = 5;

//depth and width of dovetails locking cubes
doveDepth = 3;
doveWidth = 3;

t6=tan(60);

cubePos=[[-cubeSize/6,cubeSize/2,0],
    [cubeSize/2,cubeSize/6,0],
    [cubeSize/6,-cubeSize/2,0],
    [-cubeSize/2,-cubeSize/6,0]];

    //Show where nuts of that size would be, and the
//bolts that would fit them
//nutVisualiser();
//boltVisualiser();

    //Main rotating legs
color ("red") legs(legDiam, cubePos);

    //The plate to be held stationary which acts as
//the pivot point for the legs
color ("lightGreen") fixedPlate(funnel=false);

    //The plate which when rotated, twists the legs
color ("orange") twistPlate(gear=false);

//creating the fibre holding 'cubes'
//Parameters can be changes for CAD visualising or 3D printing
//1st parameter shows the single slotted cubes
//2nd shows the double slotted cubes
//3rd: 0 gives a single cube of each slot number, 1 gives a pair
//e.g. true, false, 0 -> a single, 1 slot cube
cubes(true, true, true, 1);

module cubes(sliders=true, nutAndBolt=true, fixed=true, number=1){
    
    ////2 sliding cubes////
    if (sliders==true){
    for (i=[0:number]){
        translate(cubePos[2*i]*1.5) rotate([0,0,180*i])
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
    }}
    
    ///Bolt and nut cutout cube////
    if (nutAndBolt==true){
        translate(cubePos[1]*1.5) rotate([0,0,-90])
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
            translate([cubeSize/8,cubeSize/3,0]) 
                rotate([90,0,135])
                    linearMotionDriverInv(3.2,5.8,2.6);
            translate([-cubeSize/3,-cubeSize/8,0]) 
                rotate([90,0,135])
                    linearMotionDriverInv(3.2,5.8,2.6);
        }   
    }
    ////Fixed position cube////  
    if (fixed==true){
        translate(cubePos[3]*1.5) rotate([0,0,90])
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
        }
    }
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

module M3cylinder(threadLength, headLength, $fn=50){
    union(){
        translate([0,0,-threadLength+0.01])
        cylinder(d=3, h=threadLength);
        
        cylinder(d=5.5, h=headLength);
    }
}