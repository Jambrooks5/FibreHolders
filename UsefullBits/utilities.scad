module isoTriangle(height, base, thickness){
    linear_extrude(height=thickness, center=true)
        polygon([[base/2,0],[-base/2,0],[0,height]]);       
}
module rightTriangle(height, base, thickness, skew=0){
    //Skew moves the top corner by a fraction of the base width
    linear_extrude(height=thickness, center=true)
        polygon([[0,0],[base*skew,height],[base,0]]);
}

module lSection(baseWidth, baseThickness, sideWidth, sideThickness, length){
    linear_extrude(length)
        polygon([[0,0],[-baseWidth,0],[-baseWidth,baseThickness],[-sideThickness,baseThickness],[-sideThickness,sideWidth],[0,sideWidth]]);
}
module M3cylinder(threadLength, headLength, $fn=50){
    union(){
        translate([0,0,-threadLength+0.01])
        cylinder(d=3, h=threadLength);
        
        cylinder(d=5.5, h=headLength);
    }
}

module nut(w, height, hole){
    t6=tan(60);
    
    difference(){
        linear_extrude(height, center=true)
            polygon([[w/t6,w],[-w/t6,w],[-(((w/t6)^2+w^2)^0.5),0],[-w/t6,-w],[w/t6,-w],[(((w/t6)^2+w^2)^0.5),0]]);

        cylinder(d=hole, h=height+1, center=true, $fn=50);
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

module roundedCorner(height, side){
    difference(){
        cube([side,side,height], center=true);
        translate([side/2,side/2,0]) cylinder(h=height+1,r=side,center=true,$fn=50);
    }   
}