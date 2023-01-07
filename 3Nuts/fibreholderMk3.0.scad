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
//color ("red") legs(legDiam, cubePos);

    //The plate to be held stationary which acts as
//the pivot point for the legs
//color ("lightGreen") fixedPlate(funnel=false);

    //The plate which when rotated, twists the legs
//color ("orange") twistPlate(gear=false);

//creating the fibre holding 'cubes'
//Parameters can be changes for CAD visualising or 3D printing
//1st parameter shows the single slotted cubes
//2nd shows the double slotted cubes
//3rd: 0 gives a single cube of each slot number, 1 gives a pair
//e.g. true, false, 0 -> a single, 1 slot cube
cubes(true, true, 1);

module cubes(singleSlot=true, doubleSlot=true, number=1){
    //2 slot, 1 finger
    if (doubleSlot==true){
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
    
    //2 finger, 1 slot
    if (singleSlot==true){
    for (i=[0:number]){
        translate(cubePos[2*i+1]*1.5) rotate([0,0,180*i-90])
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

module smallGear(){
    translate([0,38,legLength/2+0.25*legDiam])
        rotate([0,0,360/16]) ourGear(8,5,1.5*legDiam);
}

module motorMount(){
    translate([17.5,armLength+8+8+smallGearOffset,0])
    difference(){
        //Mounting finger
        rotate([0,0,90]) slot(8,30,15);
        //Slot for bolt
        translate([0,0,6]) 
            rotate([0,0,90]) 
                slot(3.2,25,10);
        //Slot for nut
        translate([0,13,10]) #cube([5.8,30,2.6], center=true);
        
    }
    //Leg to join slot to mounting legs
    translate([17.4,29,4]) rotate([0,0,-0.5])
        difference(){
            //leg body
            cube([8,24,8], center=true);
            //cutout to keep mounting hole clear
            translate([0,-12,0])
                cylinder(h=9,d=6,center=true);
        }
}

module fixedPlate(funnel=false, $fn=50){
    difference(){
        //Main cylinder
        cylinder(r=3*nutSize, h=12);
        //Cutout to create circle to help printing on bottom
        cylinder(r=3*nutSize-2,10, center=true);
        //Circle to help legs rotate smoothly on top
        translate([0,0,10]) cylinder(r=3*nutSize-2,10);
        
        //Fibre hole
        translate([0,0,0.25*legLength])
            cylinder(r=1,h=6, center=true);
        //Leg holes
        translate([0,0,5]) legs(legDiam+0.3, nutPos*fixedPlateScale);
    }
    //optional funnel
    if (funnel==true){
        translate([0,0,0.25*legLength+7])
            funnel(6,5,2,5,0.5);
    }
    //attatchement legs to microscope
    for (i=[0:3]){
        rotate([0,0,i*90+45])
            difference(){
                union(){
                    translate([0.6*mountRad,0,7.5])
                        cube([0.8*mountRad,8,5], center=true);
                    translate([1.0*mountRad,0,0])
                        cylinder(d=8,h=10);
                }
                translate([mountRad,0,2])
                    M3cylinder(6,10);   
            }
    }
    
    motorMount();
    mirror([1,0,0]) motorMount();
}

module funnel(straightHeight, coneHeight, inRad, outRad, wallThickness, $fn=50){
    translate([0,0,-0.5*straightHeight])
        difference(){
            cylinder(d=inRad+wallThickness, h=straightHeight, center=true);
            cylinder(d=inRad, h=straightHeight+1, center=true);
        }
    //Cone    
    linear_extrude(coneHeight, scale=outRad/inRad)
        difference(){
            circle(d=inRad+wallThickness);
            circle(d=inRad);
        }
}

module twistPlate(gear=true, $fn=50){
    translate([0,0,legLength/2+legDiam])
        difference(){
            //Main disc
            cylinder(h=legDiam, r=armLength+8, center=true);
            for (i=[0:2]){  
                //Slot cutouts for each leg
                rotate([0,0,i*-120+90])
                    translate([0.8*armLength,0,-legDiam/2-0.1])
                        slot(legDiam+0.2, 0.6*armLength, legDiam+1);
                //radial circles to save plastic 
                rotate([0,0,i*-120+30])
                    translate([1*armLength,0,0])
                        cylinder(h=legDiam+1, r=armLength/3, center=true);
            }
            //center circle cutout
            cylinder(h=legDiam+1, r=armLength/2, center=true);    
        }
        //Circular ridge to help sliding against legs
        translate([0,0,legLength/2+legDiam/2])
        difference(){
            cylinder(r=armLength/2+2,h=2, center=true);
            cylinder(r=armLength/2, h=2.1, center=true);
        }
        
        //puts teeth on main disc if motor control desired
        if (gear==true){
            translate([0,0,legLength/2+legDiam/2])
                ourGear(40,2*(armLength+3*legDiam)-1,legDiam);
            smallGear();
        }
}

module legs(legDiam, nutPos, $fn=50){
    for (i=[0:2]){
        translate(nutPos[i]+[0,0,legLength])
        rotate([0,0,i*-120+90])
            union(){
                //cylinder legs
                cylinder(d=legDiam, h=legLength, center=true);
                //cuboid arms
                translate([armLength/2,0,legLength/2-legDiam/2])
                    cube([armLength,legDiam,legDiam], center=true);
                //finger at end of arm
                translate([armLength-legDiam*0.5,0,legLength/2-legDiam])
                    //cylinder(d=legDiam,h=fingerLength, center=true);
                    slot(legDiam,legDiam*1.5,fingerLength);
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