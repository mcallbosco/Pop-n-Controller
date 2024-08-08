include <cyl_head_bolt.scad>;
include <materials.scad>;
use <threads-library-by-cuiso-v1.scad>

wallthicknessabstract =21;
wallthickness = wallthicknessabstract*.7;
wallHeight = 70; //in mm
bottomheight = 5.5; //in mm
renderNutsOnBottom = true; 
printerTolerance = .1; //in mm
nutheight = 4; //in mm
screwHoleSupportSize = 20;
bottomScrewHoleWallSize = 4; //in mm
bottomScrewHoleWallHeight = 3; //in mm
DEBUGSHOWALL=false;
topMaterialThickness = 3.175; //in mm, used in bolt calculation

//I recomend disabling the middle screw hole, makes it easier to fit things together if your printer/split isn't accurate. 
middleScrewHoleSupport = false;


//mode 1 is for the left wall, mode 2 is for the right wall (It's realy interchangable though), mode 3 is for mirror version of 1,mode 4 is for bottom. READ COMMEND BELOW FOR MODE 3. 
mode = 5;
//enable for mode 3, I have not figured out how to do this programatically yet
//translate([300,0,0])mirror([1,0,0,])

if (!(mode > 3)){
union(){
difference() {
union() {
//Outer Shell Generation
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

if(!DEBUGSHOWALL){
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
}
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

if (mode == 4 || DEBUGSHOWALL){

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
if(middleScrewHoleSupport)
translate([349.233,258.519,bottomheight+(bottomScrewHoleWallHeight/2)]) cube([screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,bottomScrewHoleWallHeight],center =true);
translate([489.251,258.498,bottomheight+(bottomScrewHoleWallHeight/2)]) cube([screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,bottomScrewHoleWallHeight],center =true);
translate([559.249,20.013,bottomheight+(bottomScrewHoleWallHeight/2)]) cube([screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,bottomScrewHoleWallHeight],center =true);
translate([419.253,20.013,bottomheight+(bottomScrewHoleWallHeight/2)]) cube([screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,bottomScrewHoleWallHeight],center =true);
translate([638.306,161.279,bottomheight+(bottomScrewHoleWallHeight/2)]) rotate([0,0,-65])cube([screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,screwHoleSupportSize+printerTolerance+bottomScrewHoleWallSize,bottomScrewHoleWallHeight],center =true);
}

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

if (mode == 5){
thread_for_screw(diameter=7.8, length=topMaterialThickness+1.225+wallHeight+bottomheight+3); 
cylinder(d=13, h=3, $fn=6);
translate([0,20,0])
difference(){
cylinder(d=14 , h=3.5, $fn = 6);  
thread_for_nut(diameter=7.8, length=3.5, usrclearance=printerTolerance); 
}
}