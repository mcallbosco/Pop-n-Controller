include <cyl_head_bolt.scad>;
include <materials.scad>;
use <threads-library-by-cuiso-v1.scad>
module hole_pattern(holex, holey) {
    // Main large cylinder
    translate([holex, holey, 0])
        cylinder(h=88, d=88, center=true);
    
    // Smaller surrounding cylinders
    translate([holex, holey-45.687, 0])
        cylinder(h=88, d=7, center=true);
    translate([holex, holey-43.687, 0])
        cylinder(h=88, d=7, center=true);
    translate([holex, holey+45.687, 0])
        cylinder(h=88, d=7, center=true);
    translate([holex, holey+43.687, 0])
        cylinder(h=88, d=7, center=true);
}
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
DEBUGSHOWALL=true;
topMaterialThickness = 3.175; //in mm, used in bolt calculation

union(){
   for (i = [0:.6:wallthicknessabstract]){
      //use the imported svg file to generate the wall
      translate([349.2335,138.2555,0]) linear_extrude(wallHeight)
      resize([698.466-i,276.511-(i*1.3),0], auto = true)
   import (file = "RefrenceForSpacerSCADdontMake.svg", convexity=3,center = true);

   }
}

//really lazy way of doing this

//really lazy way of doing this
difference(){
union(){
for (i = [0:.5:60]){
      //use the imported svg file to generate the wall
      translate([349.2335,138.2555,0]) linear_extrude(bottomheight)
      resize([698.466-i,276.511-(i*1.3),0], auto = true)
   import (file = "RefrenceForSpacerSCADdontMake.svg", convexity=3,center = true);

   }



translate([100.278,0,0]) cube([500,260,bottomheight]);
linear_extrude(bottomheight)translate([0,0,0]) polygon([[0,68], [110,260],[130,0]]);


linear_extrude(bottomheight)translate([0,0,0]) polygon([[0+694.530,68], [-110+694.530,260],[-130+694.530,0]]);
   
}

hole_pattern(holex = 69.240, holey = 79.257);
hole_pattern(holex = 209.237, holey = 79.257);
hole_pattern(holex = 349.233, holey = 79.257);
hole_pattern(holex = 489.230, holey = 79.257);
hole_pattern(holex = 629.226, holey = 79.257);
hole_pattern(holex = 139.239, holey = 209.254);
hole_pattern(holex = 279.235, holey = 209.254);
hole_pattern(holex = 419.231, holey = 209.254);
hole_pattern(holex = 559.228, holey = 209.254);

}

