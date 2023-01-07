
use <./utilities.scad>
use <./compact_nut_seat.scad>
use <./logo.scad>
use <./z_axis.scad>
use <./wall.scad>
use <./main_body_transforms.scad>
use <../reflection_illuminator.scad>
use <./libdict.scad>
use <./microscope_parameters.scad> //All the geometric variables are now in here.
$fn = 32;

// base_mounting_holes returns a list of the holes for mounting the microscope
// to the base. By default it returns all four holes.
// To get only the back hole run `base_mounting_holes("back")`
// To get only the front holes run `base_mounting_holes("front")`
function base_mounting_holes(params, type="all") = let
(
    back_lug_hole_x = back_lug_x_pos(params) + microscope_wall_t()/2 - lug_back_offset().x,
    back_pos = [[back_lug_hole_x,-8,0],
               [-back_lug_hole_x,-8,0]],
    actuator_offset = [-1, -1, 0] * actuator_housing_xy_size().x/2/sqrt(2),
    y_front_lug_pos = y_actuator_pos(params) + actuator_offset + [-6.5, .5, 0],
    front_pos =[y_front_lug_pos,
               [-y_front_lug_pos.x, y_front_lug_pos.y, 0]],
    back = (type == "back") || (type == "all"),
    front = (type == "front") || (type == "all"),
    //Set which holse to output
    holes = [back?back_pos:[], front?front_pos:[]]
    //Final list comprehension make a single list of holes
) [for (h = holes) each h];

module leg_flexures(params, brace){
    // These are the flexures on the top and bottom of the leg that connect the
    // two vertical bars together.
    //
    // `brace` sets the distance to widen the block at the bottom of the leg
    //  two flexures are prodcued offset by brace. Therefore
    //  * if brace=0 there is one normal sized flexure.
    //  * if brace=flex_dims().x there is one double width fexure
    //  * if brace>flex_dims().x there are two seperare flexures
    leg_block_t = key_lookup("leg_block_t", params);
    block_size = [leg_middle_w(), leg_dims(params).y, leg_block_t];
    flex_size = [leg_outer_w(params), leg_dims(params).y, flex_dims().z];

    for (i = [0,1]){
        z_pos=[lower_xy_flex_z(), upper_xy_flex_z(params)][i];
        brace_pos= [brace, 0][i];
        translate_z(z_pos){
            //Hull two blocks to make a big one
            hull(){
                repeat([0,brace_pos,0],2){
                    translate_x(-block_size.x/2){
                        cube(block_size);
                    }
                }
            }
            //Repeat two flexures may be separate depending on brace.
            repeat([0,brace_pos,0],2){
                translate_x(-flex_size.x/2){
                    cube(flex_size);
                }
            }
        }
    }

}

module leg(params, brace=flex_dims().x){
    // The legs support the stage - this is either used directly
    // or via "actuator" to make the legs with levers
    fw=flex_dims().x;

    union(){
           //leg
        reflect_x(){
            //vertical bars of the leg
            translate_x(leg_middle_w()/2+flex_dims().y){
                hull(){
                    cube(leg_dims(params));
                    //extend the base to make the bars triangular
                    cube([leg_dims(params).x, fw+brace ,tiny()]);
                }
            }
        }
        leg_flexures(params, brace);

        //thin links between legs
        flex_sep = upper_xy_flex_z(params)-lower_xy_flex_z();
        n = floor(flex_sep/leg_link_spacing());
        if(n > 2){
            // adjust spacing so it is even
            link_space_adj = flex_sep/n;
            translate([0, leg_dims(params).y/2, lower_xy_flex_z()+link_space_adj]){
                repeat([0, 0, link_space_adj], n-1){
                    cube([leg_outer_w(params), 2, 0.5],center=true);
                }
            }
        }
    }
}

module actuator(params){
    // A leg that supports the stage, plus a lever to tilt it.
    // No longer includes the flexible nut seat actuating column.
    // TODO: find the code that unifies this with leg()
    brace=20;
    fw=flex_dims().x;
    w = actuator_dims(params).x;
    union(){
        leg(params, brace=brace);

        //arm (horizontal bit)
        difference(){
            sequential_hull(){
                translate_x(-leg_middle_w()/2){
                    cube([leg_middle_w(),brace+fw,4]);
                }
                translate_x(-w/2){
                    cube([w,brace+fw+0,actuator_dims(params).z]);
                }
                translate_x(-w/2){
                    cube(actuator_dims(params));
                }
            }
            //don't foul the actuator column
            translate_y(actuating_nut_r(params)){
                actuator_end_cutout();
            }
        }

    }
}

module actuator_silhouette(params, h=999){
    // This defines the cut-out from the base structure for the XY
    // actuators.
    linear_extrude(2*h,center=true){
        minkowski(){
            circle(r=flex_dims().y,$fn=12);
            projection(){
                actuator(params);
            }
        }
    }
}

module mounting_hole_lugs(params, holes=true){
    // lugs either side of the XY table to bolt the microscope down
    // these are to mount onto the baseplate

    //Just get one lug hole and then reflect the lug.
    hole_pos = base_mounting_holes(params);
    for (n = [0:len(hole_pos)-1]){
        hole = hole_pos[n];
        angle = lug_angles()[n];
        m3_lug(hole, angle, holes=holes);
    }
}

module m3_lug(pos, angle, holes=true){
    // position in the hole poistion. Rotate about hole

    translate(pos){
        rotate(angle){
            difference(){
                //the lug
                hull(){
                    translate(lug_back_offset()){
                        cube([10,tiny(),10]);
                    }
                    cylinder(d=8.8,h=3);
                }
                //the lug hole
                if (holes) {
                    translate_z(3){
                        m3_cap_counterbore(10, 10);
                    }
                }
            }
        }
    }
}

module reflection_illuminator_cutout(extra_depth=0){
    // The shape for a hole in the main body for the reflection illuminator to poke through.

    top_cutout_w = 17.8;
    mid_cutout_w = illuminator_width() + 1;
    bottom_cutout_w = illuminator_width() + 4;

    // Create a trapezoidal shape with width=top_cutout_w at the top.
    // This is the widest cutout we can make at height 'reflection_cutout_height()'
    // without the bridge having a corner in it.
    hull() {
        //cut below for stand
        translate([-(bottom_cutout_w)/2, -49, -22-extra_depth]){
            cube([bottom_cutout_w, 49, 1]);
        }
        translate([-(bottom_cutout_w)/2, -49, -0.5]){
            cube([bottom_cutout_w, 49, 1]);
        }
        translate([-(mid_cutout_w)/2, -49, 10]){
            cube([mid_cutout_w, 49, 1]);
        }
        translate([-top_cutout_w/2, -49, reflection_cutout_height()-1]){
            cube([top_cutout_w, 49, 1]);
        }
    }
}

module xy_stage(params, h=10, on_buildplate=false){
    // This module is the outer shape of the XY stage.
    // A square without corners, and a hole through middle.
    // The size in XY is set by microscope_parameters.scad,
    // the thickness (z) is set by input h
    // The boolean value on_buildplate sets wether the stage is printed on the
    // buildplate. If true, the bottom is flat, if false the bottom is made from
    // bridges round the edge, that then work inwards.

    side_length = leg_middle_w()+2*flex_dims().y;
    cut_out_side_length = leg_middle_w()-2*flex_dims().x;
    thickness = on_buildplate?h:h-1;
    z = on_buildplate?0:1;
    hole_r = key_lookup("stage_hole_r", params);

    difference(){
        hull(){
            each_leg(params){
                translate([0,-flex_dims().y-tiny(),z+thickness/2]){
                    cube([side_length,2*tiny(),thickness],center=true);
                }
            }
        }
        // Cuts out the hole in the stage, starting from a square.
        if (on_buildplate){
            //Normal hole if being printed on build plate
            cylinder(r=hole_r,h=999,center=true,$fn=32);
        }
        else{
            // If being printed in the in the air it needs a series of bridges to
            // be printed.
            intersection(){
                // hole_from_bottom() is used to create a cylinder which starts
                // as a square, then and octagon, doubling in number of side until
                // "circular"
                translate_z(1){
                    rotate(45){
                        hole_from_bottom(hole_r,h=999);
                    }
                }
                //The hole is intersected with this cube so the area above the
                //Top x-y flexures is not cut out
                hull(){
                    each_leg(params){
                        cube([cut_out_side_length,tiny(),999],center=true);
                    }
                }
            }
        }
    }
}


module xy_actuators(params, ties_only=false){
    // Just the actuators for the xy.
    // If ties_only=true then only the ties to the casing are printed. This is useful for
    // rendering instructions

    ties = key_lookup("print_ties", params);
    actuator_h = key_lookup("actuator_h", params);
    each_actuator(params){
        //actuator is the leg bat to connect to the flexure at the bottom of the column
        if (! ties_only){
            actuator(params);
        }
        translate_y(actuating_nut_r(params)){
            if (! ties_only){
                actuator_column(actuator_h, join_to_casing=ties);
            }
            else{
                actuator_ties();
            }
        }
    }
}

module xy_screw_seat(params, label=""){

    h = key_lookup("actuator_h", params);
    include_motor_lugs = key_lookup("include_motor_lugs", params);
    screw_seat(params,
               h,
               travel=xy_actuator_travel(params),
               include_motor_lugs=include_motor_lugs,
               extra_entry_h=actuator_dims(params).z+2,
               label=label);
}

module xy_legs_and_actuators(params){
    // This is the xy_actuators including the casing and all 4 legs

    // back legs
    reflect_x(){
        leg_frame(params, 135){
            leg(params);
        }
    }
    //front legs and actuator columns
    xy_actuators(params);

    for(i = [0,1]){
        label = ["X","Y"][i];
        angle = [-45,45][i];
        leg_frame(params, angle){
            translate_y(actuating_nut_r(params)){
                xy_screw_seat(params, label);
            }
        }
    }
}

module internal_xy_structure(params){

    difference() {
        add_hull_base(microscope_base_t()){
            wall_inside_xy_stage(params);
        }
        central_optics_cut_out(params);
        // Cut-out for reflection optics
        reflection_illuminator_cutout();
    }
}

module xy_stage_with_nut_traps(params)
{
    //This is the microscope xy-stage built at the correct height
    //and including the nut traps.
    stage_t = key_lookup("stage_t", params);
    difference(){
        translate_z(upper_xy_flex_z(params)){
            xy_stage(params, h=stage_t);
        }
        each_leg(params){
            translate([0, -stage_hole_inset(), leg_height(params)]){
                m3_nut_trap_with_shaft(0,0); //mounting holes
            }
        }
    }
}

module xy_flexures(params){

    //Bottom flexures: flexures between legs and inner walls
    w=flex_dims().x;
    //The flexure length, increased for some overlap
    flex_len = flex_dims().y + microscope_wall_t()/2;
    each_leg(params){
        reflect_x(){
            translate([leg_middle_w()/2-w, 0, lower_xy_flex_z()+0.5]){
                //Each flexure is the hull of two offset cuboids.
                hull(){
                    repeat([flex_len,-flex_len,0],2){
                        cube([w, tiny(), flex_dims().z]);
                    }
                }
            }
        }
    }

    // Top flexures: flexures between legs and stage
    // NOTE: these connect the legs together, and pass all the way under the stage.
    // This is important! If they get cut then the bridges will fail!
    difference(){
        //Make a truncated square with a truncated "corner" at each leg
        hull(){
            each_leg(params){
                translate_z(upper_xy_flex_z(params)+flex_dims().z/2+0.5){
                    cube([leg_middle_w(),tiny(),flex_dims().z],center=true);
                }
            }
        }
        //chop out a smaller truncated square
        hull(){
            each_leg(params){
                cube([leg_middle_w()-2*flex_dims().x,tiny(),999],center=true);
            }
        }
    }
}

module xy_leg_ties(params){
    // Small ties that connect the legs to the walls of the structure to stop the
    // legs moving during printing. These muse be cut after printing.

    z_tr = actuator_wall_h()*0.7;
    // Note that the walls slope in by 6 degrees so must compensate tie length
    tie_length = flex_dims().y + z_tr*tan(6) + 2;
    x_tr = leg_middle_w()/2+flex_dims().y+flex_dims().x/2;
    y_tr = 1-tie_length;

    reflect_x(){
        leg_frame(params, 135){
            reflect_x(){
                translate([x_tr, y_tr, z_tr]){
                    cube([1, tie_length, 0.5]);
                }
            }
        }
    }
}

module xy_positioning_system(params){
    // This module creates the main XY positioning mechanism. Including the actuator columns.
    ties = key_lookup("print_ties", params);
    xy_legs_and_actuators(params);
    internal_xy_structure(params);
    xy_stage_with_nut_traps(params);

    // Connect the legs to the stage and structure with flexures
    xy_flexures(params);


    //tie the legs to the wall to stop movement during printing
    if (ties){
        xy_leg_ties(params);
    }
}

module central_optics_cut_out(params, h=10, center=true) {
    // Central cut-out for optics of main body
    linear_extrude(h, center=center){
        central_optics_cut_out_projection(params);
    }
}

module xy_actuator_cut_outs(params){
    each_actuator(params){
        actuator_silhouette(params, xy_actuator_travel(params)+actuator_dims(params).z);
        translate_y(actuating_nut_r(params)){
            screw_seat_outline(h=999,adjustment=-tiny(),center=true);
        }
    }
}


module actuator_walls_and_z_casing(params, z_axis=true){
    // These are the wall that link the actuators. And the casing for the
    // z-axis. This casing includes the mount for the illumination dovetail.
    difference(){
        union(){
            add_hull_base(microscope_base_t()) {
                //link the XY actuators to the wall
                if (z_axis){
                    reflect_x(){
                        wall_inside_xy_actuators(params);
                    }
                }
                reflect_x(){
                    wall_outside_xy_actuators(params);
                }
                reflect_x(){
                    wall_between_actuators(params);
                }
                // outer profile of casing and anchor for the z axis
                if (z_axis){
                    z_axis_casing(params, condenser_mount=true);
                }
            }
            reflect_x(){
                side_housing(params);
            }
            //lugs to bolt the microscope down to base
            mounting_hole_lugs(params);
        }
        //This also cuts the walls hence why it is two objects
        if (z_axis){
            z_axis_casing_cutouts(params);
            z_cable_housing_cutout(params);
        }
        xy_actuator_cut_outs(params);
        central_optics_cut_out(params);
    }
}

module body_logos(params, message){
    // The openflexure and opehardware logos. Plus a customisable message.
    size = 0.25;
    place_on_wall(params, is_y=false){
        translate([9,actuator_wall_h()-2-15*size,-0.5]){
            scale([size,size,10]){
                openflexure_logo_above();
            }
        }
    }

    place_on_wall(params){
        translate([-34, actuator_wall_h()-2-15*size, -.5]){
            mirror([1,0,0]){
                scale([size,size,10]){
                    oshw_logo_and_text(message);
                }
            }
        }
    }
}

module xy_only_body(params){
    // This is a version of the body with only xy actuators. It is not used in the microscope
    // but can be useful for other positioning systems.
    xy_positioning_system(params);
    difference(){
        actuator_walls_and_z_casing(params, z_axis=false);
        body_logos(params, "xy-only");
    }
}

module main_body(params, version_string){
    // This module represents the main body of the microscope, including the positioning mechanism.

    difference(){
        xy_positioning_system(params);
        z_axis_casing_cutouts(params);
    }

    //z axis - Only the actuator column is housed at this point
    complete_z_actuator(params);

    difference(){
        actuator_walls_and_z_casing(params);
        body_logos(params, version_string);
    }
}