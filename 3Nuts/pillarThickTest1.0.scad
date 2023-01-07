$fn=50;

rotate([90,0,0])
for (i=[2.5,2.6,2.7,2.8,2.9]){
    translate([0,(i/2)-2.5,50*(i-2.5)])
        cylinder(d=i, h=5, center=true);
}

//cylinder(d=3, h=30, center=true);
//translate([0,0,14]) cylinder(d=2.8, h=10, center=true);