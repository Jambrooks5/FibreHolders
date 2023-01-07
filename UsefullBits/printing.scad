
// NOTE: onlyOuterBrimMode only works correctly for convex floor shapes
module smartBrim(_gap=0.2,_height=0.2,_circleRad=4,_z0=0,_onlyOuterBrimMode=false,$fn=$fn){
	module bottomLayer(){
		projection(cut=true)
		translate([0,0,-_z0])
		children();
	}
	module blobby(_r){
		minkowski(){
			bottomLayer() children();
			circle(r=_r);
		}
	}
	translate([0,0,_z0])
	linear_extrude(height=_height)
	difference(){
		blobby(_circleRad) children();
		blobby(_gap) 
		if(_onlyOuterBrimMode){hull() children();}
		else{children();}
	}
	children();
}

$fn=50;
//smartBrim() cube(5,center=false);
smartBrim()
    translate([0,20,-33])
    rotate([0,90,0])
        import ("../3Nuts/STLs/3.5/interGear.stl");
