// CR2032 battery socket for KORG DW8000
// Measurements based on datasheets for:
//  - Renesas CR2032-MFR-HR1/RH1 3-pin
//   industrial solder-in-place 225mAh Lithium battery,
//  - Panasonic CR2032-1GU 

$fn = 100;
d_coincell = 20; // 20 mm
d_coincell_tol = 0.3; // 0 to +0.3mm
d_coincell_neg = 17.7; // negative pad
h_coincell = 3.2; // 3.2 mm (2032)

d_min_hole_size = 0.7 + 0.25; // 0.7 from 1GU datasheet + IPC-2222 level A
d_min_annular_ring = 0.05; // 0.05mm
d_min_fab_allow = 0.6; // 0.6mm IPC-2222 level A
d_solder_pad = d_min_hole_size + d_min_annular_ring * 2 + d_min_fab_allow;
d_lead = 0.95; // 0.4 - 0.7mm for 1GU cell, paperclip = thicker? :)
d_hole_tol = 0.4; // FDM nozzle tolerance for small holes (for paperclips)

r_lead_pos_pin = 10.35;
y_lead_pos_pin1 = 10.15 / 2;
y_lead_pos_pin2 = -y_lead_pos_pin1;
y_lead_neg_pin = y_lead_pos_pin1 - 5.08;
x_lead_pos_pin1 = d_coincell / 2 + 0.35;
x_lead_pos_pin2 = x_lead_pos_pin1;
x_lead_neg_pin = x_lead_pos_pin1 - 17.8;
a_pos_pin = atan((y_lead_pos_pin1 - d_lead ) / (x_lead_pos_pin1 - d_lead / 2));

h_holder_base = 0.8;
w_holder_walls = 2;
d_holder = d_coincell + d_coincell_tol + 2 * w_holder_walls;
a_holder_clip = 22; // angle of width of holder vertical flex tabs
h_holder_clip = 1; // height of clip overhang
w_holder_clip = 0.5; // extent of clip overhang
//w_holder_sweep = (sin(a_holder_clip) * ((d_coincell / 2) + d_coincell_tol + w_holder_walls)) / 2; // 
w_holder_sweep = w_holder_walls;
union() {
    difference() {
        union() {
            union() {
                difference() {
                    // battery enclosure
                    difference() {
                        translate([0, 0, 0])
                            cylinder(h = h_holder_base + d_lead + h_coincell, d1 = d_holder, d2 = d_holder);
                        translate([0, 0, h_holder_base + d_lead + 0.1])
                            coincell(h_coincell, d_coincell + d_coincell_tol, d_coincell_neg);
                    }
                    // clip relief cuts
                    translate([0, 0, h_holder_base + d_lead + 0.01])
                        rotate(a = -180 - (a_holder_clip * 3) / 2, v = [0, 0, 1])
                            rotate_extrude(angle = a_holder_clip * 3, convexity = 10) {
                                    translate([d_coincell / 2 + (d_coincell_tol / 2) - 0.01, 0, 0])
                                        square([w_holder_sweep + 0.02, h_coincell + h_holder_clip]);
                            }
                }
                // positive lead retainer
                difference() {
                    translate([d_coincell / 2, 0, (h_holder_base + d_lead + h_coincell)/2 - 0.15]) {
                        cube([6, 2 * y_lead_pos_pin1 + 6, h_holder_base + d_lead + h_coincell - 0.3], center = true);
                    }
                    cylinder(h = h_holder_base + d_lead + h_coincell, d1 = d_holder, d2 = d_holder);
                }
            }

            // upper retaining ring
            translate([0, 0, h_holder_base + h_coincell + d_lead])
                difference() {
                    difference() {
                        translate([0, 0, 0])
                            cylinder(h = h_holder_clip, d1 = d_holder, d2 = d_holder);
                        translate([0, 0, -0.1])
                            cylinder(h = h_holder_clip + 0.2, d1 = d_coincell + d_coincell_tol, d2 = d_coincell + d_coincell_tol - 2 * w_holder_clip);
                    }

                    // clip relief cuts
                    translate([0, 0, -0.01]) {
                        // fingernail opening
                        rotate(a = -180 - (a_holder_clip * 3) / 2, v = [0, 0, 1])
                            rotate_extrude(angle = (a_holder_clip * 3), convexity = 10) {
                                    translate([d_coincell / 2 + (d_coincell_tol / 2) - w_holder_clip - 0.01, 0, 0])
                                        square([w_holder_sweep + w_holder_clip + 0.02, h_holder_clip + 0.03]);
                            }
                        // leave tabs on both sides of fingernail opening
                        rotate(a = a_pos_pin, v = [0, 0, 1])
                            rotate_extrude(angle = 180 - a_pos_pin - 3 * a_holder_clip, convexity = 10) {
                                    translate([d_coincell / 2 + (d_coincell_tol / 2) - w_holder_clip - 0.01, 0, 0])
                                        square([w_holder_sweep + w_holder_clip + 0.02, h_holder_clip + 0.03]);
                            }
                        rotate(a = -a_pos_pin, v = [0, 0, 1])
                            rotate_extrude(angle = -a_pos_pin - 3 * a_holder_clip, convexity = 10) {
                                    translate([d_coincell / 2 + (d_coincell_tol / 2) - w_holder_clip - 0.01, 0, 0])
                                        square([w_holder_sweep + w_holder_clip + 0.02, h_holder_clip + 0.03]);
                            }
                    }
                }
        }
        // pin holes (paperclips?)
        {
            // pin 1 (pos)
            translate([x_lead_pos_pin1, y_lead_pos_pin1, 0]) {
                soldered_lead_hole(height = h_holder_base + d_lead + h_coincell + h_holder_clip, diameter = d_lead + d_hole_tol, d_padsize = d_solder_pad);
                translate([0, 0, h_holder_base + h_coincell + h_holder_clip + 1 * (d_lead / 3)])
                    rotate([-22, 90, 180])
                        cylinder(h = 2, d1 = d_lead + d_hole_tol, d2 = d_lead + d_hole_tol, center = false);
            }
            // pin 2 (pos)
            translate([x_lead_pos_pin2, y_lead_pos_pin2, 0]) {
                soldered_lead_hole(height = h_holder_base + d_lead + h_coincell + h_holder_clip, diameter = d_lead + d_hole_tol, d_padsize = d_solder_pad);
                translate([0, 0, h_holder_base + h_coincell + h_holder_clip + 1 * (d_lead / 3)])
                    rotate([22, 90, 180])
                        cylinder(h = 2, d1 = d_lead + d_hole_tol, d2 = d_lead + d_hole_tol, center = false);
            }
            // pin 3 (neg)
            translate([x_lead_neg_pin, y_lead_neg_pin, 0])
                soldered_lead_hole(height = h_holder_base + d_lead  + d_hole_tol + 2, diameter = d_lead + d_hole_tol, d_padsize = d_solder_pad);
            // horizontal negative contact
            translate([x_lead_neg_pin, y_lead_neg_pin, h_holder_base + d_lead + d_hole_tol - (d_lead / 2)])
                rotate([0, 90, 0])
                    cylinder(h = d_coincell + 6, d1 = d_lead + d_hole_tol, d2 = d_lead + d_hole_tol, center = false);
            translate([x_lead_neg_pin, y_lead_neg_pin, h_holder_base + d_lead + d_hole_tol - 2 * (d_lead / 2)])
                rotate([0, 90, 0])
                    cylinder(h = 6, d1 = d_lead + d_hole_tol, d2 = d_lead + d_hole_tol, center = false);
            translate([x_lead_neg_pin, y_lead_neg_pin, h_holder_base + d_lead + d_hole_tol - 3 * (d_lead / 2)])
                rotate([0, 90, 0])
                    cylinder(h = 2, d1 = d_lead + d_hole_tol, d2 = d_lead + d_hole_tol, center = false);
        }
    }
}

*color("silver") {
    translate([0, 0, h_holder_base + d_lead + 0.1])
        coincell(h_coincell, d_coincell, d_coincell_neg);
}

module soldered_lead_hole(height, diameter, d_padsize) {
    translate([0, 0, height / 2])
        cylinder(h = height, d1 = diameter, d2 = diameter, center = true);
    // leave a clearance dome over solder pad
    translate([0, 0, -0.1])
        cylinder(h = diameter + 0.1, d1 = d_padsize * 1.25, d2 = diameter);
}

module coincell(height, diameter_pos, diameter_neg) {
    union() {
        translate([0, 0, 0.2])
            cylinder(h = height - 0.2, d1 = diameter_pos, d2 = diameter_pos);
        translate([0, 0, 0.01])
            cylinder(h = 0.2, d1 = diameter_neg, d2 = diameter_neg + 0.4);
    }
}


