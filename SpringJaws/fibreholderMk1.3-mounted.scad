use <agentscad/mx-screw.scad>
use <agentscad/mx-thread.scad>


//translate([0,0,-20])import("C:/Users/User/Downloads/sample_riser_LS10 (1).stl");

//shapes();
//difference(){
    pincer();
  //  translate ([6,0,10]) cube([20,60,30], center=true);
//}
module shapes() {
    difference(){
        //Holder
     translate([5,0,10])
        //color("cyan") 
            cube([15,50,20], center=true);         
   //Cutout    
    translate ([-0,0,-25]) 
        linear_extrude (height = 50)
            polygon( points=[[-12.6,12.6],[0,0],[-12.6,-12.6]] ); 
    
     #translate([-2,0,18]) cube([4,4,2], center=true);
     #translate([-2,0,10]) cube([4,4,2], center=true);
     #translate([-2,0,2]) cube([4,4,2], center=true);   
 /*
//M3 screw cutouts
     translate([-15,36.5,18]) rotate ([0,90,0]) m3stud();
     translate([-15,-36.5,18]) rotate ([0,90,0]) m3stud();
     translate([-15,36.5,2]) rotate ([0,90,0]) m3stud();
     translate([-15,-36.5,2]) rotate ([0,90,0]) m3stud();;
*/
//cylinder cutouts
     translate([-0,20,17]) rotate ([0,90,0]) cylinder(d=3, h=15, center=true, $fn=100);
     translate([-0,-20,17]) rotate ([0,90,0]) cylinder(d=3, h=15, center=true, $fn=100);
     translate([-0,20,8]) rotate ([0,90,0]) cylinder(d=3, h=15, center=true, $fn=100);
     translate([-0,-20,8]) rotate ([0,90,0]) cylinder(d=3, h=15, center=true, $fn=100);

        }
    //Fibre
    translate ([-0.2,0,5])
        cylinder (h=30, r=0.1,center=true, $fn=100)  ;

    //Slide
    //translate([0,0,20.5]) slide();
     
    //legs
    difference(){
        //legs
        union(){
            translate([0,17.3,2]) cube([45,7,4], center=true);
            translate([0,-17.3,2]) cube([45,7,4], center=true);  
        }
        //M3 holes
        translate([-17.3,17.3,1.5]) M3hole();
        translate([-17.3,-17.3,1.5]) M3hole();
        translate([17.3,17.3,1.5]) M3hole();
        translate([17.3,-17.3,1.5]) M3hole();
    }
        
    color("cyan") translate([-10,0,0]) pincer();
    
   
    }


module slide(){
    color("white",0.5)
       cube([25,75,1], center=true);
}


module pincer(){
    //Tips
    difference(){
        translate([0,0,10]) cube([3,4,20], center=true);
        //cutouts
        translate([0,0,20]) cube([5,8,2], center=true);
        translate([0,0,14]) cube([5,8,6], center=true);
        translate([0,0,6]) cube([5,8,6], center=true);
        translate([0,0,0]) cube([5,8,2], center=true);
    }
    //center
    translate([-5.5,0,10]) cube([8,8,20], center=true);
    
    //spring
    difference(){
        union(){
            //plate
            translate([-7,0,10]) cube([0.6,50,20], center=true);
            translate([-3.5,0,10]) cube([0.6,50,20], center=true);
            //end blocks
            translate([-5.5,20,10]) cube([8,10,20], center=true);
            translate([-5.5,-20,10]) cube([8,10,20], center=true);
        }
        //spring end cutouts
        translate([-7,17, 10]) cube([3,3,25], center=true);
        translate([-7,15, 12]) cube([3,3,10], center=true);
        
        translate([-7,-17, 10]) cube([3,3,25], center=true);
        translate([-7,-15, 12]) cube([3,3,10], center=true);
        
        //M3 cutouts
        translate([-7.5,22,17]) rotate([0,90,0]) M3slot();
        translate([-7.5,22,8]) rotate([0,90,0]) M3slot();
        translate([-7.5,-19,17]) rotate([0,90,0]) M3slot();
        translate([-7.5,-19,8]) rotate([0,90,0]) M3slot();
        
        //plate cutouts
        translate([-8,9.5,12]) cube([12,10.9,10], center=true);
        translate([-8,-9.5,12]) cube([12,10.9,10], center=true);
        
        //leg cutout
        translate([0,15,2]) cube([40,22,4.5], center=true);
        translate([0,-15,2]) cube([40,22,4.5], center=true);
        
    }
}

//translate([0,0,30]) M3hole();

module M3hole(){
    translate([0,0,7.5]) cylinder(d=6, h=15, center=true, $fn=50);
    translate([0,0,-7.5]) cylinder(d=3, h=15, center=true, $fn=50);
}
module M3slot(){
    linear_extrude(height=14,center=true)
        union(){ 
            circle(d=3,$fn=30);
            translate([0,-3]) circle(d=3,$fn=30);
            translate([0,-1.5]) square(3,center=true);   
        }
}

module m3stud(){
    difference(){
        #mxBoltHexagonalThreaded( M3() ,$fn=20);
        translate([0,0,18]) cylinder(d=4, h=5, center=true);
        translate([0,0,-2]) cylinder(d=10, h=5, center=true);
     }
 }




