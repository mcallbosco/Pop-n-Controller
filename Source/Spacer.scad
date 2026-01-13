use <Connector.scad>

//=====================================================================
//== Configuration for Splitting and Printing
//=====================================================================

// Set which part to render for export.
// Part 0:     ALL PARTS - Assembly view showing all parts at once
// Bottom Row: 1=Left, 2=Mid-Left, 3=Middle, 4=Mid-Right, 5=Right
// Top Row:    6=Left, 7=Mid-Left, 8=Mid-Right, 9=Right
// Part 10 is the printable connector.
// Part 11 is a test wall connector rail (for fit testing).
part_to_render = 0; // [0:11]

// Assembly view spacing (only used when part_to_render = 0)
// Set to 0 to see parts fully assembled, increase to separate them
assembly_spacing = 10; // Gap between parts in mm

// --- Main Dimensions ---
// Set top_plate_mode to true for a simple 5mm plate with no button holes
top_plate_mode = true; 

main_wall_height = 70;
main_bottom_height = 8;

wall_thickness = 21;
wall_height = top_plate_mode ? 5 : main_wall_height;
bottom_height = top_plate_mode ? 5 : main_bottom_height;

total_x = 698.466; 
total_y = 276.511; 
total_z = 100;

// --- Split line coordinates ---
// Shift cuts in top plate mode to ensure seams don't overlap with original hole locations
cut_shift = top_plate_mode ? 15 : 0;

x_cut_bottom_1 = 139.239 + cut_shift;
x_cut_bottom_2 = 279.235 + cut_shift;
x_cut_bottom_3 = 419.231 + cut_shift; 
x_cut_bottom_4 = 559.228 + cut_shift;

x_cut_top_1 = 209.237 + cut_shift;
x_cut_top_2 = 349.233 + cut_shift;
x_cut_top_3 = 489.230 + cut_shift;

y_cut1 = 138.2555; // This is the vertical centerline of the model

// --- Variable Seam Height logic ---
function get_seam_y(x) = 
    (x < x_cut_top_1) ? (y_cut1 - 4) :
    (x < x_cut_top_2) ? (y_cut1 + 13) :
    (x < x_cut_top_3) ? (y_cut1 + 13) :
    (y_cut1 - 4);

module seam_volume_bottom(x_start, x_end) {
    intersection() {
        translate([x_start, 0, 0]) cube([x_end - x_start, total_y, total_z]);
        union() {
            translate([-1, 0, -1]) cube([x_cut_top_1 + 1, y_cut1 - 4, total_z + 2]);
            translate([x_cut_top_1, 0, -1]) cube([x_cut_top_2 - x_cut_top_1, y_cut1 + 13, total_z + 2]);
            translate([x_cut_top_2, 0, -1]) cube([x_cut_top_3 - x_cut_top_2, y_cut1 + 13, total_z + 2]);
            translate([x_cut_top_3, 0, -1]) cube([total_x - x_cut_top_3 + 1, y_cut1 - 4, total_z + 2]);
        }
    }
}

module seam_volume_top(x_start, x_end) {
    difference() {
        translate([x_start, 0, 0]) cube([x_end - x_start, total_y, total_z]);
        seam_volume_bottom(x_start, x_end);
    }
}

// --- Connector Parameters ---
conn_len = 30;
conn_width = 10;
conn_height = 5;
conn_z_pos = bottom_height + (top_plate_mode ? 1 : 0); // Flush with top of plate, shifted 1mm up in top_plate_mode

// --- Connector Position Arrays ---
// Edit these arrays to add/remove/move connectors
// Each value is an X coordinate where a connector will be placed

// Connectors along the horizontal middle seam (y_cut1)
// These connect the top row (parts 6-9) to the bottom row (parts 1-5)
conn_middle_x_positions = [70,100, 140,175, 210,245, 280, 280+35, 280+70, 280+110-5,275+110+35, 275+110+70,490, 490+35, 490+70,490+70+35, 490+70+70];

// Y positions for connectors on bottom row vertical seams (parts 1-5)
conn_bottom_y_positions = [45, 110];

// Y positions for connectors on top row vertical seams (parts 6-9)
conn_top_y_positions = [180, 235];

// --- Wall Connector Parameters (Dovetail Rail/Slot) ---
wall_rail_height = wall_height; // Matches wall height
wall_rail_base = 8;          // Widest part of the dovetail
wall_rail_tip = 4;           // Narrowest part of the dovetail (at the neck)
wall_rail_depth = 4;         // Length of the dovetail pin
wall_rail_tolerance = 0.3;   // Clearance for 3D printing fit
wall_center_offset = 7;      // Distance from outer wall edge to center of connector
side_wall_offset = 32;       // Center of the side walls (approx 21mm thick)
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


// --- Magnet Hole Parameters ---
// Arrays of X coordinates for two horizontal lines of magnets
magnet_x_bottom = [80,120,160,200,240,270,320,360,400,440,480,520,560,600,640,680,720,]; 
magnet_x_top = [130,170,200,240,280,320,360,400,440,480,520,560,600,640,680,720];

// Y positions centered on the front and back walls
magnet_y_bottom = wall_center_offset;              // Center of bottom wall
magnet_y_top = total_y - wall_center_offset;      // Center of top wall

// Magnet hole dimensions
magnet_diameter = 6.2; // Adjust for your magnets
magnet_depth = 2;       // Pocket depth
magnet_z_pos = wall_height; // Always at the top of the wall

module magnet_holes() {
    for (x = magnet_x_bottom) {
        // Cut downwards from the specified Z position
        translate([x, magnet_y_bottom, magnet_z_pos - magnet_depth])
            cylinder(d = magnet_diameter, h = magnet_depth + 0.1, $fn = 32);
    }
    for (x = magnet_x_top) {
        translate([x, magnet_y_top, magnet_z_pos - magnet_depth])
            cylinder(d = magnet_diameter, h = magnet_depth + 0.1, $fn = 32);
    }
}

//=====================================================================
//== Original Model Definition
//=====================================================================

module original_model() {
    // Current variables are now global for better integration
    // wall_thickness, wall_height, bottom_height

    module hole_pattern(holex, holey) {
        translate([holex, holey, 0]) cylinder(h = 88, d = 88, center = true);
        translate([holex, holey - 45.687, 0]) cylinder(h = 88, d = 7, center = true);
        translate([holex, holey - 43.687, 0]) cylinder(h = 88, d = 7, center = true);
        translate([holex, holey + 45.687, 0]) cylinder(h = 88, d = 7, center = true);
        translate([holex, holey + 43.687, 0]) cylinder(h = 88, d = 7, center = true);
    }
    union() {
        for (i = [0:.6:wall_thickness]) {
            translate([349.2335, 138.2555, 0]) linear_extrude(wall_height)
            resize([698.466 - i, 276.511 - (i * 1.3), 0], auto = true)
            import (file = "RefrenceForSpacerSCADdontMake.svg", convexity = 3, center = true);
        }
        difference() {
            union() {
                for (i = [0:.5:60]) {
                    translate([349.2335, 138.2555, 0]) linear_extrude(bottom_height)
                    resize([698.466 - i, 276.511 - (i * 1.3), 0], auto = true)
                    import (file = "RefrenceForSpacerSCADdontMake.svg", convexity = 3, center = true);
                }
                translate([100.278, 0, 0]) cube([500, 260, bottom_height]);
                linear_extrude(bottom_height) polygon([[0, 68], [110, 260], [130, 0]]);
                linear_extrude(bottom_height) polygon([[694.530, 68], [584.530, 260], [564.530, 0]]);
            }
            if (!top_plate_mode) {
                hole_pattern(69.240, 79.257); hole_pattern(209.237, 79.257);
                hole_pattern(349.233, 79.257); hole_pattern(489.230, 79.257);
                hole_pattern(629.226, 79.257); hole_pattern(139.239, 209.254);
                hole_pattern(279.235, 209.254); hole_pattern(419.231, 209.254);
                hole_pattern(559.228, 209.254);
            }
        }
    }
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
    for (i = [0 : len(conn_middle_x_positions) - 1]) {
        x_pos = conn_middle_x_positions[i];
        rotation = (i % 2 == 0) ? 90 : 0;  // Alternate: 90, 0, 90, 0, ...
        translate([x_pos, get_seam_y(x_pos), conn_z_pos]) 
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

// Bottom wall rail (Y=0 area) - rotation -90 points +X for right side
module bottom_wall_rail(x_pos, z_start=0) {
    wall_connector_rail(x_pos, wall_center_offset, z_start, wall_rail_height, -90);
}

// Bottom wall slot - accepts rail from adjacent piece
module bottom_wall_slot(x_pos, z_start=0) {
    wall_connector_slot(x_pos, wall_center_offset, z_start, wall_rail_height, -90);
}

// Top wall rail (Y=276.511 area)
module top_wall_rail(x_pos, z_start=0) {
    wall_connector_rail(x_pos, 276.511 - wall_center_offset, z_start, wall_rail_height, -90);
}

// Top wall slot
module top_wall_slot(x_pos, z_start=0) {
    wall_connector_slot(x_pos, 276.511 - wall_center_offset, z_start, wall_rail_height, -90);
}

// Generic rail/slot placement helpers
module add_rail(x, y, z, rotation, base=wall_rail_base, tip=wall_rail_tip) {
    wall_connector_rail(x, y, z, wall_rail_height, rotation, base, tip);
}

module add_slot(x, y, z, rotation, base=wall_rail_base, tip=wall_rail_tip) {
    wall_connector_slot(x, y, z, wall_rail_height, rotation, base, tip);
}

//=====================================================================
//== Part Selection and Rendering
//=====================================================================

// Dimensions moved to the top of the file

//=====================================================================
//== Module to render a single part (used by both single and assembly modes)
//=====================================================================
module render_part(part_num) {
    difference() {
        union() {
            // First, cut out the main shape of the selected part
            intersection() {
                original_model();
                if (part_num == 1) { seam_volume_bottom(0, x_cut_bottom_1); }
                if (part_num == 2) { seam_volume_bottom(x_cut_bottom_1, x_cut_bottom_2); }
                if (part_num == 3) { seam_volume_bottom(x_cut_bottom_2, x_cut_bottom_3); }
                if (part_num == 4) { seam_volume_bottom(x_cut_bottom_3, x_cut_bottom_4); }
                if (part_num == 5) { seam_volume_bottom(x_cut_bottom_4, total_x); }
                
                if (part_num == 6) { seam_volume_top(0, x_cut_top_1); }
                if (part_num == 7) { seam_volume_top(x_cut_top_1, x_cut_top_2); }
                if (part_num == 8) { seam_volume_top(x_cut_top_2, x_cut_top_3); }
                if (part_num == 9) { seam_volume_top(x_cut_top_3, total_x); }
            }
            
            // Wall connector rails (protrude from right side of each piece)
            if (!top_plate_mode) {
                if (part_num == 1) { bottom_wall_rail(x_cut_bottom_1); }
                if (part_num == 2) { bottom_wall_rail(x_cut_bottom_2); }
                if (part_num == 3) { bottom_wall_rail(x_cut_bottom_3); }
                if (part_num == 4) { bottom_wall_rail(x_cut_bottom_4); }
                if (part_num == 6) { top_wall_rail(x_cut_top_1); }
                if (part_num == 7) { top_wall_rail(x_cut_top_2); }
                if (part_num == 8) { top_wall_rail(x_cut_top_3); }

                // Side wall rails at horizontal seam (y_cut1)
                if (part_num == 1) { add_rail(x=side_wall_offset, y=get_seam_y(side_wall_offset), z=0, rotation=0, base=side_wall_rail_base, tip=side_wall_rail_tip); }
                if (part_num == 5) { add_rail(x=total_x - side_wall_offset, y=get_seam_y(total_x - side_wall_offset), z=0, rotation=0, base=side_wall_rail_base, tip=side_wall_rail_tip); }
            }
        }

        // Subtract the connector slots for the appropriate faces
        if (part_num >= 1 && part_num <= 5) {
            connectors_bottom();
        }
        if (part_num >= 6 && part_num <= 9) {
            connectors_top();
        }
        connectors_at_y1();
        
        // Subtract magnet holes
        magnet_holes();
        
        // Wall connector slots (cut into left side of each piece)
        if (!top_plate_mode) {
            if (part_num == 2) { bottom_wall_slot(x_cut_bottom_1); }
            if (part_num == 3) { bottom_wall_slot(x_cut_bottom_2); }
            if (part_num == 4) { bottom_wall_slot(x_cut_bottom_3); }
            if (part_num == 5) { bottom_wall_slot(x_cut_bottom_4); }
            if (part_num == 7) { top_wall_slot(x_cut_top_1); }
            if (part_num == 8) { top_wall_slot(x_cut_top_2); }
            if (part_num == 9) { top_wall_slot(x_cut_top_3); }

            // Side wall slots at horizontal seam
            if (part_num == 6) { add_slot(x=side_wall_offset, y=get_seam_y(side_wall_offset), z=0, rotation=0, base=side_wall_rail_base, tip=side_wall_rail_tip); }
            if (part_num == 9) { add_slot(x=total_x - side_wall_offset, y=get_seam_y(total_x - side_wall_offset), z=0, rotation=0, base=side_wall_rail_base, tip=side_wall_rail_tip); }
        }

        // Subtract USB connector hole on the back wall (top row parts only)
        if (part_num >= 6 && part_num <= 9 && !top_plate_mode) {
            usb_connector_hole();
        }
    }
}

// Assembly View - Shows all parts at once with spacing
module assembly_view() {
    // Bottom row: Parts 1-5
    for (i = [0:4]) translate([i * assembly_spacing, 0, 0]) render_part(i + 1);
    // Top row: Parts 6-9
    for (i = [0:3]) translate([i * assembly_spacing, assembly_spacing, 0]) render_part(i + 6);
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
    echo("Rendering one connector.");
    UniversalConnector(length=conn_len, width=conn_width, height=conn_height);
} else if (part_to_render == 11) {
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
    echo("Invalid part_to_render selected! Please choose a value from 0 to 11.");
    %original_model(); // Show the full model with cut lines for reference
}