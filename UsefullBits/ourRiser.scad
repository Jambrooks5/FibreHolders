

big=999;

module main(){
	//translate([100,100,0]) sampleRiser();
	//translate([100,0,0]) upperSlice();
	//translate([0,100,0]) lowerSlice();
	translate([0,0,0]) ourRiser(3,3,9);
}


module ourRiser(_lowerHeight,_upperHeight,_gapWidth=0){
	difference(){
		union(){
			linear_extrude(height=_lowerHeight) lowerSlice();
			translate([0,0,_lowerHeight])
			linear_extrude(height=_upperHeight) upperSlice();
		}
		translate([-_gapWidth/2,0,-big/2]) cube([_gapWidth,big,big],center=false);
	}
}

module upperSlice(){
	projection(cut=true)
	translate([0,0,-10]) sampleRiser();
}

module lowerSlice(){
	projection(cut=true)
	translate([0,0,-1]) sampleRiser();
}

module sampleRiser(){
	import("sample_riser_LS10.stl");
}

main();