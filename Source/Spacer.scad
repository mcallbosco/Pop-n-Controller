// Original file includes provided by user
include <cyl_head_bolt.scad>;
include <materials.scad>;
use <threads-library-by-cuiso-v1.scad>
use <Connector.scad>

//=====================================================================
//== Configuration for Splitting and Printing
//=====================================================================

// Set which part to render for export.
// Part 0:     ALL PARTS - Assembly view showing all parts at once
// Bottom Row: 1=Left, 2=Mid-Left, 3=Middle, 4=Mid-Right, 5=Right
// Top Row:    6=Left, 7=Mid-Left, 8=Mid-Right, 9=Right
// Part 10 is the printable dowel pin.
// Part 11 is the printable connector.
// Part 12 is a test wall connector rail (for fit testing).
part_to_render = 0; // [0:12]

// Assembly view spacing (only used when part_to_render = 0)
// Set to 0 to see parts fully assembled, increase to separate them
assembly_spacing = 10; // Gap between parts in mm

// --- Split line coordinates ---
// creating a 5x2 grid of parts (5 on bottom, 4 on top).
// Separate cuts for top and bottom rows to avoid holes
x_cut_bottom_1 = 139.239;
x_cut_bottom_2 = 279.235;
x_cut_bottom_3 = 419.231; // New cut to split the large middle part
x_cut_bottom_4 = 559.228;

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
conn_z_pos = 8; // Flush with the top of the 8mm bottom plate

// --- Connector Position Arrays ---
// Edit these arrays to add/remove/move connectors
// Each value is an X coordinate where a connector will be placed

// Connectors along the horizontal middle seam (y_cut1)
// These connect the top row (parts 6-9) to the bottom row (parts 1-5)
conn_middle_x_positions = [60,100, 140,175, 210,245, 280, 280+35, 280+70, 280+110-5,275+110+35, 275+110+70,490, 490+35, 490+70,490+70+35, 490+70+70];

// Y positions for connectors on bottom row vertical seams (parts 1-5)
conn_bottom_y_positions = [45, 110];

// Y positions for connectors on top row vertical seams (parts 6-9)
conn_top_y_positions = [160, 225];

// --- Wall Connector Parameters (Dovetail Rail/Slot) ---
wall_rail_height = 70;       // Vertical span of the rail (matches wall height)
wall_rail_base = 8;          // Widest part of the dovetail
wall_rail_tip = 4;           // Narrowest part of the dovetail (at the neck)
wall_rail_depth = 4;         // Length of the dovetail pin
wall_rail_tolerance = 0.3;   // Clearance for 3D printing fit
wall_center_offset = 7;      // Distance from outer wall edge to center of connector
side_wall_center_offset = 34; // Center of the side walls (approx 21mm thick)
side_wall_right_offset = 34;  // Offset for the right side walls (Parts 5 & 9)
side_wall_rail_base = 6;     // Smaller base for side walls
side_wall_rail_tip = 3;      // Smaller tip for side walls

// --- USB Connector Hole Parameters ---
usb_hole_diameter = 24;      // Diameter of the USB connector hole (in mm)
usb_x_pos = 330;             // X position (centered on the model by default)
usb_z_pos = 40;              // Z position (height from the bottom, centered on wall)

// D-Type screw hole parameters (Neutrik D-series)
usb_screw_hole_diameter = 3.4; // Diameter for M3 heat-set inserts
usb_screw_x_spacing = 19;      // Horizontal distance between screw centers
usb_screw_z_spacing = 24;      // Vertical distance between screw centers

// Module to create USB connector hole cutout on the back wall
module usb_connector_hole() {
    // Back wall is at Y = 276.511, wall thickness is ~21mm
    // We cut through the entire wall thickness
    wall_y = 276.511;
    wall_thickness = 30; // Extra depth to ensure clean cut-through
    
    // Main 24mm opening
    translate([usb_x_pos, wall_y - wall_thickness/2, usb_z_pos])
    rotate([90, 0, 0])
    cylinder(h = wall_thickness, d = usb_hole_diameter, center = true, $fn = 64);

    // D-Type mounting holes (diagonal pair 1: top-left and bottom-right)
    // Horizontal offset: 19/2 = 9.5mm, Vertical offset: 24/2 = 12mm
    for (offset = [[-usb_screw_x_spacing/2, usb_screw_z_spacing/2], 
                   [usb_screw_x_spacing/2, -usb_screw_z_spacing/2]]) {
        translate([usb_x_pos + offset[0], wall_y - wall_thickness/2, usb_z_pos + offset[1]])
        rotate([90, 0, 0])
        cylinder(h = wall_thickness, d = usb_screw_hole_diameter, center = true, $fn = 32);
    }
}

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
    for (cut_x = [x_cut_bottom_1, x_cut_bottom_2, x_cut_bottom_3, x_cut_bottom_4]) {
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
    for (cut_x = [x_cut_bottom_1, x_cut_bottom_2, x_cut_bottom_3, x_cut_bottom_4]) {
        // Place connectors in the flat part (Z=4)
        // Avoid button holes.
        // Original connectors (no rotation)
        for (y_pos = conn_bottom_y_positions) {
            translate([cut_x, y_pos, conn_z_pos]) 
                UniversalConnectorCutout(length=conn_len, width=conn_width, height=conn_height);
        }
        // Flipped connectors between the original ones (rotated 90°)
        for (i = [0 : len(conn_bottom_y_positions) - 2]) {
            midpoint_y = (conn_bottom_y_positions[i] + conn_bottom_y_positions[i + 1]) / 2;
            translate([cut_x, midpoint_y, conn_z_pos]) 
                rotate([0, 0, 90])
                UniversalConnectorCutout(length=conn_len, width=conn_width, height=conn_height);
        }
    }
}

module connectors_top() {
    for (cut_x = [x_cut_top_1, x_cut_top_2, x_cut_top_3]) {
        // Original connectors (no rotation)
        for (y_pos = conn_top_y_positions) {
            translate([cut_x, y_pos, conn_z_pos]) 
                UniversalConnectorCutout(length=conn_len, width=conn_width, height=conn_height);
        }
        // Flipped connectors between the original ones (rotated 90°)
        for (i = [0 : len(conn_top_y_positions) - 2]) {
            midpoint_y = (conn_top_y_positions[i] + conn_top_y_positions[i + 1]) / 2;
            translate([cut_x, midpoint_y, conn_z_pos]) 
                rotate([0, 0, 90])
                UniversalConnectorCutout(length=conn_len, width=conn_width, height=conn_height);
        }
    }
}

module connectors_at_y1() {
    // Along the horizontal seam (middle connectors)
    // Uses conn_middle_x_positions array from configuration section
    // Every other connector is rotated 90 degrees for better interlocking
    for (i = [0 : len(conn_middle_x_positions) - 1]) {
        x_pos = conn_middle_x_positions[i];
        rotation = (i % 2 == 0) ? 90 : 0;  // Alternate: 90, 0, 90, 0, ...
        translate([x_pos, y_cut1, conn_z_pos]) 
            rotate([0, 0, rotation])
            UniversalConnectorCutout(length=conn_len, width=conn_width, height=conn_height);
    }
}

//=====================================================================
//== Wall Dovetail Connectors (Locking Rail and Slot)
//=====================================================================
// These connectors are used on the top/bottom walls (which are straight)
// to help lock adjacent wall pieces together during assembly.
// The rail is a dovetail extrusion that spans vertically on the wall edge.
// The slot is a matching cutout that the rail slides into.

// Dovetail profile for the rail (2D)
// Creates a dovetail shape pointing outward
module wall_rail_profile_2d(base, tip, depth) {
    polygon([
        [0, -tip/2],      // Neck bottom
        [depth, -base/2], // Tip bottom
        [depth, base/2],  // Tip top
        [0, tip/2]        // Neck top
    ]);
}

// Dovetail rail that spans vertically on the wall
// x_pos: X position along the wall
// y_pos: Y position (typically centered in the wall thickness)
// z_start: Starting Z position of the rail
// height: Vertical height of the rail
// rotation: Rotation around Z axis (0 = pointing in +Y direction)
module wall_connector_rail(x_pos, y_pos, z_start, height=wall_rail_height, rotation=0, base=wall_rail_base, tip=wall_rail_tip, depth=wall_rail_depth) {
    translate([x_pos, y_pos, z_start])
    rotate([0, 0, rotation])
    rotate([0, 0, 90])  // Orient to point in Y direction by default
    linear_extrude(height=height)
        wall_rail_profile_2d(base, tip, depth);
}

// Dovetail slot (cutout) that matches the rail
// Same parameters as rail, but slightly larger for tolerance
module wall_connector_slot(x_pos, y_pos, z_start, height=wall_rail_height, rotation=0, base=wall_rail_base, tip=wall_rail_tip, depth=wall_rail_depth, tolerance=wall_rail_tolerance) {
    // Add tolerance for 3D printing fit
    // For a dovetail, we need to expand the shape.
    // Simple way: increase base and tip, keep depth same or slightly deeper.
    slot_base = base + tolerance;
    slot_tip = tip + tolerance; // Neck width
    slot_depth = depth + tolerance/2; // Slightly deeper to avoid bottoming out
    slot_height = height + tolerance; // Vertical clearance if needed
    
    translate([x_pos, y_pos, z_start - tolerance/2])
    rotate([0, 0, rotation])
    rotate([0, 0, 90])  // Orient to point in Y direction by default
    linear_extrude(height=slot_height)
        wall_rail_profile_2d(slot_base, slot_tip, slot_depth);
}

// Convenience module: Rail on bottom wall (Y=0 area)
// side: "left" or "right" - which side of the piece the connector is on
// For left side: rotation=180 (rail points inward/right, slot opens outward/left)
// For right side: rotation=0 (rail points outward/right, slot opens inward/left)
// Wait, direction depends on which face we are on.
// Bottom wall is at Y=0.
// If we are at the RIGHT cut of a piece (e.g. x_cut_bottom_1), we want the rail to stick out in +X direction?
// No, the cut is in the Y-Z plane. The rail should stick out in the X direction?
// The user said "rail on the side of the wall spanning vertically across it".
// If the wall runs along X, the cut face is in the Y-Z plane.
// So the rail should protrude from the Y-Z plane in the +X or -X direction.
// My previous implementation rotated by 90 degrees to point in Y.
// Let's re-evaluate orientation.
// The cut is at `x = x_cut_bottom_1`. This is a plane x=constant.
// The wall runs along X.
// So the cross section of the wall is in the Y-Z plane.
// We want to join two pieces along the X axis.
// So the rail should point in the X direction.
// If I am on the RIGHT side of a piece (max X), the rail should point +X.
// If I am on the LEFT side of a piece (min X), the slot should be cut into the material (pointing -X?).

// Let's adjust the rotation logic.
// Default `wall_connector_rail` rotates 90 deg to point in Y.
// If we want it to point in +X, we need rotation = -90.
// If we want it to point in -X, we need rotation = 90.

module bottom_wall_rail(x_pos, z_start=0, height=wall_rail_height, side="right") {
    // Rail on the right side of the piece (pointing +X)
    // Position: x_pos is the cut line.
    // y_pos: centered in the wall. Bottom wall is at Y=0 to Y~14. Center ~7.
    y_center = wall_center_offset;
    
    // If side is "right", we want the rail to start at x_pos and go +X.
    // Rotation: -90 makes it point +X.
    rotation = (side == "right") ? -90 : 90;
    
    wall_connector_rail(x_pos, y_center, z_start, height, rotation);
}

module bottom_wall_slot(x_pos, z_start=0, height=wall_rail_height, side="left") {
    // Slot on the left side of the piece (cutting into the material from -X direction?)
    // If side is "left", the piece starts at x_pos. The slot should be cut into the piece.
    // So the slot shape should be positioned at x_pos and point +X (into the piece).
    // Wait, if the rail from the previous piece (left) points +X, 
    // then the slot on this piece (right) should accept that rail.
    // So the slot volume should be exactly where the rail would be.
    // If the rail is on the LEFT piece, it ends at x_pos.
    // So the rail points +X and its base is at x_pos (on the left piece).
    // Actually, usually:
    // Left Piece: Ends at x_cut. Has Rail protruding +X.
    // Right Piece: Starts at x_cut. Has Slot cut into it (accepting the rail).
    
    // So for the Right Piece (side="left" of the piece), we need a slot at x_cut.
    // The slot should match the rail from the left piece.
    // Rail from left piece: Origin at x_cut, pointing +X.
    // So Slot should also be at x_cut, pointing +X.
    
    y_center = wall_center_offset;
    rotation = -90; // Points +X
    
    wall_connector_slot(x_pos, y_center, z_start, height, rotation);
}

// Convenience module: Rail on top wall (Y=total_y area)
module top_wall_rail(x_pos, z_start=0, height=wall_rail_height, side="right") {
    // Top wall is at Y=276.511. Wall goes inwards (smaller Y).
    // Center is at total_y - wall_center_offset.
    y_center = 276.511 - wall_center_offset;
    
    // Rail on right side of piece: Points +X.
    rotation = -90;
    
    wall_connector_rail(x_pos, y_center, z_start, height, rotation);
}

// Generic modules for easy positioning
module add_rail(x, y, z, rotation, length=wall_rail_height, base=wall_rail_base, tip=wall_rail_tip) {
    wall_connector_rail(x, y, z, length, rotation, base, tip);
}

module add_slot(x, y, z, rotation, length=wall_rail_height, base=wall_rail_base, tip=wall_rail_tip) {
    wall_connector_slot(x, y, z, length, rotation, base, tip);
}

// Module for rails on the side walls (at the horizontal Y-cut)
module side_wall_rail(x_pos, y_pos, z_start=0, height=wall_rail_height, side="bottom") {
    // side="bottom" means it's on the bottom piece, pointing +Y
    // side="top" means it's on the top piece, pointing -Y
    
    rotation = (side == "bottom") ? 0 : 180;
    
    wall_connector_rail(x_pos, y_pos, z_start, height, rotation, base=side_wall_rail_base, tip=side_wall_rail_tip);
}

module side_wall_slot(x_pos, y_pos, z_start=0, height=wall_rail_height, side="top") {
    // side="top" means it's on the top piece, accepting a rail from bottom (+Y)
    // So slot points +Y.
    
    rotation = (side == "top") ? 0 : 180;
    
    wall_connector_slot(x_pos, y_pos, z_start, height, rotation, base=side_wall_rail_base, tip=side_wall_rail_tip);
}

module top_wall_slot(x_pos, z_start=0, height=wall_rail_height, side="left") {
    // Slot on left side of piece: Accepts rail from left piece.
    // Rail points +X. Slot points +X.
    y_center = 276.511 - wall_center_offset;
    rotation = -90;
    
    wall_connector_slot(x_pos, y_center, z_start, height, rotation);
}

// Module to add rails to bottom wall pieces at cut lines
// Each piece gets a rail on one side and expects a slot on the other
module bottom_wall_rails() {
    // Rails protrude from the RIGHT side of each piece (except the rightmost)
    // Part 1: rail on right side at x_cut_bottom_1
    bottom_wall_rail(x_cut_bottom_1, z_start=0, side="right");
    // Part 2: rail on right side at x_cut_bottom_2
    bottom_wall_rail(x_cut_bottom_2, z_start=0, side="right");
    // Part 3: rail on right side at x_cut_bottom_3
    bottom_wall_rail(x_cut_bottom_3, z_start=0, side="right");
    // Part 4: rail on right side at x_cut_bottom_4
    bottom_wall_rail(x_cut_bottom_4, z_start=0, side="right");
}

module bottom_wall_slots() {
    // Slots cut into the LEFT side of each piece (except the leftmost)
    // Part 2: slot on left side at x_cut_bottom_1
    bottom_wall_slot(x_cut_bottom_1, z_start=0, side="left");
    // Part 3: slot on left side at x_cut_bottom_2
    bottom_wall_slot(x_cut_bottom_2, z_start=0, side="left");
    // Part 4: slot on left side at x_cut_bottom_3
    bottom_wall_slot(x_cut_bottom_3, z_start=0, side="left");
    // Part 5: slot on left side at x_cut_bottom_4
    bottom_wall_slot(x_cut_bottom_4, z_start=0, side="left");
}

// Module to add rails to top wall pieces at cut lines
module top_wall_rails() {
    // Rails protrude from the RIGHT side of each piece
    top_wall_rail(x_cut_top_1, z_start=0, side="right");
    top_wall_rail(x_cut_top_2, z_start=0, side="right");
    top_wall_rail(x_cut_top_3, z_start=0, side="right");
}

module top_wall_slots() {
    // Slots cut into the LEFT side of each piece
    top_wall_slot(x_cut_top_1, z_start=0, side="left");
    top_wall_slot(x_cut_top_2, z_start=0, side="left");
    top_wall_slot(x_cut_top_3, z_start=0, side="left");
}

//=====================================================================
//== Part Selection and Rendering
//=====================================================================

total_x = 698.466; total_y = 276.511; total_z = 100;

//=====================================================================
//== Module to render a single part (used by both single and assembly modes)
//=====================================================================
module render_part(part_num) {
    difference() {
        union() {
            // First, cut out the main shape of the selected part
            intersection() {
                original_model();
                if (part_num == 1) { translate([0, 0, 0]) cube([x_cut_bottom_1, y_cut1, total_z]); }
                if (part_num == 2) { translate([x_cut_bottom_1, 0, 0]) cube([x_cut_bottom_2 - x_cut_bottom_1, y_cut1, total_z]); }
                if (part_num == 3) { translate([x_cut_bottom_2, 0, 0]) cube([x_cut_bottom_3 - x_cut_bottom_2, y_cut1, total_z]); }
                if (part_num == 4) { translate([x_cut_bottom_3, 0, 0]) cube([x_cut_bottom_4 - x_cut_bottom_3, y_cut1, total_z]); }
                if (part_num == 5) { translate([x_cut_bottom_4, 0, 0]) cube([total_x - x_cut_bottom_4, y_cut1, total_z]); }
                
                if (part_num == 6) { translate([0, y_cut1, 0]) cube([x_cut_top_1, total_y - y_cut1, total_z]); }
                if (part_num == 7) { translate([x_cut_top_1, y_cut1, 0]) cube([x_cut_top_2 - x_cut_top_1, total_y - y_cut1, total_z]); }
                if (part_num == 8) { translate([x_cut_top_2, y_cut1, 0]) cube([x_cut_top_3 - x_cut_top_2, total_y - y_cut1, total_z]); }
                if (part_num == 9) { translate([x_cut_top_3, y_cut1, 0]) cube([total_x - x_cut_top_3, total_y - y_cut1, total_z]); }
            }
            
            // Add wall connector rails (protrude from right side of each piece)
            // Bottom row parts - rails at their right cut edge
            if (part_num == 1) { bottom_wall_rail(x_cut_bottom_1, z_start=0, side="right"); }
            if (part_num == 2) { bottom_wall_rail(x_cut_bottom_2, z_start=0, side="right"); }
            if (part_num == 3) { bottom_wall_rail(x_cut_bottom_3, z_start=0, side="right"); }
            if (part_num == 4) { bottom_wall_rail(x_cut_bottom_4, z_start=0, side="right"); }
            // Part 5 has no rail (rightmost piece)
            
            // Top row parts - rails at their right cut edge
            if (part_num == 6) { top_wall_rail(x_cut_top_1, z_start=0, side="right"); }
            if (part_num == 7) { top_wall_rail(x_cut_top_2, z_start=0, side="right"); }
            if (part_num == 8) { top_wall_rail(x_cut_top_3, z_start=0, side="right"); }
            // Part 9 has no rail (rightmost piece)

            // Side wall rails (at horizontal cut y_cut1)
            // Part 1 (Bottom Left) - Rail pointing +Y
            if (part_num == 1) { 
                add_rail(x=side_wall_center_offset, y=y_cut1, z=0, rotation=0, base=side_wall_rail_base, tip=side_wall_rail_tip); 
            }
            // Part 5 (Bottom Right) - Rail pointing +Y
            if (part_num == 5) { 
                add_rail(x=total_x - side_wall_right_offset, y=y_cut1, z=0, rotation=0, base=side_wall_rail_base, tip=side_wall_rail_tip); 
            }
        }

        // Subtract the dowel holes for the appropriate faces
        if (part_num >= 1 && part_num <= 5) {
            dowels_bottom();
            connectors_bottom();
        }
        if (part_num >= 6 && part_num <= 9) {
            dowels_top();
            connectors_top();
        }
        dowels_at_y1();
        connectors_at_y1();
        
        // Subtract wall connector slots (cut into left side of each piece)
        // Bottom row parts - slots at their left cut edge
        if (part_num == 2) { bottom_wall_slot(x_cut_bottom_1, z_start=0, side="left"); }
        if (part_num == 3) { bottom_wall_slot(x_cut_bottom_2, z_start=0, side="left"); }
        if (part_num == 4) { bottom_wall_slot(x_cut_bottom_3, z_start=0, side="left"); }
        if (part_num == 5) { bottom_wall_slot(x_cut_bottom_4, z_start=0, side="left"); }
        
        // Top row parts - slots at their left cut edge
        if (part_num == 7) { top_wall_slot(x_cut_top_1, z_start=0, side="left"); }
        if (part_num == 8) { top_wall_slot(x_cut_top_2, z_start=0, side="left"); }
        if (part_num == 9) { top_wall_slot(x_cut_top_3, z_start=0, side="left"); }

        // Side wall slots (at horizontal cut y_cut1)
        // Part 6 (Top Left) - Slot accepting rail from bottom
        if (part_num == 6) { 
            add_slot(x=side_wall_center_offset, y=y_cut1, z=0, rotation=0, base=side_wall_rail_base, tip=side_wall_rail_tip); 
        }
        // Part 9 (Top Right) - Slot accepting rail from bottom
        if (part_num == 9) { 
            add_slot(x=total_x - side_wall_right_offset, y=y_cut1, z=0, rotation=0, base=side_wall_rail_base, tip=side_wall_rail_tip); 
        }

        // Subtract USB connector hole on the back wall (top row parts only)
        if (part_num >= 6 && part_num <= 9) {
            usb_connector_hole();
        }
    }
}

//=====================================================================
//== Assembly View Mode (Part 0) - Shows all parts at once
//=====================================================================
module assembly_view() {
    echo("Rendering ASSEMBLY VIEW - All 9 parts with spacing");
    
    // Calculate offsets for each part based on assembly_spacing
    // Bottom row: Parts 1-5 (spread along X axis)
    // Top row: Parts 6-9 (spread along X axis, offset in Y)
    
    // Bottom row parts with X spacing
    translate([0 * assembly_spacing, 0, 0]) 
        render_part(1);
    translate([1 * assembly_spacing, 0, 0]) 
        render_part(2);
    translate([2 * assembly_spacing, 0, 0]) 
        render_part(3);
    translate([3 * assembly_spacing, 0, 0]) 
        render_part(4);
    translate([4 * assembly_spacing, 0, 0]) 
        render_part(5);
    
    // Top row parts with X and Y spacing
    translate([0 * assembly_spacing, assembly_spacing, 0]) 
        render_part(6);
    translate([1 * assembly_spacing, assembly_spacing, 0]) 
        render_part(7);
    translate([2 * assembly_spacing, assembly_spacing, 0]) 
        render_part(8);
    translate([3 * assembly_spacing, assembly_spacing, 0]) 
        render_part(9);
}

//=====================================================================
//== Main Rendering Logic
//=====================================================================

if (part_to_render == 0) {
    // Assembly view - show all parts at once
    assembly_view();
} else if (part_to_render >= 1 && part_to_render <= 9) {
    // Single part view
    render_part(part_to_render);
} else if (part_to_render == 10) {
    printable_dowel();
} else if (part_to_render == 11) {
    echo("Rendering one connector.");
    UniversalConnector(length=conn_len, width=conn_width, height=conn_height);
} else if (part_to_render == 12) {
    echo("Rendering test wall connector rail.");
    // Test piece: a small section of wall with a rail for fit testing
    // Print this to test the fit before printing full parts
    difference() {
        cube([20, wall_rail_depth + 10, wall_rail_height + 10]);
        // Add slot for testing fit
        translate([10, wall_center_offset, 5])
        rotate([0, 0, -90])
        wall_connector_slot(0, 0, 0, height=wall_rail_height);
    }
    // Rail next to it for comparison
    translate([25, 0, 5])
    wall_connector_rail(0, wall_center_offset, 0, height=wall_rail_height, rotation=-90);
} else {
    echo("Invalid part_to_render selected! Please choose a value from 1 to 12.");
    %original_model(); // Show the full model with cut lines for reference
}