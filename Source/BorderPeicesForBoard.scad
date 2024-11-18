//Outer Shell Generation
mode = 3;
difference(){
union(){
union(){
   for (i = [0:.6:10]){
      //use the imported svg file to generate the wall
      translate([349.2335,138.2555,0]) linear_extrude(.2)
      resize([698.466-i,276.511-(i*.5),0], auto = true)
   import (file = "RefrenceForSpacerSCADdontMake.svg", convexity=3,center = true);

   }
    
    
}
union(){
   for (i = [0:.6:3]){
      //use the imported svg file to generate the wall
      translate([349.2335,138.2555,-4]) linear_extrude(4.2)
      resize([698.466+i,276.511+(i*1.3),0], auto = true)
   import (file = "RefrenceForSpacerSCADdontMake.svg", convexity=3,center = true);

   }
    
    
}
}
union(){
   for (i = [0:.6:.6]){
      //use the imported svg file to generate the wall
      translate([349.2335,138.2555,-2.4+.5]) linear_extrude(.4)
      resize([698.466+i,276.511+(i*1.3),0], auto = true)
   import (file = "RefrenceForSpacerSCADdontMake.svg", convexity=3,center = true);

   }}
   union(){
   for (i = [0:.6:.12 ]){
      //use the imported svg file to generate the wall
      translate([349.2335,138.2555,-2.3+.2]) linear_extrude(.2)
      resize([698.466+i,276.511+(i*1.3),0], auto = true)
   import (file = "RefrenceForSpacerSCADdontMake.svg", convexity=3,center = true);

   }}
union(){
   for (i = [0:.6:1.5]){
      //use the imported svg file to generate the wall
      translate([349.2335,138.2555,-1.5]) linear_extrude(1.5)
      resize([698.466+i,276.511+(i*1.3),0], auto = true)
   import (file = "RefrenceForSpacerSCADdontMake.svg", convexity=3,center = true);

   }}
   if (mode == 1){
translate([279.235+15,-10,-10]) cube ([1000,500,1000]);}
if (mode == 2){
translate([-2,-10,-10]) cube ([279.235+15+2,500,1000]); 
    translate([400.295,-10,-10]) cube ([1000,500,1000]); }
if (mode == 3){
translate([-3,-10,-10]) cube ([400.295+3,500,1000]); 

}
}
    
    
    
    
