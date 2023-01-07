use <../openscad/MIAH_large_gears.scad>
//  PARAMETERS
nutSize = 2.75;
nutHeight = 5;

legLength = 30;
legDiam = 2.8;
armLength = 20;
//effective finger length will be fingerLength-legDiam
fingerLength = 10;

t6=tan(60);

nutPos=[[0, (((nutSize/t6)^2+nutSize^2)^0.5), -legLength],
    [nutSize, -nutSize/t6, -legLength],
    [-nutSize, -nutSize/t6, -legLength]];
    
    
//stackedGears();
arcCutout(100);
module stackedGears(){
    for (i=[0:0]){
        translate([0,0,7*i])
        rotate([0,0,0])
            translate(nutPos[i])
        rotate([0,0,0])        
        difference(){
                    
                    printable_large_gears();
                    translate([0,0,3])
                        rotate([0,0,0])
                            arcCutout(100);
                    translate([0,0,3])
                        rotate([0,0,0])
                            arcCutout(100);
                }
    }
}

module arcCutout(angle, $fn=50){
    rotate_extrude(angle=angle, convexity=2)
        union(){
            translate([2*nutSize,0,0])
                square([1.4*legDiam, 10], center=true);
            rotate([0,0,120])
                translate([2*nutSize,0,0])
                    square([1.4*legDiam, 10], center=true);
        }
}