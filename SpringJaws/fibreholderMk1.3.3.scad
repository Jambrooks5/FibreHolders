use <agentscad/mx-screw.scad>
use <agentscad/mx-thread.scad>


//translate([0,0,-20])import("C:/Users/User/Downloads/sample_riser_LS10 (1).stl");

///CALLING TESTS
shapes();
/*
difference(){
    pincer();
    #translate ([12,0,10]) cube([20,60,30], center=true);
    translate ([-9,0,1]) cube([30,80,30], center=true);
}*/
//translate([-11.5,34,15]) cube([5,10,10], center=true);
//translate([-11.5,-34,15]) cube([5,10,10], center=true);
/*
intersection(){
    shapes();
    //translate([0,0,18]) cube([5,15,10], center=true);
    //translate([-11,0,18]) cube([5,15,10], center=true);
}*/

//Spring with dovetail cutout
/*difference(){
    pincer();
    
    union(){
    #translate([-5,0,7])
        rotate([0,0,270])
            isoTriangle(15,5,30);
    #translate([2.51,0,7])
        cube([8,8,30], center=true);
    }
}*/

//Jaws with dovetail cutout
/*intersection(){
    pincer();
    
    union(){
    #translate([-5,0,7])
        rotate([0,0,270])
            isoTriangle(15,5,30);
    #translate([2.51,0,7])
        cube([8,8,30], center=true);
    }
}*/

//shapes();
//pincer();

//Main body with jaw cutout
/*difference(){
    shapes();
    translate([5,0,7]) 
        rotate([0,0,90]) 
            isoTriangle(40,15,30);
}*/
//Jaws only
/*intersection(){
    shapes();
    translate([5,0,7]) 
        rotate([0,0,90]) 
            isoTriangle(40,15,30);
}*/

module chunkyArms(){
    //chunky arms
    difference(){
        translate([-2.5,25,12])
           rightTriangle(25,25,10,-0.24);
        translate ([-9,52,12]) cube([10,10,11], center=true);
    
            //Spring bolt slots
        
    
    
         }
     //Hands
     difference(){
        translate([-20,43,12]) //End of arm
            rotate([0,0,0])
                cube([30,8,10], center=true);
         translate([-28,42,12]) //M3 slot in arm
            rotate([0,90,90]) 
                M3slot(18,15);
         translate([-21,43,12]) //Nut slot in arm
            rotate([])
                cube([30,2.4,5.6], center=true);
     }
     //Wrist reinforcement
     //#translate([-3,35,12])
       // rotate([0,0,-60])
         //   cube([15,8,10], center=true);
}

module shapes() {
    difference(){
        //Holder body
         union(){
             //main chunk
             translate([10,0,10])
                 cube([25,50,20], center=true); 
             
             translate([0,0,3]) chunkyArms();
             translate([0,0,-7]) chunkyArms();
     
             mirror ([0,1,0])translate([0,0,3]) chunkyArms();
             mirror ([0,1,0])translate([0,0,-7]) chunkyArms();
         }     
       //Cutouts  
       //Groove  
        translate ([-0,0,-25]) 
            linear_extrude (height = 50)
                polygon( points=[[-12.6,12.6],[0,0],[-12.6,-12.6]] ); 
       //Tooth holes
         translate([-2,0,18]) cube([4,4,2], center=true);
         translate([-2,0,10]) cube([4,4,2], center=true);
         translate([-2,0,2]) cube([4,4,2], center=true);   
       //Bolt holes
         translate([17.3,17.3,10]) cylinder(d=6.5, h=25, center=true, $fn=50);
         translate([17.3,-17.3,10]) cylinder(d=6.5, h=25, center=true, $fn=50);
     /*
    //M3 screw cutouts
         translate([-15,36.5,18]) rotate ([0,90,0]) m3stud();
         translate([-15,-36.5,18]) rotate ([0,90,0]) m3stud();
         translate([-15,36.5,2]) rotate ([0,90,0]) m3stud();
         translate([-15,-36.5,2]) rotate ([0,90,0]) m3stud();;
    *//*
    //cylinder cutouts
         translate([-0,20,17]) rotate ([0,90,0]) cylinder(d=3, h=15, center=true, $fn=100);
         translate([-0,-20,17]) rotate ([0,90,0]) cylinder(d=3, h=15, center=true, $fn=100);
         translate([-0,20,8]) rotate ([0,90,0]) cylinder(d=3, h=15, center=true, $fn=100);
         translate([-0,-20,8]) rotate ([0,90,0]) cylinder(d=3, h=15, center=true, $fn=100);
    */
            }
        
         
        //legs
        difference(){
            //legs
            union(){
                translate([0,17.3,2]) cube([45,10,4], center=true);
                translate([0,-17.3,2]) cube([45,10,4], center=true);  
            }
            //M3 holes
            translate([-17.3,17.3,2.5]) M3hole();
            translate([-17.3,-17.3,2.5]) M3hole();
            translate([17.3,17.3,2.5]) M3hole();
            translate([17.3,-17.3,2.5]) M3hole();
        }
        
    color("cyan") translate([-5,0,0]) pincer();
    
    //Fibre
    translate ([-0.2,0,5])
        cylinder (h=30, r=0.1,center=true, $fn=100)  ;

    //Slide
    //translate([0,0,20.5]) slide();
    }


module slide(){
    color("white",0.5)
       cube([25,75,1], center=true);
}
module pincerTips(){
    difference(){
        translate([0,0,10]) cube([3,4,20], center=true);
        //cutouts
        translate([0,0,20]) cube([5,8,2], center=true);
        translate([0,0,14]) cube([5,8,6], center=true);
        translate([0,0,6]) cube([5,8,6], center=true);
        translate([0,0,0]) cube([5,8,2], center=true);
    }
}

module spring(){
    //springs
    //left top
    difference(){
        cube([20,30,16], center=true);
        cube([19,28,17], center=true);
    }
    
    translate([-7.5,-12,0]) rotate([0,0,0]) corner(16,4);
    translate([7.5,-12,0]) rotate([0,0,90]) corner(16,4);
    translate([7.5,12,0]) rotate([0,0,180]) corner(16,4);
    translate([-7.5,12,0]) rotate([0,0,270]) corner(16,4);
    
}

module pincer(){
    pincerTips();
    
    //springs
    translate([-11.5,19,12]) spring();//top left
    //translate([-11.5,19,6]) spring();//bottom left
    translate([-11.5,-19,12]) spring();//top right
    //translate([-11.5,-19,6]) spring();//bottom right
    
    //center block
    translate([-11.5,0,10]) cube([20,8,20], center=true);
     
    
    //round corners from spring to end blocks
    //topleft
    translate([-15.25,31.75,12]) rotate([0,0,180]) corner(16,2.5);
    translate([-7.75,31.75,12]) rotate([0,0,270]) corner(16,2.5);
    //top right
    translate([-15.25,-31.75,12]) rotate([0,0,90]) corner(16,2.5);
    translate([-7.75,-31.75,12]) rotate([0,0,0]) corner(16,2.5);
    
    //end blocks
    difference(){
        union(){
            translate([-9,34,12])//FrontTopLeft
                rotate([180,0,90])
                    rightTriangle(7.5,5,16);
            translate([-14,34,12])//RTL
                rotate([180,180,270])
                    rightTriangle(7.5,5,16);
            translate([-9,-34,12])//FTR
                rotate([0,0,270])
                    rightTriangle(7.5,5,16);
            translate([-14,-34,12])//RTR
                rotate([180,0,270])
                    rightTriangle(7.5,5,16);
            //Bottom
            /*
            translate([-9,34,6])//FBL
                rotate([180,0,90])
                    rightTriangle(7.5,5,4);
            translate([-14,34,6])//RBL
                rotate([180,180,270])
                    rightTriangle(7.5,5,4);
            translate([-9,-34,6])//FBR
                rotate([0,0,270])
                    rightTriangle(7.5,5,4);
            translate([-14,-34,6])//RBR
                rotate([180,0,270])
                    rightTriangle(7.5,5,4);
            */
            //Blocks
            translate([-11.5,34,12])
                cube([5,10,16], center=true);
            translate([-11.5,-34,12])
                cube([5,10,16], center=true);
                
            translate([-11.5,34,5]) cube([5,10,10], center=true);
            translate([-11.5,-34,5]) cube([5,10,10], center=true);
        }
      
        //M3 cutouts
        #translate([-11.5,39.5,15]) rotate([0,90,90]) M3slot();
        #translate([-11.5,39.5,5]) rotate([0,90,90]) M3slot();
        #translate([-11.5,-39.5,15]) rotate([0,90,90]) M3slot();
        #translate([-11.5,-39.5,5]) rotate([0,90,90]) M3slot();
        
        //leg cutout
        translate([0,15,1.5]) cube([40,22,5], center=true);
        translate([0,-15,1.5]) cube([40,22,5], center=true);
    }
    
}

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



