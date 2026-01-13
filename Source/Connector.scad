// Connector.scad
// Universal connector for joining parts
// Shape: U-channel (Box without top and two faces) with side ridges.

// Generates the 2D profile of the connector (U-shape with side ridges)
module connector_profile(width, height, wall_thickness, base_thickness, ridge_depth) {
    w = width;
    h = height;
    wt = wall_thickness;
    bt = base_thickness;
    rd = ridge_depth;
    
    // Centered on X, Bottom at Y=0 (in 2D) -> Z=0 in 3D
    // U-shape body
    difference() {
        translate([-w/2, 0]) square([w, h]);
        translate([-w/2 + wt, bt]) square([w - 2*wt, h + 0.1]); // +0.1 to ensure top cut
    }
}

// Generates the 3D connector object
module UniversalConnector(length=20, width=8, height=4, wall_thickness=2.5, base_thickness=3.0, ridge_depth=0.5, tolerance=0) {
    // Apply tolerance to shrink the connector slightly if needed
    // Usually tolerance is 0 for the part, and >0 for the hole.
    
    eff_w = width - tolerance;
    eff_h = height - tolerance;
    eff_l = length - tolerance; 
    
    // Extrude along Y
    rotate([-90, 0, 0])
    linear_extrude(height=eff_l, center=true)
        connector_profile(eff_w, eff_h, wall_thickness, base_thickness, ridge_depth);
}

// Generates the negative volume to subtract from the parts
module UniversalConnectorCutout(length=20, width=8, height=4, wall_thickness=2.5, base_thickness=3.0, ridge_depth=0.5, tolerance=0.2) {
    // Cutout is larger by tolerance
    eff_w = width + tolerance;
    eff_h = height; // Height usually matches surface, or +tolerance if embedded
    eff_l = length + tolerance;
    
    // Extrude along Y
    rotate([-90, 0, 0])
    linear_extrude(height=eff_l, center=true)
    connector_profile(eff_w, eff_h, wall_thickness, base_thickness, ridge_depth);
}

// ===================================
// == Z-Pillar and Tab Modules
// ===================================

// A vertical tab that protrudes from the face of a part (Z direction)
// Designed as a radial spoke.
// centered at origin locally, but positioned radially.
module ZTab(width=8, thickness=3, height=8, angle=0, distance=8) {
    // width: Radial length of the tab
    // thickness: Tangential thickness
    // distance: Radial distance from center to center of tab
    // angle: Angle in XY plane
    
    rotate([0, 0, angle])
    translate([distance, 0, 0])
    linear_extrude(height=height, scale=[0.9, 0.9]) // Slight taper for fit
        square([width, thickness], center=true);
}

// The Hub/Pillar that accepts the tabs
// Centered at the intersection point.
module PillarBlock(height=10, radius=14, tab_width=8, tab_thickness=3, tab_dist=8, tolerance=0.3) {
    difference() {
        // Main body - Octagon for style or Cylinder
        cylinder(r=radius, h=height, $fn=8);
        
        // Subtract slots for tabs at 45, 135, 225, 315
        // Add tolerance to the slot
        for (a = [45, 135, 225, 315]) {
             // Slot is slightly larger than tab
             ZTab(width=tab_width + tolerance, thickness=tab_thickness + tolerance, height=height+1, angle=a, distance=tab_dist);
        }
        
        // Central hole for looks or reinforcement?
        // cylinder(r=4, h=height*3, center=true, $fn=16);
    }
}
