use <agentscad/mx-screw.scad>
use <agentscad/mx-thread.scad>


shapes();

module shapes() {
    difference(){
        //Holder
     translate([5,0,10])
        color("cyan") 
            cube([35,80,20], center=true);         
   //Cutout    
    translate ([-10,0,-1]) 
        linear_extrude (height = 100)
            polygon( points=[[-12.6,12.6],[0,0],[-12.6,-12.6]] ); 
    
     translate([-12,0,18]) cube([4,4,2], center=true);
     translate([-12,0,10]) cube([4,4,2], center=true);

 /*
//M3 screw cutouts
     translate([-15,36.5,18]) rotate ([0,90,0]) m3stud();
     translate([-15,-36.5,18]) rotate ([0,90,0]) m3stud();
     translate([-15,36.5,2]) rotate ([0,90,0]) m3stud();
     translate([-15,-36.5,2]) rotate ([0,90,0]) m3stud();;
*/
//cylinder cutouts
     translate([-15,35.5,17]) rotate ([0,90,0]) cylinder(d=3, h=15, center=true, $fn=100);
     translate([-15,-35.5,17]) rotate ([0,90,0]) cylinder(d=3, h=15, center=true, $fn=100);
     translate([-15,35.5,3]) rotate ([0,90,0]) cylinder(d=3, h=15, center=true, $fn=100);
     translate([-15,-35.5,3]) rotate ([0,90,0]) cylinder(d=3, h=15, center=true, $fn=100);

        }
    //Fibre
    translate ([-10.2,0,55])
        cylinder (h=30, r=0.1,center=true, $fn=100)  ;

    //Slide
    translate([0,0,20.5])
        color("white",0.5)
            cube([25,75,1], center=true);
    
    
    //Ramp
    translate([-11,0,4])
        difference(){
            translate([-5, 0,0])
                cube([20,5,8], center=true);
            translate([-5,0,4]) rotate([90,90,0])
                rotate_extrude(convexity=2, angle = 90, $fn=100)
                    translate([5,0,0])
                        circle(r=1);
            translate([-35,0,-1]) rotate([0,90,0])
                cylinder(r=1, h=30, $fn=50);
            //translate([-4,3,2.5]) rotate([90,0,0])
              //  cylinder(h=6, r=5, $fn=50);
            
            //translate ([-19,0,-5])
              //  cube([25,7,10]);
        }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    pincer();
    mirror([0,1,0]) pincer();
   
    }


module pincer(){
    translate([-24,0,0])
    union(){
        //Tip piece
        difference(){
            linear_extrude(height=20) polygon(points=[[0.5,2],[3,2],[3,0],[0,0]]);
            
            translate([3,0,20]) cube([5,8,2], center=true);
            translate([3,0,14]) cube([5,8,6], center=true);
            translate([3,0,6]) cube([5,8,6], center=true);
            translate([3,0,0]) cube([5,8,2], center=true);
        
        }
        
        difference(){
        //Spring
            linear_extrude(height=20)
                translate([-0,0,0]) rotate([0,0,0])
                    polygon(points=[[0,40],[0.5,40],[0.5,20],[0.5,0],[-3,0],[-3,5],[0,5],[-0,13],[-3,13],[-3,23],[-0,23]]);
        
        //Square cut out    
        translate([0,18,10]) 
            cube([10,25,12], center=true);
        //M3 cut outs
        translate([0,37,17]) rotate([0,90,0])    
            linear_extrude(height=6,center=true)
            union(){
                
                circle(d=3,$fn=30);
                translate([0,-3]) circle(d=3,$fn=30);
                translate([0,-1.5]) square(3,center=true);     
         };
         translate([0,37,3]) rotate([0,90,0])    
            linear_extrude(height=6,center=true)
            union(){
                circle(d=3,$fn=30);
                translate([0,-3]) circle(d=3,$fn=30);
                translate([0,-1.5]) square(3,center=true);     
         };
        }
    }
}


module m3stud(){
    difference(){
        #mxBoltHexagonalThreaded( M3() ,$fn=20);
        translate([0,0,18]) cylinder(d=4, h=5, center=true);
        translate([0,0,-2]) cylinder(d=10, h=5, center=true);
     }
 }




