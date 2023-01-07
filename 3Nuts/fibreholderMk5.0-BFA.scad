use <../UsefullBits/utilities.scad>

$fn=100;

//radius of the mounting holes on the sample riser
mountRad = 24.5;

//translate([0,0,2]) microscopeSlide();

legs();
//translate([0,-10.9,15]) rotate([-90,0,0]) holder();

mount();
mirror([1,0,0]) mount();

module mount(){   
    difference(){
        union(){
            //square slab
            translate([0,0,1.25])
                cube([38,38,2.5], center=true);
            //slope support
            translate([16,-12.4,0]) rotate([90,0,90])
                rightTriangle(25,25,6);
            //rear supports
            translate([5,-19,0])
                cube([8,6,10]);
        }
		//flaten top of sloping supports
		translate([0,0,25])
			cube([40,40,10], center=true);
        //fibre holder plate coutout
        translate([0,-10.9,15]) rotate([-90,0,0]) holder();
        //mounting leg coutouts
        for (i=[0:3]){
            rotate([0,0,i*90+45])
                translate([mountRad,0,2])
                    M3cylinder(6,10); 
            }
        //center circle
        cylinder(h=10, d=20, center=true);
        //rear grub screw hole
        translate([9,-12,6]) rotate([90,0,0])
            cylinder(d=2.8, h=10);
            
        //microscope slide cutout
        translate([-11.25,-11.25,1.5])
            cube([22.5,50,2]);
    }
}

//Based on a Thorlabs HFB004
module holder(){
    difference(){
        union(){
            //main base
            cube([32,25,3.2], center=true);
            //keyway
            translate([0,0,-2.3])
                cube([2.2,25,1.4], center=true);
            //vertical plate
            translate([0,12.5,10.9]) rotate([90,0,0])
                cylinder(h=2.5, r=7.2);
            translate([-7.2,10,0])
                cube([14.4,2.5,11]);
            //thread cylinder
            translate([0,10.5,10.9]) rotate([90,0,0])
                cylinder(d=8, h=4.5);
        }
        //fibre hole
        translate([0,15,10.9]) rotate([90,0,0])
            cylinder(d=1.3, h=20);
        //thread hole
        translate([0,10,10.9]) rotate([90,0,0])
            cylinder(d=6, h=20);
    }
}

//attatchement legs to microscope
module legs(){
    for (i=[0:3]){
        rotate([0,0,i*90+45])
            difference(){
                union(){
                    //translate([0.6*mountRad,0,7.5])
                        //cube([0.8*mountRad,8,5], center=true);
                    translate([1.0*mountRad,0,0])
                        cylinder(d=8,h=2.5);
                }
                translate([mountRad,0,2])
                    M3cylinder(6,10);   
            }
    }
}

module microscopeSlide(thickness=0.87/5, tolerance=0.1){
	cube([22+tolerance,22+tolerance,thickness], center=true);
}