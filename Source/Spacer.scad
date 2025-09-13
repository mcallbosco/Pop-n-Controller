// Original file includes provided by user
include <cyl_head_bolt.scad>;
include <materials.scad>;
use <threads-library-by-cuiso-v1.scad>

//=====================================================================
//== Configuration for Splitting and Printing
//=====================================================================

// Set which part to render for export.
// Bottom Row: 1=Left, 2=Mid-Left, 3=Mid-Right, 4=Right
// Top Row:    5=Left, 6=Mid-Left, 7=Mid-Right, 8=Right
// Part 9 is the printable dowel pin.
part_to_render = 1; // [1:9]

// --- Split line coordinates ---
// CORRECTED: Cuts are now made at the exact center of existing holes
// to ensure clean splits, creating a 4x2 grid of parts.
x_cut1 = 139.239;  // Center of hole pattern
x_cut2 = 349.233;  // Center of hole pattern
x_cut3 = 559.228;  // Center of hole pattern
y_cut1 = 138.2555; // This is the vertical centerline of the model

// --- Assembly Dowel Parameters ---
dowel_d = 5;          // Diameter of the dowel pins (in mm)
dowel_hole_depth = 10;  // Depth of the hole on each side
printer_tolerance = 0.2; // Clearance for the dowel. Adjust for a looser/tighter fit.

//=====================================================================
//== Original Model Definition
//=====================================================================

module original_model() {
    // Original variables
    wallthicknessabstract = 21;
    wallHeight = 70; //in mm
    bottomheight = 5.5; //in mm

    module hole_pattern(holex, holey) {
        translate([holex, holey, 0]) cylinder(h = 88, d = 88, center = true);
        translate([holex, holey - 45.687, 0]) cylinder(h = 88, d = 7, center = true);
        translate([holex, holey - 43.687, 0]) cylinder(h = 88, d = 7, center = true);
        translate([holex, holey + 45.687, 0]) cylinder(h = 88, d = 7, center = true);
        translate([holex, holey + 43.687, 0]) cylinder(h = 88, d = 7, center = true);
    }
    union() {
        for (i = [0:.6:wallthicknessabstract]) {
            translate([349.2335, 138.2555, 0]) linear_extrude(wallHeight)
            resize([698.466 - i, 276.511 - (i * 1.3), 0], auto = true)
            import (file = "RefrenceForSpacerSCADdontMake.svg", convexity = 3, center = true);
        }
        difference() {
            union() {
                for (i = [0:.5:60]) {
                    translate([349.2335, 138.2555, 0]) linear_extrude(bottomheight)
                    resize([698.466 - i, 276.511 - (i * 1.3), 0], auto = true)
                    import (file = "RefrenceForSpacerSCADdontMake.svg", convexity = 3, center = true);
                }
                translate([100.278, 0, 0]) cube([500, 260, bottomheight]);
                linear_extrude(bottomheight) polygon([[0, 68], [110, 260], [130, 0]]);
                linear_extrude(bottomheight) polygon([[694.530, 68], [584.530, 260], [564.530, 0]]);
            }
            hole_pattern(69.240, 79.257); hole_pattern(209.237, 79.257);
            hole_pattern(349.233, 79.257); hole_pattern(489.230, 79.257);
            hole_pattern(629.226, 79.257); hole_pattern(139.239, 209.254);
            hole_pattern(279.235, 209.254); hole_pattern(419.231, 209.254);
            hole_pattern(559.228, 209.254);
        }
    }
}

//=====================================================================
//== Dowel and Splitting Logic
//=====================================================================

dowel_hole_d = dowel_d + printer_tolerance;

// -- Dowel modules for vertical seams (X-cuts)
// Dowels are now placed *around* the large holes.
module dowels_at_x_cuts() {
    for (cut_x = [x_cut1, x_cut2, x_cut3]) {
        for (z_pos = [20, 50]) { // Two heights for stability
            // Y positions are chosen to be outside the 88mm diameter holes
            for (y_pos = [30, 130, 150, 250]) {
                translate([cut_x, y_pos, z_pos]) rotate([0, 90, 0]) 
                    cylinder(d = dowel_hole_d, h = dowel_hole_depth * 2, center = true, $fn = 16);
            }
        }
    }
}

// -- Dowel module for the horizontal seam (Y-cut)
module dowels_at_y1() {
    for (x_pos = [50, 200, 280, 450, 500, 650]) {
        translate([x_pos, y_cut1, wallHeight / 2]) rotate([90, 0, 0]) 
            cylinder(d = dowel_hole_d, h = dowel_hole_depth * 2, center = true, $fn = 16);
    }
}

// -- Module to generate a single dowel pin for printing
module printable_dowel() {
    echo("Rendering one dowel pin.");
    rotate([90,0,0]) cylinder(h = dowel_hole_depth * 2 - printer_tolerance, d = dowel_d, center = true, $fn=32);
}

//=====================================================================
//== Part Selection and Rendering
//=====================================================================

total_x = 698.466; total_y = 276.511; total_z = 100;

if (part_to_render >= 1 && part_to_render <= 8) {
    difference() {
        // First, cut out the main shape of the selected part
        intersection() {
            original_model();
            if (part_to_render == 1) { translate([0, 0, 0]) cube([x_cut1, y_cut1, total_z]); }
            if (part_to_render == 2) { translate([x_cut1, 0, 0]) cube([x_cut2 - x_cut1, y_cut1, total_z]); }
            if (part_to_render == 3) { translate([x_cut2, 0, 0]) cube([x_cut3 - x_cut2, y_cut1, total_z]); }
            if (part_to_render == 4) { translate([x_cut3, 0, 0]) cube([total_x - x_cut3, y_cut1, total_z]); }
            if (part_to_render == 5) { translate([0, y_cut1, 0]) cube([x_cut1, total_y - y_cut1, total_z]); }
            if (part_to_render == 6) { translate([x_cut1, y_cut1, 0]) cube([x_cut2 - x_cut1, total_y - y_cut1, total_z]); }
            if (part_to_render == 7) { translate([x_cut2, y_cut1, 0]) cube([x_cut3 - x_cut2, total_y - y_cut1, total_z]); }
            if (part_to_render == 8) { translate([x_cut3, y_cut1, 0]) cube([total_x - x_cut3, total_y - y_cut1, total_z]); }
        }

        // Second, subtract the dowel holes for the appropriate faces
        // Holes are added to the parts with the "lower" coordinates at each seam
        if (part_to_render == 1 || part_to_render == 2 || part_to_render == 3 || part_to_render == 5 || part_to_render == 6 || part_to_render == 7) {
            dowels_at_x_cuts();
        }
        if (part_to_render == 1 || part_to_render == 2 || part_to_render == 3 || part_to_render == 4) {
            dowels_at_y1();
        }
    }
} else if (part_to_render == 9) {
    printable_dowel();
} else {
    echo("Invalid part_to_render selected! Please choose a value from 1 to 9.");
    %original_model(); // Show the full model with cut lines for reference
}