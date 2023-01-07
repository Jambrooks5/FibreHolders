nut(8,5,2.9);

//w = Distance from center to flat edge
//height = thickness of nut
//hole = diameter of center hole cutout
module nut(w, height, hole){
    t6=tan(60);
    
    difference(){
        linear_extrude(height, center=true)
            polygon([[w/t6,w],[-w/t6,w],[-(((w/t6)^2+w^2)^0.5),0],[-w/t6,-w],[w/t6,-w],[(((w/t6)^2+w^2)^0.5),0]]);

        cylinder(d=hole, h=height+1, center=true, $fn=50);
    }
}