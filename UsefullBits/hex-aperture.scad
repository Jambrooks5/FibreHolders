use <gearbox.scad>// parameters within
use <microscope-utilities.scad>
use <../UsefullBits/openscad/libs/utilities.scad>

//		CONSTANTS


big=999;// a distance larger than all other distances or objects used
m3NutWidth=5.3;
m3NutHeight=2.3;


//		GENERAL PARAMETERS


//$fs=0.1; $fa=1;
$fn=100;

//		SPECIFIC PARAMETERS


m3BoltHolderWallWidth=1.6;
m3BoltHolderDiam=2.9;
m3HexHoleDims=[m3NutWidth,m3NutHeight] + [0,0];// ← [width,height]
m3BoltHoleDiam=3 + 0;


//		MAIN


module main(){
	translate([0,0,0])
	m3BoltHolder(_wallThickness=1.6,_h=5,_nominalDiam=2.9,_extent=big,_center=false);
	translate([10,0,0])
	m3Bolt(40);
	translate([0,m3NutWidth/sqrt(3),0])rotate([0,0,30])
	closedAperture(true);
	translate([-10,0,0])
	rigidLeg(9,30);
	translate([-20,0,0])
	driverLeg(_holderHeight=9,_legLen=50,_flexLayerThickness=1,_flexLen=40,_flexTaperLen=2,_flexNumLayers=2,_hexDistFromEnd=1,_hexRecessLen=0,_hexRecessSF=1,_legDiamLim=big,_center=false);
	translate([-30,0,0])
	flexLeg(_holderHeight=20,_legLen=60,_flexLayerThickness=1,_flexLen=50,_flexTaperLen=1,_flexLayerSep=false,_flexNumLayers=2,_baseDims=[50,10,20],_baseFlexLayerThickness=0.5,_baseFlexLen=false,_baseFlexTaperLen=0.5,_baseFlexNumLayers=4,_legDiamLim=big,_center=true);
	translate([40,0,0]) difference(){
		cylinder(r=10,h=40);
		translate([0,0,5])
		flexRotorInv(_layerThickness=1,_h=30,_taperLen=2,_numHinges=6,_center=false,_extent=big);
	}
}


//		SPECIFIC MODULES


// NOTE: _legLen is the length starting at the center of the holder; also 
module rigidLeg(_holderHeight,_legLen,_legDiamLim=big,_center=true){
	module holder_(){
		m3BoltHolder(
			_wallThickness=m3BoltHolderWallWidth,
			_h=_holderHeight,
			_nominalDiam=m3BoltHolderDiam,
			_center=true
		);
	}
	translate([0,0,_center?0:_holderHeight/2]){
		holder_();
		// ↓ confines the cylinder to within the confines of the holder shape without filling in the center
		intersection(){
			difference(){
				rotate([90,0,0]) cylinder(d=_legDiamLim,h=_legLen);
				m3SelftapInv(_nominalDiam=m3BoltHolderDiam,_center=true);
			}
			hull(){
				holder_();
				translate([0,-2*_legLen,0]) holder_();
			}
		}
	}
}

// shouldn't grab the bolt furthest from the nut, as it could lead to an increase in friction sticking; _flexLayerSep=false automatically fits the flex layers to the leg (as long as _legDiamLim=big)
module driverLeg(_holderHeight,_legLen,_flexLayerThickness,_flexLen,_flexTaperLen=0,_flexLayerSep=false,_flexNumLayers=2,_hexDistFromEnd=-0.01,_hexRecessLen=0,_hexRecessSF=1,_legDiamLim=big,_center=true){
	// ↓ calculating the appropriate layer seperation if not given
	selftapVals=getSelftapTrylinderVals(m3BoltHolderDiam);
	selftapWallRad=getSelftapWallRad(m3BoltHolderDiam);
	wallScaleFactor=1+(m3BoltHolderWallWidth/selftapWallRad);
	_flexLayerSep=_flexLayerSep==false?
	let(legWidth=(selftapVals[1]+2*selftapVals[0])*wallScaleFactor)
	(legWidth-_flexLayerThickness)/(_flexNumLayers-1):
	_flexLayerSep;
	//
	translate([0,0,_center?0:_holderHeight/2]){
		difference(){
			rigidLeg(_holderHeight,_legLen,_legDiamLim,true);
			// ↓ flexer
			translate([0,-_legLen/2,0]) rotate([90,0,0])
			flexHingeStackInv(
				_layerThickness=_flexLayerThickness,
				_h=_flexLen,
				_taperLen=_flexTaperLen,
				_layerSep=_flexLayerSep,
				_numLayers=_flexNumLayers,
				_center=true,
				_extent=big
			);
			// ↓ hexTrap
			difference(){
				translate([0,_hexRecessLen-_legLen+_hexDistFromEnd,0])
				rotate([-90,-90,0])
				m3HexTrapInv(
					_recessLen=_hexRecessLen,
					_recessSF=_hexRecessSF,
					_center=false,
					_extent=big
				);
				translate([0,-_legLen/2,0]) rotate([-90,0,0])
				cylinder(r=big,h=big,center=false);// stops the boltHole halfway through the flexHingeStack
			}
		}
	}
}

// 
module flexLeg(_holderHeight,_legLen,_flexLayerThickness,_flexLen,_flexTaperLen=0,_flexLayerSep=false,_flexNumLayers=2,_baseDims=[0,0,0],_baseFlexLayerThickness=0,_baseFlexLen=false,_baseFlexTaperLen=0,_baseFlexLayerSep=false,_baseFlexNumLayers=2,_legDiamLim=big,_center=true){
	// ↓ calculating the appropriate layer seperation if not given
	selftapVals=getSelftapTrylinderVals(m3BoltHolderDiam);
	selftapWallRad=getSelftapWallRad(m3BoltHolderDiam);
	wallScaleFactor=1+(m3BoltHolderWallWidth/selftapWallRad);
	legWidth=(selftapVals[1]+2*selftapVals[0])*wallScaleFactor;
	_flexLayerSep=_flexLayerSep==false?
	(legWidth-_flexLayerThickness)/(_flexNumLayers-1):
	_flexLayerSep;
	//
	module mainLeg(){
		difference(){
			rigidLeg(_holderHeight,_legLen,_legDiamLim,true);
			// ↓ side-to-side flexer
			translate([0,-_legLen,0]) rotate([90,0,180])
			//↑translate([0,-_legLen/2,0]) rotate([90,0,0])
			flexHingeStackInv(
				_layerThickness=_flexLayerThickness,
				_h=_flexLen,
				_taperLen=_flexTaperLen,
				_layerSep=_flexLayerSep,
				_numLayers=_flexNumLayers,
				_center=false,
				//↑_center=true,
				_extent=big
			);
		}
	}
	translate([0,0,_center?0:_holderHeight/2]){
		mainLeg();
		// ↓ forward-backward flexer
		_baseFlexLen=_baseFlexLen==false?
		(_baseDims[0]/2)-legWidth:
		_baseFlexLen;
		translate([0,-0.5*_baseDims[1]-_legLen,0])
		flexSpring(
			_dims=_baseDims,
			_blockWidth=legWidth,
			_layerThickness=_baseFlexLayerThickness,
			_flexLen=_baseFlexLen,
			_taperLen=_baseFlexTaperLen,
			_layerSep=_baseFlexLayerSep,
			_numLayers=_baseFlexNumLayers,
			_center=true
		);
	}
}


//
module closedAperture(_centered=false){
	for(i=[0:2]){
		color([i==0?1:0,i==1?1:0,i==2?1:0])
		rotate(120*i) translate([m3NutWidth/sqrt(3),0,0]) m3Nut(_centered);
	}
}


//		GENERAL SHAPES


// regular 2d polygon
module regPoly(_numSides,_cornerRad){
	corners=[for(i=[0:_numSides]) [
		_cornerRad*cos(i*360/_numSides),
		_cornerRad*sin(i*360/_numSides),
	]];
	polygon(corners);
}

// hexagonal prism; _cornerRad=width/sqrt(3)
module hex(_cornerRad,_h=0,_center=false){
	if(_h!=0) linear_extrude(_h,center=_center) regPoly(6,_cornerRad);
	else regPoly(6,_cornerRad);
}

// a rounded (concave) corner of radius of curvature _r, for use with difference() or union(); curve will arc between +x & +y directions
module roundedCorner(_r,_h,_center=false){
	translate([0,0,_center?-_h/2:0])
	difference(){
		// the 0.1s prevent face alignment
		cube([_r+0.1,_r+0.1,_h]);
		translate([0,0,-0.1]) cylinder(r=_r,h=_h+0.2);
	}
}

// creates a 3d line of given thickness between the given points
module volLine(_points,_thickness){
	for(i=[1:len(_points)-1]){
		hull(){
			translate(_points[i-1]) sphere(d=_thickness);
			translate(_points[i]) sphere(d=_thickness);
		}
	}
}

// creates a 2d line of given thickness between the given points
module areaLine(_points,_thickness){
	for(i=[1:len(_points)-1]){
		hull(){
			translate(_points[i-1]) circle(d=_thickness);
			translate(_points[i]) circle(d=_thickness);
		}
	}
}

// VERY SLOW
module applyTwist(_thetaPerZ,_zLims,_numSlices=100,_numSubSlices=10){
	zStep=(_zLims[1]-_zLims[0])/_numSlices;
	thetaStep=_thetaPerZ*zStep;
	for(iZ=[0:_numSlices]){
		thisZ=_zLims[0]+iZ*zStep;
		
		translate([0,0,thisZ])
		linear_extrude(height=zStep,center=true,twist=-thetaStep*0,slices=_numSubSlices)
		rotate(_thetaPerZ*thisZ,[0,0,1])
		projection(cut=true) translate([0,0,-thisZ]) children();
	}
}


//		FLEXURE COMPONENTS


// in the xy plane, with the groove along the x axis
// flexure hinge inverse, ie for use with difference(); for monoaxial flexing & somewhat low twisting
module flexHingeInv(_thickness,_h,_taperLen=0,_center=false,_extent=big){
	translate([0,0,_center?0:_h/2])
	union(){
		for(iSide=[0:1]){
			rotate(180*iSide,[0,0,1]) translate([_thickness/2,0,0])
			difference(){
				translate([0,-_extent/2,-_h/2])
				cube([_extent,_extent,_h]);
				for(iCorner=[0:1]){//rounding upper & lower corners
					rotate(180*iCorner,[1,0,0])
					rotate(180,[0,0,1])
					rotate(-90,[1,0,0])
					translate([-_taperLen,(_h/2)-_taperLen,0])
					roundedCorner(_taperLen,_extent+0.1,true);
				}
			}
		}
	}
}

// flexure hinge stack inverse; like flexHingeInv(), but produces a stack of hinge layers; use in the same way as flexHingeInv(); for monoaxial flexing without tilting & minimal rotation
module flexHingeStackInv(_layerThickness,_h,_taperLen=0,_layerSep=0,_numLayers=2,_center=false,_extent=big){
	layerSep= _layerSep==0 ? (_taperLen==0?1/_numLayers:_taperLen*2) : _layerSep;
	intersection_for(i=[0:_numLayers-1]){
		translate([layerSep*(i-(_numLayers-1)/2),0,0])
		flexHingeInv(_layerThickness,_h,_taperLen,_center,_extent);
	}
}

// for twisting without axial flexing;
module flexRotorInv(_layerThickness,_h,_taperLen=0,_numHinges=3,_center=false,_extent=big){
	intersection_for(i=[0:_numHinges-1]){
		rotate(180*i/_numHinges,[0,0,1])
		flexHingeInv(_layerThickness,_h,_taperLen,_center,_extent);
	}
	removedCenterCylinderRad=(_layerThickness/2)/sin(90/(_numHinges+1));// removes the center region where the hinges combine; the +1 is to prevent edge overlap
	cylinder(r=removedCenterCylinderRad,h=_h,center=_center);
}

// make a hinge tube \ hollow cylinder for all axial motion but not twisting or tilting; probably doesn't need to be an inverse in this case
module flexTubeInv(_layerThickness,_h,_r,_taperLen=0,_center=false,_extent=big){
	module hingeProjection(){
		intersection(){
			translate([_r,0,0])
			projection(cut = true)
			rotate(90,[1,0,0]) flexHingeInv(_layerThickness,_h,_taperLen,true,_extent);
			translate([_extent,0,0]) square(2*_extent,center=true);
		}
	}
	translate([0,0,_center?0:_h/2])
	rotate_extrude(angle=360,convexity = 10) hingeProjection();
}

// allows axial motion but not twisting
module flexTube(_layerThickness,_h,_r,_taperLen=0,_center=false){
	difference(){
		cylinder(r=_r+_layerThickness+_taperLen,h=_h,center=_center);
		flexTubeInv(_layerThickness,_h,_r,_taperLen,_center);
	}
}

//
module flexSpring(_dims,_blockWidth,_layerThickness,_flexLen=false,_taperLen=0,_layerSep=false,_numLayers=2,_center=false){
	//
	_layerSep=_layerSep==false?
	(_dims[1]-_layerThickness)/(_numLayers-1):
	_layerSep;
	_flexLen=_flexLen==false?
	0.5*(_dims[0]-_blockWidth):
	_flexLen;
	//
	translate([0,0,_center?0:_dims[2]/2]){
		difference(){
			cube(_dims,center=true);
			for(i=[-1,1]){
				translate([i*_blockWidth/2,0,0]) rotate([90,0,90*i])
				flexHingeStackInv(
					_layerThickness=_layerThickness,
					_h=_flexLen,
					_taperLen=_taperLen,
					_layerSep=_layerSep,
					_numLayers=_numLayers,
					_center=false,
					_extent=big
				);
			}
		}
	}
}
	// needs to ideally be resistant to tilting, ie one side can't compress without the other
	// ideas:
	// 	matrix transformation of flexTube? bows out at the center?
	//		would allow for axial motion
	//		matrix mult would add the f(z) to all x,y coords at that z, ie cannot add an f(x,y,z)
	//			would have to apply the matrix mult to the one-sided projection hingeProjection() before the rotate_extrude
	//	like flexRotor, but each blade is slanted eg clockwise?
	//		would rotate as it compressed
	//	as ↑ but with blades also slanted the other direcion?
	//		may not rotate easily, structural weakness
	//	as ↑ but curves as intersections, ie approx like gyroid fill pattern, possibly a sinusiodal func?
	//		perhaps good but complicated
	//	in order to prevent axial motion, we would need to prevent one side from compressing unless the other side does as well


//		NUTS & BOLTS


//
module m3Nut(_center=false){
	translate([0,0,_center?-m3NutHeight/2:0])
	difference(){
		hex(m3NutWidth/sqrt(3),m3NutHeight,_center=false);
		translate([0,0,-0.1]) cylinder(d=3,h=m3NutWidth+0.2,center=false);
	}
}

//
module m3Bolt(_h=40){
	color([1,1,0]){
		cylinder(d=5.5,h=3,center=false);
		cylinder(d=3,h=_h,center=false);
	}
}

//
module m3HexTrapInv(_recessLen=0,_recessSF=1,_cornerForwardsMode=true,_center=false,_extent=big){
	hexTrapInv(m3BoltHoleDiam,m3HexHoleDims[0],m3HexHoleDims[1],_recessLen=_recessLen,_recessSF=_recessSF,_cornerForwardsMode=_cornerForwardsMode,_center=_center,_extent=_extent);
}

// _nominalDiam of ~3 works decently though perhaps a little too loose, 3.1 is tolerable, 2.8 is tight but works nicely
module m3SelftapInv(_nominalDiam=3,_extent=big,_center=true){
	trylinder_selftap(_nominalDiam, h=_extent, center=_center);
}

//
function getSelftapWallRad(_nominalDiam)=
max(_nominalDiam*0.8/2 + 0.2, _nominalDiam/2 - 0.2);

//returns the cylinder radiusn and the flat wall section length
function getSelftapTrylinderVals(_nominalDiam)=
let(
	r = max(_nominalDiam*0.8/2 + 0.2, _nominalDiam/2 - 0.2),
    dr = 0.5,
    flat = dr * 2 * sqrt(3),
	cylRad=r - dr
)
[cylRad,flat];

//
module m3BoltHolder(_wallThickness,_h,_nominalDiam=3,_extent=big,_center=true){
	wallRad=getSelftapWallRad(_nominalDiam);
	scaleFactor=(_wallThickness+wallRad)/wallRad;
	//
	translate([0,0,_center?0:_h/2])
	difference(){
		scale(scaleFactor)
		trylinder_selftap(_nominalDiam, h=_h/scaleFactor, center=true);
		trylinder_selftap(_nominalDiam, h=_extent, center=true);
	}
}

// for converting rotation to linear motion, using 1 bolt and 1 nut; bolt hole along z, hex hole along x
module hexTrapInv(_boltHoleDiam,_hexWidth,_hexHeight,_recessLen=0,_recessSF=1,_cornerForwardsMode=true,_center=false,_extent=big){
	hexHoleWidth=_cornerForwardsMode?_hexWidth:2*_hexWidth/sqrt(3);
	translate([0,0,_center?0:_hexHeight/2]){
		cylinder(d=_boltHoleDiam,h=_extent,center=true);
		translate([0,-hexHoleWidth/2,-_hexHeight/2])
		cube([_extent,hexHoleWidth,_hexHeight]);
		rotate(_cornerForwardsMode?0:30,[0,0,1])
		{
			hex(_hexWidth/sqrt(3),_hexHeight,true);
			// ↓ recess
			for(i=[0,1]){
				rotate(180*i,[1,0,0]) translate([0,0,_hexHeight/2])
				linear_extrude(_recessLen,scale=_recessSF) 
				hex(_hexWidth/sqrt(3),0,true);
			}
		}
		// TODO: need a way to hold nut in place
	}
}


//		RUN


main();