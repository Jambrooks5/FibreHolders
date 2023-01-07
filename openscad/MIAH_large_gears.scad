use <./libs/gears.scad>
use <./libs/utilities.scad>

printable_large_gears();

module printable_large_gears(){
    // Calculate the spacing from the gear pitch radius.
    // Add 4mm of clearance
    //spacing = 2*large_gear_pitch_radius() + 4;
    //repeat([0,spacing,0],3,center=true){
        large_gear();
    //}
}
