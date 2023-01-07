use <./openscad/libs/MCAD/involute_gears.scad>

//	MESHING PARAMETERS

toothArcSpacing=5;
pressureAngle=30;

clearance_=0.5;

backlash_=0;

twistPerHeight=0;

//	OTHER PARAMETERS

$fn=100;

//	MAIN

module main(){
	ourGear(10,0,0);
}

//	MODULES

module ourGear(_numTeeth,_boreDiameter,_height=0, _reverse=false){
    rotate(360*$t*(_reverse?-1:1)/_numTeeth,[0,0,1])
	gear(
		number_of_teeth=_numTeeth,
		diametral_pitch=PI/toothArcSpacing,// pitchCircDiam = numTeeth/diametral_pitch & pitchCircCircum = PI*pitchCircDiam
		pressure_angle=pressureAngle,
		clearance=clearance_,
		gear_thickness=_height,
		rim_thickness=_height,
		//rim_width=rimWidth,
		hub_thickness=_height,
		//hub_diameter=hubDiameter,
		bore_diameter=_boreDiameter,
		//circles=circles_,// doesn't work without tweaking diameters
		backlash=backlash_,
		twist=twistPerHeight*_height,
		//involute_facets=involuteFacets,
		flat=(_height==0)// gives the 2D profile instead
	);
    
}

//	RUN

main();