// Connector.scad
// Universal connector for joining parts
// Shape: U-channel (Box without top and two faces) with side ridges.

// Generates the 2D profile of the connector (U-shape with side ridges)
module connector_profile(width, height, wall_thickness, ridge_depth) {
    w = width;
    h = height;
    wt = wall_thickness;
    rd = ridge_depth;
    
    // Centered on X, Bottom at Y=0 (in 2D) -> Z=0 in 3D
    union() {
        // U-shape body
        difference() {
            translate([-w/2, 0]) square([w, h]);
            translate([-w/2 + wt, wt]) square([w - 2*wt, h + 0.1]); // +0.1 to ensure top cut
        }
        
        // Ridges on the outer sides
        // Triangular ridges for locking/friction
        // Left ridge
        polygon([
            [-w/2, h/4],
            [-w/2 - rd, h/2],
            [-w/2, 3*h/4]
        ]);
        
        // Right ridge
        polygon([
            [w/2, h/4],
            [w/2 + rd, h/2],
            [w/2, 3*h/4]
        ]);
    }
}

// Generates the 3D connector object
module UniversalConnector(length=20, width=8, height=4, wall_thickness=1.5, ridge_depth=0.5, tolerance=0) {
    // Apply tolerance to shrink the connector slightly if needed
    // Usually tolerance is 0 for the part, and >0 for the hole.
    
    eff_w = width - tolerance;
    eff_h = height - tolerance;
    eff_l = length - tolerance; 
    
    // Extrude along Y
    rotate([90, 0, 0])
    linear_extrude(height=eff_l, center=true)
        connector_profile(eff_w, eff_h, wall_thickness, ridge_depth);
}

// Generates the negative volume to subtract from the parts
module UniversalConnectorCutout(length=20, width=8, height=4, wall_thickness=1.5, ridge_depth=0.5, tolerance=0.2) {
    // Cutout is larger by tolerance
    eff_w = width + tolerance;
    eff_h = height; // Height usually matches surface, or +tolerance if embedded
    eff_l = length + tolerance;
    
    // Extrude along Y
    rotate([90, 0, 0])
    linear_extrude(height=eff_l, center=true)
        connector_profile(eff_w, eff_h, wall_thickness, ridge_depth);
}
