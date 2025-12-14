// Original file includes provided by user
include <cyl_head_bolt.scad>;
include <materials.scad>;
use <threads-library-by-cuiso-v1.scad>
use <Connector.scad>

//=====================================================================
//== Configuration for Splitting and Printing
//=====================================================================

// Set which part to render for export.
// Bottom Row: 1=Left, 2=Mid-Left, 3=Mid-Right, 4=Right
// Top Row:    5=Left, 6=Mid-Left, 7=Mid-Right, 8=Right
// Part 9 is the printable dowel pin.
// Part 10 is the printable connector.
part_to_render = 10; // [1:10]

// --- Split line coordinates ---
// creating a 4x2 grid of parts.
// Separate cuts for top and bottom rows to avoid holes
x_cut_bottom_1 = 139.239;
x_cut_bottom_2 = 279.235;
x_cut_bottom_3 = 559.228;

x_cut_top_1 = 209.237;
x_cut_top_2 = 349.233;
x_cut_top_3 = 489.230;

y_cut1 = 138.2555; // This is the vertical centerline of the model

// --- Assembly Dowel Parameters ---
dowel_d = 5;          // Diameter of the dowel pins (in mm)
dowel_hole_depth = 10;  // Depth of the hole on each side
printer_tolerance = 0.2; // Clearance for the dowel. Adjust for a looser/tighter fit.

// --- Connector Parameters ---
conn_len = 30;
conn_width = 10;
conn_height = 5;
conn_z_pos = 4; // Centered in the 8mm bottom plate

//=====================================================================
//== Original Model Definition
//=====================================================================

module original_model() {
    // Original variables
    wallthicknessabstract = 21;
    wallHeight = 70; //in mm
    bottomheight = 8; //in mm

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
module dowels_bottom() {
    for (cut_x = [x_cut_bottom_1, x_cut_bottom_2, x_cut_bottom_3]) {
        for (z_pos = [20, 50]) { // Two heights for stability
            // Y positions are chosen to be outside the 88mm diameter holes
            for (y_pos = [30, 130]) {
                translate([cut_x, y_pos, z_pos]) rotate([0, 90, 0]) 
                    cylinder(d = dowel_hole_d, h = dowel_hole_depth * 2, center = true, $fn = 16);
            }
        }
    }
}

module dowels_top() {
    for (cut_x = [x_cut_top_1, x_cut_top_2, x_cut_top_3]) {
        for (z_pos = [20, 50]) { // Two heights for stability
            // Y positions are chosen to be outside the 88mm diameter holes
            for (y_pos = [150, 250]) {
                translate([cut_x, y_pos, z_pos]) rotate([0, 90, 0]) 
                    cylinder(d = dowel_hole_d, h = dowel_hole_depth * 2, center = true, $fn = 16);
            }
        }
    }
}

// -- Dowel module for the horizontal seam (Y-cut)
module dowels_at_y1() {
    // Adjusted 280 to 314 to avoid cut line at 279.235
    for (x_pos = [50, 200, 314, 450, 500, 650]) {
        translate([x_pos, y_cut1, wallHeight / 2]) rotate([90, 0, 0]) 
            cylinder(d = dowel_hole_d, h = dowel_hole_depth * 2, center = true, $fn = 16);
    }
}

// -- Module to generate a single dowel pin for printing
module printable_dowel() {
    echo("Rendering one dowel pin.");
    rotate([90,0,0]) cylinder(h = dowel_hole_depth * 2 - printer_tolerance, d = dowel_d, center = true, $fn=32);
}

// -- Connector Modules
module connectors_bottom() {
    for (cut_x = [x_cut_bottom_1, x_cut_bottom_2, x_cut_bottom_3]) {
        // Place connectors in the flat part (Z=4)
        // Avoid button holes.
        for (y_pos = [30, 110]) {
            translate([cut_x, y_pos, conn_z_pos]) 
                UniversalConnectorCutout(length=conn_len, width=conn_width, height=conn_height);
        }
    }
}

module connectors_top() {
    for (cut_x = [x_cut_top_1, x_cut_top_2, x_cut_top_3]) {
        for (y_pos = [160, 240]) {
            translate([cut_x, y_pos, conn_z_pos]) 
                UniversalConnectorCutout(length=conn_len, width=conn_width, height=conn_height);
        }
    }
}

module connectors_at_y1() {
    // Along the horizontal seam
    for (x_pos = [50, 200, 314, 450, 500, 650]) {
        translate([x_pos, y_cut1, conn_z_pos]) 
            rotate([0, 0, 90])
            UniversalConnectorCutout(length=conn_len, width=conn_width, height=conn_height);
    }
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
            if (part_to_render == 1) { translate([0, 0, 0]) cube([x_cut_bottom_1, y_cut1, total_z]); }
            if (part_to_render == 2) { translate([x_cut_bottom_1, 0, 0]) cube([x_cut_bottom_2 - x_cut_bottom_1, y_cut1, total_z]); }
            if (part_to_render == 3) { translate([x_cut_bottom_2, 0, 0]) cube([x_cut_bottom_3 - x_cut_bottom_2, y_cut1, total_z]); }
            if (part_to_render == 4) { translate([x_cut_bottom_3, 0, 0]) cube([total_x - x_cut_bottom_3, y_cut1, total_z]); }
            if (part_to_render == 5) { translate([0, y_cut1, 0]) cube([x_cut_top_1, total_y - y_cut1, total_z]); }
            if (part_to_render == 6) { translate([x_cut_top_1, y_cut1, 0]) cube([x_cut_top_2 - x_cut_top_1, total_y - y_cut1, total_z]); }
            if (part_to_render == 7) { translate([x_cut_top_2, y_cut1, 0]) cube([x_cut_top_3 - x_cut_top_2, total_y - y_cut1, total_z]); }
            if (part_to_render == 8) { translate([x_cut_top_3, y_cut1, 0]) cube([total_x - x_cut_top_3, total_y - y_cut1, total_z]); }
        }

        // Second, subtract the dowel holes for the appropriate faces
        // Holes are added to all parts at the seams
        if (part_to_render >= 1 && part_to_render <= 4) {
            dowels_bottom();
            connectors_bottom();
        }
        if (part_to_render >= 5 && part_to_render <= 8) {
            dowels_top();
            connectors_top();
        }
        if (part_to_render >= 1 && part_to_render <= 8) {
            dowels_at_y1();
            connectors_at_y1();
        }
    }
} else if (part_to_render == 9) {
    printable_dowel();
} else if (part_to_render == 10) {
    echo("Rendering one connector.");
    UniversalConnector(length=conn_len, width=conn_width, height=conn_height);
} else {
    echo("Invalid part_to_render selected! Please choose a value from 1 to 10.");
    %original_model(); // Show the full model with cut lines for reference
}