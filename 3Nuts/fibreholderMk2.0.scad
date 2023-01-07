use <agentscad/mx-screw.scad>
use <agentscad/mx-thread.scad>
use <./NutMaker.scad>

//translate([0,0,-20])import("C:/Users/User/Downloads/sample_riser_LS10 (1).stl");

///CALLING TESTS

//rotate([0,0,80]) curveDisc(12, 3, 3);
translate([0,0,-20]) straightDisc(20,3,3.1);
//arc(10,5,3);

nut(8,5,2.9);

module curveDisc(rad, thickness, boltSize,$fn=100){
    difference(){
        cylinder(r=rad, h=thickness, center=true);
        
        linear_extrude(thickness+1, center=true)
            channel(1.55,[60,180]);
        rotate([0,0,120])
            linear_extrude(thickness+1, center=true)
                channel(1.55,[60,180]);
        rotate([0,0,240])
            linear_extrude(thickness+1, center=true)
                channel(1.55,[60,180]);
        
        
        //rotate([0,0,0]) arc(rad/2.5,thickness,boltSize);
        //rotate([0,0,120]) arc(rad/2.5,thickness,boltSize);
        //rotate([0,0,240]) arc(rad/2.5,thickness,boltSize);
        
        cylinder(d=2, h=thickness+1, center=true);
    }
}


function getLinearR(_theta)=0.2*_theta;

module channel( _boltRad,_thetaRange,_numPoints=100){
    for (i=[0:_numPoints]){
        th=_thetaRange[0]+
        (_thetaRange[1]-_thetaRange[0])*i/_numPoints;
        r=0.05*th;
        translate([r*cos(th),r*sin(th),0])
            circle(r=_boltRad);
           //echo(r=r);
    }
}



module straightDisc(rad, thickness, boltSize,$fn=100){
    difference(){
        cylinder(r=rad, h=thickness, center=true);
        
        rotate([0,0,0]) straightCutout(rad, thickness, boltSize);
        rotate([0,0,120]) straightCutout(rad, thickness, boltSize);
        rotate([0,0,240]) straightCutout(rad, thickness, boltSize);
        
        cylinder(d=2, h=thickness+1, center=true);
    }
}

module straightCutout(rad, thickness, boltSize, , $fn=100){
    translate([-0,3.5,0])
            rotate([0,0,90])
                M3slot(rad-0.9*boltSize, thickness+1);
}

module arc(rad, thickness, boltSize, $fn=100){
    translate([-rad,-boltSize/4,0])
        rotate([0,0,0])
            rotate_extrude(angle=100)
                translate([rad+boltSize,0,0])
                    //square([boltSize, thickness+1], center=true);
                    #cylinder(d=boltSize, h=thickness+1, center=true);
}




///////////Little library///////
module M3hole(){
    translate([0,0,7.5]) cylinder(d=6.5, h=15, center=true, $fn=50);
    translate([0,0,-7]) cylinder(d=3.5, h=15, center=true, $fn=50);
}
module M3slot(centerSep, thickness=5){
    linear_extrude(height=thickness,center=true)
        union(){ 
            circle(d=3,$fn=30);
            translate([0,-centerSep]) circle(d=3,$fn=30);
            translate([0,-centerSep/2]) square([3,centerSep],center=true);   
        }
}

module m3stud(){
    difference(){
        #mxBoltHexagonalThreaded( M3() ,$fn=20);
        translate([0,0,18]) cylinder(d=4, h=5, center=true);
        translate([0,0,-2]) cylinder(d=10, h=5, center=true);
     }
 }

module corner(height, side){
    difference(){
        cube([side,side,height], center=true);
        translate([side/2,side/2,0]) cylinder(h=height+1,r=side,center=true,$fn=50);
    }   
}

module isoTriangle(height, base, thickness){
    linear_extrude(height=thickness, center=true)
        polygon([[base/2,0],[-base/2,0],[0,height]]);       
}
module rightTriangle(height, base, thickness, skew=0){
    //Skew moves the top corner by a fraction of the base width
    linear_extrude(height=thickness, center=true)
        polygon([[0,0],[base*skew,height],[base,0]]);
}



