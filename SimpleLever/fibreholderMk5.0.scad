use <../UsefullBits/utilities.scad>


//PARAMETERS
hingeL = 40;
lockL = 40;
blockHeight = 10;
blockDepth = 15;

grooveThickness = 2;
grooveDepth = 3;
grooves = [0,0];

clampThickness = 1;
clampHeight = blockHeight-0.2;



//block();
color("lightGreen") clamp();

module clamp(){
	difference(){
		union(){
			baseExtension = 10;
			//Left end block
			translate([hingeL+5,5,0])
				cube([10,blockDepth+baseExtension,clampHeight], center=true);
			
			//Left rounded corner
			translate([hingeL-(baseExtension-clampThickness)/2,blockDepth/2+baseExtension-(baseExtension-clampThickness)/2,0])
				rotate([0,0,90])
					roundedCorner(clampHeight, baseExtension-clampThickness);
			
			//Clamp main length
			translate([0,blockDepth/2+clampThickness/2,0])
				cube([hingeL+lockL,clampThickness,clampHeight], center=true);
			
			//Right latch pieces
			//Right end block
			//translate([-hingeL-2.5,0,0])
			//	cube([5,10,clampHeight], center=true);
		}
		translate([hingeL-1,-1.5,0])
			rotate([90,0,90])
				slot(3.2,6,20);
		
	}
}

module block(){
	difference(){
		union(){
			//Main body
			cube([hingeL+lockL, blockDepth, blockHeight], center=true);
			//Top and bottom plates
			color("orange")
			for (i=grooves){
				translate([0,grooveDepth/2,(-1+2*i)*(blockHeight/2+grooveThickness/2)])
					cube([hingeL+lockL, blockDepth+grooveDepth, grooveThickness], center=true);
			}
		}
		//V-groove cutout
		translate([0,blockDepth/2,0])
			rotate([0,0,45])
				rightTriangle(10,10,blockHeight*2);
		
		//Left bolt hole
		translate([hingeL-19,0,0])
			rotate([90,0,90])
				slot(2.8,2.8,20);
		
		//Right bolt hole
		translate([-hingeL-1,0,0])
			rotate([90,0,90])
				slot(2.8,2.8,20);
	}
}