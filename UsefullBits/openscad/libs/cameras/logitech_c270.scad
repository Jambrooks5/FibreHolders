/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Logitech C270 screw-on-from-bottm mount *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* This file defines a camera mount (together with functions that  *
* return the mount height and sensor position) for the Logitech   *
* C270 webcam.                                                    *
*                                                                 *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/


use <../utilities.scad>
use <../libdict.scad>

$fn=48;

function c270_camera_dict() = [["mount_height", 4.5],
                               ["sensor_height", 0.2]];//Height of the sensor above the PCB


module mounting_hole(){
    translate_z(-5){
        cylinder(r=0.8*1.2,h=999,$fn=12);
    }
    translate_z(-0.5){
        cylinder(r1=0.8*1.2,h=1,r2=0.8*1.2+1,$fn=12);
    }
}

module C270(beam_r=5, beam_h=6){
    //cut-out to fit logitech C270 webcam
    //optical axis at (0,0)
    //top of PCB at (0,0,0)
    mounting_hole_x = 8.25;
    mirror([0,0,1]){ //parts cut out of the mount are z<0
        //beam clearance
        hull(){
            cube([8,8,6],center=true);
            translate_z(-beam_h){
                cylinder(r=beam_r,h=2*tiny(),center=true);
            }
        }

        //mounting holes
        reflect_x(){
            translate_x(mounting_hole_x){
                mounting_hole();
            }
        }

        //clearance for PCB
        hull(){
            translate([-10/2,-13.5,0]){
                cube([10,tiny(),8]);
                }
            translate([-21.5/2,-4,0]){
                cube([21.5,41,8]);
                }
            translate([-10/2,45,0]){
                cube([10,tiny(),8]);
                }
        }
        reflect_y(){
            hull(){
                translate([-4.5,6,-1.5]){
                    cube([9,7.5,8]);
                }
                translate([-5.5,6,-1.5]){
                    cube([11,6.5,8]);
                }
            }
        }
        difference(){
            hull(){
                translate([0,22.5,0+4]){
                    cube([20.5,28,15],center=true);
                }
                translate([0,34,0+4]){
                    cube([10,9.5*2,15],center=true);
                }
            }
            translate([-5,39.5,-999]){
                mirror([1,0,0]){
                    cube([999,999,999]);
                }
            }
        }
        translate([-6,42.3,0]){
            mounting_hole();
        }


        //exit for cable
        translate([4,20,0]){
            rotate_x(-90){
                cylinder(r=3,h=99);
            }
        }
    }
}

module c270_camera_mount(){
    // A mount for the pi camera v2
    // This should finish at z=0+tiny(), with a surface that can be
    // hull-ed onto the lens assembly.
    h = 58;
    w = 25;

    mount_height = key_lookup("mount_height", c270_camera_dict());
    rotate(-45){
        difference(){
            translate([-w/2, -13, -mount_height]){
                cube([w, h, mount_height]);
            }
            translate_z(-mount_height){
                C270();
            }
        }
    }
}
