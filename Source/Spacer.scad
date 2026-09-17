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
// Set bottom_plate_mode to true for a simple 5mm plate with no button holes.
bottom_plate_mode = true;

main_wall_height = 70;
main_bottom_height = 8;

wall_thickness = 18; 
wall_height = bottom_plate_mode ? 5 : main_wall_height;
bottom_height = bottom_plate_mode ? 5 : main_bottom_height;

// Locating lip on the wall, with a matching groove in the removable plate.
locating_lip_enabled = true;
locating_lip_height = 1.5;
locating_lip_width = 1.5;
locating_lip_inset = 1.2;     // Outer edge of lip measured from body perimeter
locating_lip_clearance = 0.3; // Clearance on EACH side of the lip
locating_lip_depth_clearance = 0.2;

total_x = 698.466;
total_y = 276.511;
total_z = max(100, wall_height + locating_lip_height + 1, bottom_height + 1);


wall_cuts = [[139.239, 279.235, 419.231, 559.228],
             [209.237, 349.233, 489.230]];
plate_cut_shift = 15;
cut_shift = bottom_plate_mode ? plate_cut_shift : 0;
row_cuts = [for (row = wall_cuts) [for (x = row) x + cut_shift]];
y_cut1 = total_y / 2;

function part_row(part) = part <= 5 ? 0 : 1;
function part_index(part) = part <= 5 ? part - 1 : part - 6;
function row_edges(row) = concat([0], row_cuts[row], [total_x]);
function get_seam_y(x) =
    x < row_cuts[1][0] || x >= row_cuts[1][2] ? y_cut1 - 4 : y_cut1 + 13;

module front_row_volume() {
    // Keep seam faces in 3D: a 2D polygon rounds coordinates before extrusion,
    // which can leave a microscopic gap where a dovetail meets the seam.
    bands = [0, row_cuts[1][0], row_cuts[1][2], total_x];
    for (i = [0:2])
        translate([bands[i], 0, 0])
            cube([bands[i + 1] - bands[i],
                  y_cut1 + (i == 1 ? 13 : -4), total_z]);
}

module part_volume(part) {
    row = part_row(part);
    index = part_index(part);
    edges = row_edges(row);
    intersection() {
        translate([edges[index], 0, 0])
            cube([edges[index + 1] - edges[index], total_y, total_z]);
        if (row == 0) front_row_volume();
        else difference() {
            cube([total_x, total_y, total_z]);
            front_row_volume();
        }
    }
}

// --- Connector Parameters ---
conn_len = 30;
conn_width = 10;
conn_height = 5;
conn_z_pos = bottom_height + (bottom_plate_mode ? 1 : 0); // Flush with top of plate, shifted 1mm up in bottom_plate_mode

// Seam connector positions
conn_middle_x_positions = [70, 100, 140, 175, 210, 245, 280, 315, 350,
                           385, 420, 455, 490, 525, 560, 595, 630];
conn_bottom_y_positions = [45, 110];
conn_top_y_positions = [180, 235];

// --- Wall Connector Parameters (Dovetail Rail/Slot) ---
wall_rail_height = wall_height; // Matches wall height
wall_rail_base = 8;          // Widest part of the dovetail
wall_rail_tip = 4;           // Narrowest part of the dovetail (at the neck)
wall_rail_depth = 4;         // Length of the dovetail pin
wall_rail_tolerance = 0.3;   // Clearance for 3D printing fit
wall_center_offset = 7;      // Distance from outer wall edge to center of connector
side_wall_offset = 32;       // Fixed side connector X offset; check if thickness changes
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
    // Extend beyond the inside wall so the socket always cuts through.
    wall_y = total_y;
    cut_depth = max(30, wall_thickness + 2);
    
    // Main 24mm opening
    translate([usb_x_pos, wall_y - cut_depth/2, usb_z_pos])
    rotate([90, 0, 0])
    cylinder(h = cut_depth, d = usb_hole_diameter, center = true, $fn = 64);

    // D-Type mounting holes (diagonal pair 1: top-left and bottom-right)
    // Horizontal offset: 19/2 = 9.5mm, Vertical offset: 24/2 = 12mm
    for (offset = [[-usb_screw_x_spacing/2, usb_screw_z_spacing/2], 
                   [usb_screw_x_spacing/2, -usb_screw_z_spacing/2]]) {
        translate([usb_x_pos + offset[0], wall_y - cut_depth/2, usb_z_pos + offset[1]])
        rotate([90, 0, 0])
        cylinder(h = cut_depth, d = usb_screw_hole_diameter, center = true, $fn = 32);
    }
}


// --- Magnet Hole Parameters ---
magnet_enabled = true;
magnet_diameter = 6.2;
magnet_depth = 2;
magnet_pitch = 40;             // Approximate pitch before seam exclusions
magnet_end_margins = [90, 165]; // Keep pockets on the straight front/back walls
magnet_edge_clearance = 2;     // Minimum material around a pocket
magnet_seam_clearance = 12;    // Minimum center distance from BOTH sets of cuts
magnet_row_inset = wall_thickness / 2;

function magnet_x_positions(row) =
    let(start = magnet_end_margins[row], end = total_x - start,
        intervals = max(1, floor((end - start) / magnet_pitch)),
        keepout = max(magnet_seam_clearance,
                      magnet_diameter / 2 + magnet_edge_clearance +
                      wall_rail_depth + wall_rail_tolerance / 2),
        seams = concat(wall_cuts[row],
                       [for (x = wall_cuts[row]) x + plate_cut_shift]))
    [for (i = [0:intervals])
        let(x = start + (end - start) * i / intervals)
        if (min([for (cut = seams) abs(x - cut)]) >= keepout) x];

magnet_positions = [for (row = [0:1], x = magnet_x_positions(row))
    [x, row == 0 ? magnet_row_inset : total_y - magnet_row_inset]];

module magnet_holes() {
    if (magnet_enabled) {
        assert(magnet_pitch > 0 && magnet_diameter > 0 && magnet_depth > 0);
        assert(magnet_depth < (bottom_plate_mode ? bottom_height : wall_height));
        assert(magnet_row_inset >= magnet_diameter / 2 + magnet_edge_clearance,
            "Wall is too thin for these magnet pockets.");
        assert(!locating_lip_enabled ||
            magnet_row_inset - magnet_diameter / 2 >= locating_lip_inset +
            locating_lip_width + locating_lip_clearance + magnet_edge_clearance,
            "Magnet pockets are too close to the locating groove.");
        for (position = magnet_positions)
            translate([position[0], position[1], wall_height - magnet_depth])
                cylinder(d = magnet_diameter, h = magnet_depth + 0.1, $fn = 32);
    }
}

// --- Adhesive feet on the OUTSIDE of the removable bottom plate ---
// For nominal 20 mm round pads, 3–5 mm thick.
feet_enabled = true;
foot_recess_diameter = 20.6;
foot_recess_depth = 1;
foot_edge_margin = 1.2;
foot_feature_clearance = 2;
foot_row_inset = foot_recess_diameter / 2 + foot_edge_margin;
// Deliberately staggered to clear both sets of seams and the magnet pattern.
foot_x_positions = [[110, 320, total_x - 110], [181, 380, total_x - 181]];
foot_positions = [for (row = [0:1], x = foot_x_positions[row])
    [x, row == 0 ? foot_row_inset : total_y - foot_row_inset]];

module foot_recesses() {
    if (feet_enabled) {
        radius = foot_recess_diameter / 2;
        groove_depth = locating_lip_enabled ?
            locating_lip_height + locating_lip_depth_clearance : 0;
        assert(radius > 0 && foot_recess_depth > 0 && foot_edge_margin > 0);
        assert(foot_feature_clearance >= 0);
        assert(bottom_height - foot_recess_depth - groove_depth >= 2,
            "Foot recess and inside groove must leave at least 2 mm of plate.");
        assert(foot_row_inset < wall_thickness,
            "Foot centers must remain beneath the supporting walls.");
        for (row = [0:1], x = foot_x_positions[row]) {
            position = [x, row == 0 ? foot_row_inset : total_y - foot_row_inset];
            assert(min([for (cut = wall_cuts[row]) abs(x - cut)]) >=
                radius + foot_feature_clearance + wall_rail_depth + wall_rail_tolerance / 2,
                "Foot is too close to a wall joint.");
            assert(min([for (cut = wall_cuts[row]) abs(x - cut - plate_cut_shift)]) >=
                radius + foot_feature_clearance,
                "Foot recess is too close to a plate seam.");
            if (magnet_enabled && len(magnet_positions) > 0)
                assert(min([for (magnet = magnet_positions) norm(position - magnet)]) >=
                    radius + magnet_diameter / 2 + foot_feature_clearance,
                    "Foot recess is too close to a magnet pocket.");
            // The final Z reflection moves this cut to the exterior, Z=4–5.
            translate([position[0], position[1], -0.01])
                cylinder(d = foot_recess_diameter, h = foot_recess_depth + 0.01, $fn = 96);
        }
    }
}

//=====================================================================
//== Shared Body Profiles
//=====================================================================

// Preserve the original filled footprint built from resized SVG strokes.
module outline_profile_2d(inset) {
    translate([349.2335, 138.2555])
        resize([698.466 - inset, 276.511 - (inset * 1.3)], auto = true)
            import(file = "RefrenceForSpacerSCADdontMake.svg", convexity = 3, center = true);
}

module wall_profile_2d() {
    assert(wall_thickness > 0, "Wall thickness must be positive.");
    difference() {
        bottom_profile_2d();
        offset(delta = -wall_thickness) bottom_profile_2d();
    }
}

module bottom_profile_2d() {
    union() {
        for (i = [0:.5:60]) outline_profile_2d(i);
        translate([100.278, 0]) square([500, 260]);
        polygon([[0, 68], [110, 260], [130, 0]]);
        polygon([[694.530, 68], [584.530, 260], [564.530, 0]]);
    }
}

module locating_lip_profile_2d() {
    assert(locating_lip_height > 0 && locating_lip_width > 0);
    assert(locating_lip_clearance >= 0 && locating_lip_depth_clearance >= 0);
    assert(locating_lip_inset > locating_lip_clearance,
        "Lip groove must leave an outer edge on the plate.");
    // Use the actual filled footprint so curved sides follow the existing body.
    // Clip to the wall profile to ensure the lip is supported everywhere.
    intersection() {
        wall_profile_2d();
        difference() {
            offset(delta = -locating_lip_inset) bottom_profile_2d();
            offset(delta = -locating_lip_inset - locating_lip_width)
                bottom_profile_2d();
        }
    }
}

module locating_lip() {
    translate([0, 0, wall_height - 0.01])
        linear_extrude(locating_lip_height + 0.01, convexity = 3)
            locating_lip_profile_2d();
}

module locating_lip_groove() {
    groove_depth = locating_lip_height + locating_lip_depth_clearance;
    assert(groove_depth < bottom_height,
        "Lip groove must not cut through the bottom plate.");
    // part_geometry is later reflected in Z, putting this groove underneath.
    translate([0, 0, bottom_height - groove_depth])
        linear_extrude(groove_depth + 0.01, convexity = 3)
            offset(delta = locating_lip_clearance) locating_lip_profile_2d();
}

button_positions = [[69.240, 79.257], [209.237, 79.257], [349.233, 79.257],
                    [489.230, 79.257], [629.226, 79.257], [139.239, 209.254],
                    [279.235, 209.254], [419.231, 209.254], [559.228, 209.254]];

module button_holes() {
    for (position = button_positions) translate(position) {
        cylinder(h = 88, d = 88, center = true);
        for (dy = [-45.687, -43.687, 43.687, 45.687])
            translate([0, dy, 0]) cylinder(h = 88, d = 7, center = true);
    }
}

module body() {
    if (bottom_plate_mode) {
        linear_extrude(bottom_height, convexity = 3) bottom_profile_2d();
    } else union() {
        linear_extrude(wall_height, convexity = 3) wall_profile_2d();
        if (locating_lip_enabled) locating_lip();
        difference() {
            linear_extrude(bottom_height, convexity = 3) bottom_profile_2d();
            button_holes();
        }
    }
}

module connector_cutout(x, y, angle = 0) {
    translate([x, y, conn_z_pos]) rotate([0, 0, angle])
        UniversalConnectorCutout(length=conn_len, width=conn_width, height=conn_height);
}

module seam_connectors(row) {
    positions = row == 0 ? conn_bottom_y_positions : conn_top_y_positions;
    for (x = row_cuts[row]) {
        for (y = positions) connector_cutout(x, y);
        if (len(positions) > 1)
            for (i = [0:len(positions) - 2])
                connector_cutout(x, (positions[i] + positions[i + 1]) / 2, 90);
    }
    if (len(conn_middle_x_positions) > 0)
        for (i = [0:len(conn_middle_x_positions) - 1]) {
            x = conn_middle_x_positions[i];
            connector_cutout(x, get_seam_y(x), i % 2 == 0 ? 90 : 0);
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

// A single placement path for rails and their matching slots.
module wall_joint(x, y, angle, slot = false, side = false) {
    base = side ? side_wall_rail_base : wall_rail_base;
    tip = side ? side_wall_rail_tip : wall_rail_tip;
    if (slot) wall_connector_slot(x, y, 0, rotation=angle, base=base, tip=tip);
    else wall_connector_rail(x, y, 0, rotation=angle, base=base, tip=tip);
}

module part_wall_joints(part, slot = false) {
    row = part_row(part);
    index = part_index(part);
    edges = row_edges(row);
    if (slot ? index > 0 : index < len(edges) - 2)
        wall_joint(edges[index + (slot ? 0 : 1)],
                   row == 0 ? wall_center_offset : total_y - wall_center_offset,
                   -90, slot);
    if (slot ? (part == 6 || part == 9) : (part == 1 || part == 5)) {
        x = part == 1 || part == 6 ? side_wall_offset : total_x - side_wall_offset;
        wall_joint(x, get_seam_y(x), 0, slot, side=true);
    }
}

// Printable parts in their assembled orientation.
module render_part(part_num) {
    if (bottom_plate_mode) {
        // Flip through the thickness, preserving X/Y alignment with the walls.
        translate([0, 0, bottom_height])
            mirror([0, 0, 1]) part_geometry(part_num);
    } else {
        part_geometry(part_num);
    }
}

module part_geometry(part_num) {
    difference() {
        union() {
            intersection() {
                body();
                part_volume(part_num);
            }
            if (!bottom_plate_mode) part_wall_joints(part_num);
        }
        seam_connectors(part_row(part_num));
        magnet_holes();
        if (bottom_plate_mode) {
            if (locating_lip_enabled) locating_lip_groove();
            foot_recesses();
        } else {
            part_wall_joints(part_num, slot=true);
            if (part_row(part_num) == 1) usb_connector_hole();
        }
    }
}

module assembly_view() {
    for (part = [1:9])
        translate([part_index(part) * assembly_spacing,
                   part_row(part) * assembly_spacing, 0]) render_part(part);
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
    %body(); // Show the full model with cut lines for reference
}
