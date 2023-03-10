// This is a trivial tool to support a 16mm lens as it is inserted
// into the holder.  Part of the OpenFlexure Microscope.

// (c) 2017 Richard Bowman, released under CERN open hardware license.

use <./libs/utilities.scad>

function lens_tool_height() = 20;

module lens_tool(h=lens_tool_height()){
    $fn=32;

    difference(){
        union(){
            cylinder(d=12.5, h=h);
            cylinder(d1=16, d2=12.5, h=10);
        }
        // hollow it out
        cylinder(d=8, h=999, center=true);
        // bevel the top
        translate_z(h-4){
            cylinder(d1=8, d2=10.5, h=4.01);
        }
    }
}

lens_tool();
