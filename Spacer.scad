include <cyl_head_bolt.scad>;
include <materials.scad>;



wallthicknessabstract =21;
wallthickness = wallthicknessabstract*.7;
wallHeight = 70;
bottomheight = 11;
renderNutsOnBottom = true;
printerTolerance = .1;
nutheight = 8.25;
screwHoleSupportSize = 20;
bottomScrewHoleWallSize = 4;
bottomScrewHoleWallHeight = 5;

//mode 1 is for the left wall, mode 2 is for the right wall (It's realy interchangable though), mode 3 is for mirror version of 1,mode 4 is for bottom
mode = 1;
//enable for mode 3, I have not figured out how to do this programatically yet
//translate([300,0,0])mirror([1,0,0,])

if (mode != 4){
union(){
difference() {
union() {
union(){
   for (i = [0:.6:wallthicknessabstract]){
      //use the imported svg file to generate the wall
      translate([349.2335,138.2555,0]) linear_extrude(wallHeight)
      resize([698.466-i,276.511-(i*1.3),0], auto = true)
   import (file = "RefrenceForSpacerSCADdontMake.svg", convexity=3,center = true);

   }
    
    
}


   //screw boxes
translate([139.238,20,wallHeight/2]) cube([screwHoleSupportSize,screwHoleSupportSize,wallHeight],center =true);
translate([279.235,20.013,wallHeight/2]) cube([screwHoleSupportSize,screwHoleSupportSize,wallHeight],center =true);

translate([60.181,161.300,wallHeight/2]) rotate([0,0,65])cube([screwHoleSupportSize,screwHoleSupportSize,wallHeight],center =true);
translate([209.237,258.519,wallHeight/2]) cube([screwHoleSupportSize,screwHoleSupportSize,wallHeight],center =true);
translate([349.233,258.519,wallHeight/2]) cube([screwHoleSupportSize,screwHoleSupportSize,wallHeight],center =true);




}

if (mode == 2){
    translate([0,-1,-1]) cube ([279.235+15,500,1000]); 
    translate([400.295,-1,-1]) cube ([1000,500,1000]); 
    radius = (wallthickness/2)-((wallthickness/2)*.30);
    //circle at the end to connect the two walls
    linear_extrude(wallHeight)translate ([279.235+15+(radius*.80),((wallthickness/2)),0]) circle(r = radius+printerTolerance);
    linear_extrude(wallHeight)translate ([279.235+15+(radius*.80),278.511-((wallthickness/2)+(radius/2)),0]) circle(r = radius+printerTolerance);
    linear_extrude(wallHeight)translate ([400.295-(radius*.80),((wallthickness/2)),0]) circle(r = radius+printerTolerance);
    linear_extrude(wallHeight)translate ([400.295-(radius*.80),278.511-((wallthickness/2)+(radius/2)),0]) circle(r = radius+printerTolerance);

}
else{translate([279.235+15,-1,-1]) cube ([1000,500,1000]); }

//screw holes
linear_extrude(wallHeight) translate([139.238,20,0]) circle(r = 4);
linear_extrude(wallHeight) translate([279.235,20.013,0]) circle(r = 4);
linear_extrude(wallHeight) translate([60.181,161.300,0]) circle(r = 4);
linear_extrude(wallHeight) translate([209.237,258.519,0]) circle(r = 4);
linear_extrude(wallHeight) translate([349.233,258.519,0]) circle(r = 4);


}

if (mode !=2){
    radius = (wallthickness/2)-((wallthickness/2)*.30);
    //circle at the end to connect the two walls
    linear_extrude(wallHeight)translate ([279.235+15+(radius*.80),((wallthickness/2)),0]) circle(r = radius);
    linear_extrude(wallHeight)translate ([279.235+15+(radius*.80),278.511-((wallthickness/2)+(radius/2)),0]) circle(r = radius);
    

}
}
}
else{


//really lazy way of doing this
difference(){
union(){
for (i = [0:.5:60]){
      //use the imported svg file to generate the wall
      translate([349.2335,138.2555,0]) linear_extrude(bottomheight)
      resize([698.466-i,276.511-(i*1.3),0], auto = true)
   import (file = "RefrenceForSpacerSCADdontMake.svg", convexity=3,center = true);

   }
difference(){
union(){
translate([139.238,20,bottomheight+(bottomScrewHoleWallHeight/2)]) cube([screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,bottomScrewHoleWallHeight],center =true);
translate([279.235,20.013,bottomheight+(bottomScrewHoleWallHeight/2)]) cube([screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,bottomScrewHoleWallHeight],center =true);

translate([60.181,161.300,bottomheight+(bottomScrewHoleWallHeight/2)]) rotate([0,0,65])cube([screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,bottomScrewHoleWallHeight],center =true);
translate([209.237,258.519,bottomheight+(bottomScrewHoleWallHeight/2)]) cube([screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,bottomScrewHoleWallHeight],center =true);
translate([349.233,258.519,bottomheight+(bottomScrewHoleWallHeight/2)]) cube([screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,bottomScrewHoleWallHeight],center =true);
translate([489.251,258.498,bottomheight+(bottomScrewHoleWallHeight/2)]) cube([screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,bottomScrewHoleWallHeight],center =true);
translate([559.249,20.013,bottomheight+(bottomScrewHoleWallHeight/2)]) cube([screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,bottomScrewHoleWallHeight],center =true);
translate([419.253,20.013,bottomheight+(bottomScrewHoleWallHeight/2)]) cube([screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,bottomScrewHoleWallHeight],center =true);
translate([638.306,161.279,bottomheight+(bottomScrewHoleWallHeight/2)]) rotate([0,0,-65])cube([screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,bottomScrewHoleWallHeight],center =true);}

union(){
translate([139.238,20,wallHeight/2]) cube([screwHoleSupportSize+printerTolerance,screwHoleSupportSize+printerTolerance,wallHeight],center =true);
translate([279.235,20.013,wallHeight/2]) cube([screwHoleSupportSize+printerTolerance,screwHoleSupportSize+printerTolerance,wallHeight],center =true);

translate([60.181,161.300,wallHeight/2]) rotate([0,0,65])cube([screwHoleSupportSize+printerTolerance,screwHoleSupportSize+printerTolerance,wallHeight],center =true);
translate([209.237,258.519,wallHeight/2]) cube([screwHoleSupportSize+printerTolerance,screwHoleSupportSize+printerTolerance,wallHeight],center =true);
translate([349.233,258.519,wallHeight/2]) cube([screwHoleSupportSize+printerTolerance,screwHoleSupportSize+printerTolerance,wallHeight],center =true);
translate([489.251,258.498,wallHeight/2]) cube([screwHoleSupportSize+printerTolerance,screwHoleSupportSize+printerTolerance,wallHeight],center =true);
translate([559.249,20.013,wallHeight/2]) cube([screwHoleSupportSize+printerTolerance,screwHoleSupportSize+printerTolerance,wallHeight],center =true);
translate([419.253,20.013,wallHeight/2]) cube([screwHoleSupportSize+printerTolerance,screwHoleSupportSize+printerTolerance,wallHeight],center =true);
translate([638.306,161.279,wallHeight/2]) rotate([0,0,-65])cube([screwHoleSupportSize+printerTolerance,screwHoleSupportSize+printerTolerance,wallHeight],center =true);
}
union(){
   for (i = [0:.6:wallthicknessabstract]){
      //use the imported svg file to generate the wall
      translate([349.2335,138.2555,0]) linear_extrude(wallHeight)
      resize([698.466-i,276.511-(i*1.3),0], auto = true)
   import (file = "RefrenceForSpacerSCADdontMake.svg", convexity=3,center = true);

   }
    
    
}
}


translate([100.278,0,0]) cube([500,260,bottomheight]);
linear_extrude(bottomheight)translate([0,0,0]) polygon([[0,68], [110,260],[130,0]]);


linear_extrude(bottomheight)translate([0,0,0]) polygon([[0+694.530,68], [-110+694.530,260],[-130+694.530,0]]);
   
}


if (renderNutsOnBottom){
translate([139.238,20,nutheight])nutcatch_parallel("M8", clh=6.25);
translate([279.235,20.013,nutheight])nutcatch_parallel("M8", clh=6.25);
translate([209.237,258.519,nutheight])nutcatch_parallel("M8", clh=6.25);
translate([60.181,161.300,nutheight])nutcatch_parallel("M8", clh=6.25);
translate([349.233,258.519,nutheight])nutcatch_parallel("M8", clh=6.25);

translate([419.253,20.013,nutheight])nutcatch_parallel("M8", clh=6.25);
translate([559.249,20.013,nutheight])nutcatch_parallel("M8", clh=6.25);
translate([638.306,161.279,nutheight])nutcatch_parallel("M8", clh=6.25);
translate([489.251,258.498,nutheight])nutcatch_parallel("M8", clh=6.25);

}



linear_extrude(20) translate([139.238,20,0]) circle(r = 4);
linear_extrude(20) translate([279.235,20.013,0]) circle(r = 4);
linear_extrude(20) translate([60.181,161.300,0]) circle(r = 4);
linear_extrude(20) translate([209.237,258.519,0]) circle(r = 4);
linear_extrude(20) translate([419.253,20.013,0]) circle(r = 4);
linear_extrude(20) translate([559.249,20.013,0]) circle(r = 4);
linear_extrude(20) translate([638.306,161.279,0]) circle(r = 4);
linear_extrude(20) translate([489.251,258.498,0]) circle(r = 4);
linear_extrude(20) translate([349.233,258.519,0]) circle(r = 4);
}
}