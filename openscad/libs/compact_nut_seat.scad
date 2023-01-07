/*

An attempt at an alternative to my ageing "nut_seat_with_flex" design...

(c) 2016 Richard Bowman - released under CERN Open Hardware License

*/

use <./utilities.scad>
use <./libdict.scad>
use <./microscope_parameters.scad>




/**
* Nominal thread size of the actuator nut
*/
function actuator_nut_size() = 3;

/**
* Radius of hole to cut for actuator screw
*/
function actuator_shaft_radius() = actuator_nut_size()/2 * 1.15;

/**
* Radius of the bottom of the actuator column
* Note that this sets width of the actuator column. However, the column
* itself is stretched into an oval to match the depth of the top cube of
* the column (i.e. where the nut trap is)
*/
function column_base_radius() = actuator_shaft_radius() + 2;

/**
* The dimensions of the actuating lever for the x and y axes
*/
function actuator_dims(params) = let(
    width = column_base_radius()*2
 ) [width, actuating_nut_r(params), 6];

/**
* The dimensions of the but slot in the actuator
*/
function actuator_nut_slot_size() = let(
    //nominal width of the nut (vertex-to-vertex) multiplied by a clearance factor of 10%
    nut_w = 6.3*1.1,
    nut_h = 2.6
) [nut_w*sin(60), nut_w, nut_h+0.4];


//TODO find out where all the magic numbers come from
function column_core_size() = let(
    nut_slot_xy =  zero_z(actuator_nut_slot_size()),
    // Adding extra material to the column. Note, must leave z=0 here
    extra_xy =  2*[1.5+7+1, 1.5+1.5, 0]
) nut_slot_xy + extra_xy;

/**
* Thickness of the actuator housing wall
*/
function actuator_wall_t() = 1.6;

/**
* The xy size of the the actuator housing (outer dimensions)
* Note that this returns a 3-vector with z=0
*/
function actuator_housing_xy_size() = let(
    extra_size_for_walls = [2, 2, 0]*actuator_wall_t()
) column_core_size() + extra_size_for_walls;

function actuator_entry_width() = 2*column_base_radius()+3;

module nut_trap_and_slot(r, slot, squeeze=0.9, trap_h=undef){
    // A cut-out that will hold a nut.  The nut slots in horizontally
    // along the +y axis, and is pulled up and into the tight part of the
    // nut seat when a screw is inserted.
    hole_r = r*1.15/2;
    trap_height = if_undefined_set_default(trap_h, r);
    w = slot.x; //width of the nut entry slot (should be slightly larger than the nut)
    l = slot.y; //length/depth of the slot (now ignored)
    h = slot.z; //height of the slot
    r1 = w/2/cos(30); //bottom of nut trap is large
    r2 = r*squeeze; //top of nut trap is very tight
    sequential_hull(){
        translate([-w/2,999,0]){
            cube([w,tiny(),h]);
        }
        union(){
            translate([-w/2,l/2-tiny(),0]){
                cube([w,tiny(),h]);
            }
            rotate(30){
                cylinder(d=w/sin(60), h=h, $fn=6);
            }
        }
        a = 1/trap_height;
        rotate(30){
            cylinder(r=r1*(1-a) + r2*a, h=h+1, $fn=6);
        }
        rotate(30){
            cylinder(r=r2, h=h+trap_height, $fn=6);
        }
    }
    // ensure the hole in the top can be made nicely
    intersection(){
        translate([-999, -hole_r,0]){
            cube([999, 2*hole_r, h + trap_height + 0.5]);
        }
        rotate(30){
            cylinder(r=r2, h=999, $fn=6);
        }
    }

}


module m3_nut_trap_with_shaft(slot_angle=0,tilt=0)
{
    // Nut trap for an M3 nut with a screw from the top this is a solid
    // Object difference it from your part.
    // Trap starts at z=1mm and ends at 7.5mm
    // We recommend have the outer stucture occupies the space from z = 0-9mm

    rotate_x(tilt){
        rotate_z(slot_angle){
            translate_z(1){
                union(){
                    nut_trap_and_slot(actuator_nut_size(), actuator_nut_slot_size());
                    cylinder(r=actuator_shaft_radius(), h=999, $fn=16);
                }
            }
        }
    }
}

module central_actuator_column(h, top){
    //The central column of the actuator including the square head. The column extends down
    //past the bottom of the base and must be cut
    $fn=16;
    r1 = column_base_radius(); //size of the bottom part
    r2 = sqrt(top.x*top.x+top.y*top.y)/2; //outer radius of top
    sequential_hull(){
        translate_z(-99){
            resize([2*r1, top.y, tiny()]){
                cylinder(r=r1, h=tiny());
            }
        }
        translate_z(h-top.z - 2*(r2-r1)){
            resize([2*r1, top.y, tiny()]){
                cylinder(r=r1, h=tiny());
            }
        }
        translate_z(h-top.z/2){
            cube(top, center=true);
        }
    }
}

module actuator_hooks(h,top){
    //These are the hooks on the actuator
    //Reflect to get two hooks
    reflect_x(){
        //Translate to the correct postion on the actuator
        translate([top.x/2,0,h]){
            //Mirror as build upside down
            mirror([0,0,1]){
                // The hook is the sequantiall hull of:
                sequential_hull(){
                    //A thin cube on the side wall of the block
                    translate([-tiny(),-top.y/2,0]){
                        cube([tiny(),top.y,top.z]);
                    }
                    //A thin cylinder inside the block so the nex section is thin
                    translate_z(0.5){
                        scale([0.5 ,1, 1]){
                            cylinder(d=4.5, h=top.z-2);
                        }
                    }
                    //A compressed truncated cone just outside the block
                    translate([1.5,0,0.5]){
                        resize([3,4,3.5]){
                            cylinder(d1=1, d2=4, h=4);
                        }
                    }
                    //Another compressed truncated cone just under where the
                    //hook rises
                    translate([3.5,0,0.5]){
                        resize([2.5,3.0,1.5]){
                            cylinder(d1=1,d2=3.5);
                        }
                    }
                    // A tri-lobular shape for the top of the hook formed from the union
                    // of three cylinders.
                    union(){
                        reflect_y(){
                            translate([4.5,0.5,0]){
                                cylinder(d=1,h=1);
                            }
                        }
                        translate_x(4){
                            cylinder(d=1,h=1);
                        }
                    }
                }
            }
        }
    }
}

module actuator_ties(tilt=0, lever_tip=3){
    // The ties for the actuator.
    rotate_x(tilt){
        translate_z(lever_tip+flex_dims().z+3){
            cube([actuator_housing_xy_size().x-actuator_wall_t(), 1, 0.5], center=true);
        }
    }
}

module actuator_column(h, tilt=0, lever_tip=3, flip_nut_slot=false, join_to_casing=true, no_voids=false){
    // An "actuator column", a nearly-vertical tower, with a nut trap and hooks
    // for elastic bands at the top, usually attached to a flexure at the bottom.
    // There's often one of these inside the casing under an adjustment screw/gear
    //h: the height of the column
    //tilt: the column is rotated about the x axis
    //lever_tip: height of the actuating lever at its end (can taper up at 45 degrees)
    //flip_nut_slot: if set to true, the nut is inserted from -y
    //join_to_casing: if set to true, the column is joined to the casing by thin threads
    //no_voids: don't leave a void for the nut or screw, used for the drilling jig.

    top = actuator_nut_slot_size() + [3,3,actuator_nut_size() + 1.5]; //size of the top part
    slot_angle = flip_nut_slot ? 180 : 0; //enter from -y if needed
    $fn=16;
    difference(){
        union(){
            rotate_x(tilt){
                central_actuator_column(h, top);
                // hooks for elastic bands/springs
                actuator_hooks(h, top);
            }
            // join the column to the casing, for strength during printing
            // This module does the tilt itself so it can be rendered separately
            // for instructions
            if(join_to_casing){
                actuator_ties(tilt, lever_tip);
            }
        }

        // nut trap
        if(!no_voids){
            rotate_x(tilt){
                rotate(slot_angle){
                    translate_z(h-top.z){
                        nut_trap_and_slot(actuator_nut_size(), actuator_nut_slot_size());
                    }
                }
            }
        }

        // shaft for the screw
        // NB this is raised up from the bottom so it stays within the shaft - this may need to change depending on the length of screw we use...
        if(!no_voids){
            rotate_x(tilt){
                translate_z(lever_tip){
                    cylinder(r=actuator_shaft_radius(), h=999);
                    translate_z(-lever_tip+1){
                        //pointy bottom (stronger)
                        cylinder(r1=0, r2=actuator_shaft_radius(), h=lever_tip-1);
                    }
                }
            }
        }

        // space for lever and flexure
        translate([-99, -flex_dims().y/2, flex_dims().z]){
            sequential_hull(){
                cube([999,flex_dims().y,lever_tip]);
                translate([0,-999,999]){
                    cube([999,flex_dims().y,lever_tip]);
                }
            }
        }

        // tiny holes, to increase the perimeter of the bottom bit and make it
        // stronger
        translate([-tiny(),0,flex_dims().z]){
            cube([2*tiny(), 10, 4]);
        }
        // cut off at the bottom
        mirror([0,0,1]){
            cylinder(r=999,h=999,$fn=4);
        }
    }
}


module actuator_end_cutout(lever_tip=3-0.5 ){
    // This shape cuts off the end of an actuator, leaving a thin strip to
    // connect to the actuator column (the flexure).
    sequential_hull(){
        translate([-999,-flex_dims().y/2,flex_dims().z]){
            cube([2,2,2]*999);
        }
        translate([-999,-flex_dims().y/2,flex_dims().z+lever_tip]){
            cube([2,2,2]*999);
        }
        translate([-999,-flex_dims().y/2-999,flex_dims().z+999]){
            cube([2,2,2]*999);
        }
    }
}

module nut_seat_silhouette(offset=0){
    // a (2D) shape made from the convex hull of two circles od radius r
    // we don't actually build it like that though, as the hull is a slow operation.
    r=actuator_housing_xy_size().y/2;
    dx=actuator_housing_xy_size().x-actuator_housing_xy_size().y;
    union(){
        reflect([1,0]){
            translate([dx/2,0]){
                circle(r=r+offset);
            }
        }
        square([dx,2*(r+offset)], center=true);
    }
}

module nut_seat_void(h=1, tilt=0, center=true){
    // Inside of the actuator column housing (should be subtracted
    // h is the height of the top (excluding nut hole)
    // center=true will cause it to punch through the bottom.
    // This ensures enough clearance to let the actuator column move.
    rotate_x(tilt){
        intersection(){
            linear_extrude(999,center=center){
                nut_seat_silhouette(offset=-actuator_wall_t());
            }
            translate_z(h){
                rotate(90){
                    hole_from_bottom(actuator_nut_size()*1.1/2, h=999, base_w=999);
                }
            }
        }
    }
}

module screw_seat_shell(h=1, tilt=0){
    // Outside of the actuator column housing - this is the structure that
    // the gear sits on top of.  It needs to be hollowed out before use
    // (see screw_seat)
    // Create a slightly over double height column and cut off bottom
    double_h = (h+2)*2;
    difference(){
        rotate_x(tilt){
            hull(){
                linear_extrude(double_h-3, center=true){
                    nut_seat_silhouette();
                }
                linear_extrude(double_h, center=true){
                    nut_seat_silhouette(offset=-2);
                }
            }
        }
        mirror([0,0,1]){
            //ground
            cylinder(r=999,h=999,$fn=8);
        }
    }
}

//TODO: h is currently the actator height plus travel. This should be a parameter rather than calculated ad-hoc
module motor_lugs(h, tilt=0, angle=0){
    screw_pos = motor_screw_pos(h);
    // lugs to mount a micro geared stepper motor on a screw_seat.
    screw_r = sqrt(pow(screw_pos.x,2)+pow(screw_pos.y,2));
    rotate_x(tilt){
        rotate(angle){
            reflect_x(){
                difference(){
                    union(){
                        hull(){
                            translate(screw_pos-[0,0,motor_lug_h()]){
                                cylinder(r=4,h=motor_lug_h());
                            }
                            translate_z(screw_pos.z-screw_r-motor_lug_h()){
                                cylinder(r=5,h=screw_r-5);
                            }
                        }
                    }
                    //space for gears
                    translate_z(h){
                        cylinder(r1=8,r2=17,h=2+tiny());
                    }
                    translate_z(h+2){
                        cylinder(h=999,r=17);
                    }
                    //hollow inside of the structure
                    rotate(-angle){
                        nut_seat_void(h=h, tilt=tilt);
                    }
                    //mounting screws
                    translate(screw_pos){
                        m4_selftap_hole(h=40,center=true);
                    }
                }
            }
        }
    }
}

module screw_seat(params, h, travel, tilt=0, extra_entry_h=7, include_motor_lugs=undef, lug_angle=0, label=""){
    // This forms a hollow column, usually built around an actuator_column to
    // support the screw (see screw_seat_shell)

    create_motor_lugs = if_undefined_set_default(include_motor_lugs,
                                                 key_lookup("include_motor_lugs", params));

    entry_h = extra_entry_h + travel; //ensure the actuator can move
    nut_slot_z = h-actuator_nut_size()-1.5-actuator_nut_slot_size().z;
    difference(){
        union(){
            screw_seat_shell(h=h + travel, tilt=tilt);

            if(create_motor_lugs){
                rotate(180){
                    motor_lugs(h=h + travel, angle=lug_angle, tilt=-tilt);
                }
            }
            if(len(label) > 0){
                rotate_x(tilt){
                    translate([0, actuator_housing_xy_size().y/2, nut_slot_z - 2]){
                        rotate_x(90){
                            linear_extrude(1, center=true){
                                mirror([1,0]){
                                    text(label, size=10, font="Sans", halign="center", valign="top");
                                }
                            }
                        }
                    }
                }
            }
        }
        //hollow out the inside
        nut_seat_void(h=h + travel, tilt=tilt);

        //allow the actuator to poke in
        edge_y = actuator_housing_xy_size().y/2;
        sparse_matrix_transform(zy=sin(tilt)){
            translate_y(-edge_y){
                cube([actuator_entry_width(), edge_y, entry_h*2], center=true);
            }
        }

        //entrance slot for nut
        rotate_x(tilt){
            translate_z(nut_slot_z){
                nut_trap_and_slot(actuator_nut_size(), actuator_nut_slot_size() + [0,0,0.3]);
            }
        }
    }
}

module screw_seat_outline(h=999,adjustment=0,center=false,tilt=0){
    // The bottom of a screw seat
    rotate_x(tilt){
        linear_extrude(h,center=center){
            nut_seat_silhouette(offset=adjustment);
        }
    }
}

