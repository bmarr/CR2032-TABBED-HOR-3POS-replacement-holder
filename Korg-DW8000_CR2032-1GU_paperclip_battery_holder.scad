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
x_lead_neg_pin = x_lead_pos_pin1 - 16; // was 17.8, but then I measured the actual battery!
a_pos_pin = atan((y_lead_pos_pin1 - d_lead ) / (x_lead_pos_pin1 - d_lead / 2));
a_pos_pin_range = atan((y_lead_pos_pin1 + (d_lead / 2)) / (x_lead_pos_pin1 - d_lead / 2));
a_pos_pin_lean = -8;

h_holder_base = 1.2;
w_holder_walls = 2.5;
d_holder = d_coincell + d_coincell_tol + 2 * w_holder_walls;
a_holder_clip = 22; // angle of width of holder vertical flex tabs
h_holder_clip = 2; // height of clip overhang
w_holder_clip = 1; // extent of clip overhang
//w_holder_sweep = (sin(a_holder_clip) * ((d_coincell / 2) + d_coincell_tol + w_holder_walls)) / 2; // 
w_holder_sweep = w_holder_walls;
a_flex_relief_cut = 4; // 4 degrees for now, TODO: calculate

union() {
    difference() {
        union() {
            union() {
                difference() {
                    union() {
                        // battery enclosure
                        difference() {
                            translate([0, 0, 0])
                                cylinder(h = h_holder_base + d_lead + h_coincell, d1 = d_holder, d2 = d_holder);
                            translate([0, 0, h_holder_base + d_lead + 0.1])
                                coincell(h_coincell, d_coincell + d_coincell_tol, d_coincell_neg);
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
                        // flex tab base strengthening chamfer parallel to outside NEG edge of coincell
                        for (m = [0:1:1])
                            mirror(v = [0, m, 0])
                                translate([0, 0, h_holder_base + d_lead + (d_hole_tol / 2) - 0.01]) {
                                    rotate(a = -180 - a_holder_clip * 3, v = [0, 0, 1])
                                        rotate_extrude(angle = (a_holder_clip * 3) / 2, convexity = 10) {
                                                translate([d_coincell / 2 + (d_coincell_tol / 2) - (w_holder_clip / 2), 0, 0])
                                                    polygon(points = [[0, 0], [(w_holder_clip / 2), 0], [(w_holder_clip / 2) + 0.03, (w_holder_clip / 1)]]);
                                                    //square([w_holder_walls / 2 + 0.03, (h_holder_base + d_lead + d_hole_tol) / 2 + 0.03], center = false);
                                        }
                                }

                        // positive lead retainer
                        union() {
                            difference() {
                                translate([d_coincell / 2 + 2, 0, (h_holder_base + d_lead + h_coincell)/2 - 0.15]) {
                                    cube([6.5, 2 * y_lead_pos_pin1 + 8, h_holder_base + d_lead + h_coincell + - 0.3], center = true);
                                }
                                cylinder(h = h_holder_base + d_lead + h_coincell, d1 = d_holder, d2 = d_holder);
                            }
                            translate([0, 0, h_holder_base + d_lead + h_coincell - 0.3]) {
                                rotate(a = -a_holder_clip, v = [0, 0, 1])
                                    rotate_extrude(angle = 2*a_holder_clip, convexity = 10) {
                                        translate([d_coincell / 2 + (d_coincell_tol / 2) + w_holder_walls, 0, 0])
                                            polygon(points = [[0, 0], [0, h_holder_clip + 0.3], [2, 0]]);
                                    }
                            }
                        }
                    }
                    // clip relief cuts
                    translate([0, 0, h_holder_base + d_lead + 0.01])
                        rotate(a = -180 - (a_holder_clip * 3) / 2, v = [0, 0, 1])
                            rotate_extrude(angle = a_holder_clip * 3, convexity = 10) {
                                    translate([d_coincell / 2 + (d_coincell_tol / 2) - 0.01, 0, 0])
                                        square([w_holder_sweep + 0.02, h_coincell + h_holder_clip]);
                            }
                    // clip flex tab relief cuts (to allow flex at base)
                    for (m = [0:1:1])
                        mirror(v = [0, m, 0])
                            translate([0, 0, - 0.01]) {
                                // shoulder A
                                rotate(a = -180 - (a_holder_clip * 3) / 2, v = [0, 0, 1])
                                    rotate_extrude(angle = a_flex_relief_cut, convexity = 10) {
                                            translate([d_coincell / 2 + (d_coincell_tol / 2) - w_holder_clip - 0.01, 0, 0])
                                                square([w_holder_sweep + w_holder_clip + 0.03, h_holder_base + d_lead + d_hole_tol + h_coincell + h_holder_clip + 0.03], center = false);
                                    }
                                // shoulder B
                                rotate(a = -180 - a_holder_clip * 3 - a_flex_relief_cut, v = [0, 0, 1])
                                    rotate_extrude(angle = a_flex_relief_cut, convexity = 10) {
                                            translate([d_coincell / 2 + (d_coincell_tol / 2) - w_holder_clip - 0.01, 0, 0])
                                                square([w_holder_sweep + w_holder_clip + 0.03, h_holder_base + d_lead + d_hole_tol + h_coincell + h_holder_clip + 0.03], center = false);
                                    }
                                // base corner chamfer
                                rotate(a = -180 - a_holder_clip * 3 - 0.01, v = [0, 0, 1])
                                    rotate_extrude(angle = (a_holder_clip * 3) / 2 + 0.02, convexity = 10) {
                                            translate([d_coincell / 2 + (d_coincell_tol / 2) - w_holder_clip - 0.01, 0, 0])
                                                polygon(points = [[0, 0], [w_holder_sweep + w_holder_clip + 0.03, 0], [w_holder_sweep + w_holder_clip + 0.03, (h_holder_base + d_lead + d_hole_tol) / 1 + 0.03]]);
                                                //square([w_holder_walls / 2 + 0.03, (h_holder_base + d_lead + d_hole_tol) / 2 + 0.03], center = false);
                                    }
                                
                            }
                    // positive lead exposure
                    translate([0, 0, h_holder_base + d_lead + 0.01])
                        rotate(a = -a_pos_pin_range, v = [0, 0, 1])
                            rotate_extrude(angle = a_pos_pin_range * 2, convexity = 10) {
                                    translate([d_coincell / 2 + (d_coincell_tol / 2) - (d_lead / 2) - 0.01, 0, 0])
                                        square([d_lead, h_coincell]);
                            }
                    
                    // positive lead vertical guide
                    rotate([0, a_pos_pin_lean, 0]) {
                        translate([x_lead_pos_pin2, 0, h_holder_base -0.5]) {
                                hull() {
                                    cube([d_lead + d_hole_tol, y_lead_pos_pin1 - y_lead_pos_pin2, h_holder_base + h_coincell + (d_lead + d_hole_tol) / 4 + 0.5] , center = true);
                                    translate([0, 0, h_coincell - (d_lead + d_hole_tol) / 2])
                                        rotate([90, 0, 0])
                                            cylinder(h = y_lead_pos_pin1 - y_lead_pos_pin2, d1 = d_lead + d_hole_tol, d2 = d_lead + d_hole_tol, center = true);
                                }
                            }
                    }
                    // positive lead ceiling overhang trim
                    translate([0, 0, h_holder_base + h_coincell + (d_lead / 2) - 0.01]) {
                        rotate(a = -(a_holder_clip)-1, v = [0, 0, 1])
                            rotate_extrude(angle = 2 * a_holder_clip + 2, convexity = 10) {
                                translate([d_coincell / 2 + (d_coincell_tol / 2) - 0.01, 0, 0])
                                    polygon(points = [[0, 0], [d_lead, 0], [-d_lead, h_holder_clip + 0.2], [0, h_holder_clip + 0.2], [-2*d_lead - 0.2, h_holder_clip + 0.2]]);
                    }
                }

                }
                
                // positive wire lock tab
                translate([0, 0, h_holder_base + d_lead + d_hole_tol]) {
                    rotate(a = -(a_holder_clip / 2), v = [0, 0, 1])
                        rotate_extrude(angle = a_holder_clip, convexity = 10) {
                            translate([d_coincell / 2 + (d_coincell_tol / 2) + d_lead - 0.01, 0, 0])
                                polygon(points = [[0, 0], [0, h_holder_clip], [-d_lead - 0.2, h_holder_clip]]);
                        }
                }
            }

        }
        // pin holes (paperclips?)
        {
            // pin 1 (pos)
            translate([x_lead_pos_pin1, y_lead_pos_pin1, -0.2]) {
                rotate([0, a_pos_pin_lean, 22]) {
                    soldered_lead_hole(height = h_holder_base + d_lead + h_coincell + h_holder_clip, diameter = d_lead + d_hole_tol, d_padsize = d_solder_pad * 1.5);
                    translate([0, 0, h_holder_base + h_coincell + h_holder_clip + 1 * (d_lead / 3)])
                        rotate([0, 90, 180])
                            translate([1.5, 0, 0])
                                cube([d_lead + d_hole_tol, d_lead + d_hole_tol + 0.01, 3], center = true);
                }
            }
            // pin 2 (pos)
            translate([x_lead_pos_pin2, y_lead_pos_pin2, -0.2]) {
                rotate([0, a_pos_pin_lean, -22]) {
                    soldered_lead_hole(height = h_holder_base + d_lead + h_coincell + h_holder_clip, diameter = d_lead + d_hole_tol, d_padsize = d_solder_pad * 1.5);
                    translate([0, 0, h_holder_base + h_coincell + h_holder_clip + 1 * (d_lead / 3)])
                        rotate([0, 90, 180])
                            translate([1.5, 0, 0])
                                    cube([d_lead + d_hole_tol, d_lead + d_hole_tol + 0.01, 3], center = true);
                }
            }
            // pin 3 (neg) - horizontal channel
            translate([x_lead_neg_pin, y_lead_neg_pin, 0])
                soldered_lead_hole(height = h_holder_base + d_lead  + d_hole_tol + 2, diameter = d_lead + d_hole_tol, d_padsize = d_solder_pad * 1.5);
            // horizontal negative contact restraining sleeve
            translate([x_lead_neg_pin, y_lead_neg_pin, h_holder_base + d_lead + d_hole_tol + (d_lead / 1)])
                rotate([0, 98, 0])
                    cylinder(h = d_coincell + 6, d1 = d_lead + d_hole_tol, d2 = d_lead + d_hole_tol, center = false);
            translate([x_lead_neg_pin, y_lead_neg_pin, h_holder_base + d_lead + d_hole_tol - 2 * (d_lead / 2)])
                rotate([0, 83, 0])
                    cylinder(h = d_coincell / 2, d1 = d_lead + d_hole_tol, d2 = d_lead + d_hole_tol, center = false);
            // cleanup access to battery NEG pad
            translate([x_lead_neg_pin, y_lead_neg_pin, h_holder_base + d_lead + d_hole_tol - 0.2])
                rotate([0, 90, 0])
                    cylinder(h = d_coincell / 2 + 4, d1 = d_lead + d_hole_tol, d2 = d_lead + d_hole_tol, center = false);
            // cut a slip channel into fingernail end for pre-soldered NEG wire to glide through.
            translate([x_lead_neg_pin, y_lead_neg_pin + (d_lead + d_hole_tol) / 2, -0.01]) {
                rotate([0, 0, 180])
                    cube([x_lead_neg_pin + (d_holder / 2) + 0.1, d_lead + d_hole_tol, h_holder_base + d_lead + d_hole_tol + 0.02], center = false );
            }

            // Korg DM8000 fitment customization (deleting parts of body to fit better)
            //  Make room for capacitor C97
            translate([0, 0, -0.01])
                rotate(a = -(a_holder_clip * 3)/2, v = [0, 0, 1])
                    rotate_extrude(angle = a_holder_clip * 3, convexity = 10) {
                        translate([-(d_holder / 2)- 0.01, 0, -0.01])
                            square([w_holder_walls + 0.02, h_holder_base + d_lead + 0.03]);
                    }
            // Make room for R99
            translate([7.5, 8.3, -0.01])
                cube([7.8, 2, h_holder_base + d_lead + (d_hole_tol / 2) + h_coincell], center = false);

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
        cylinder(h = diameter + 0.1, d1 = d_padsize * 1.25, d2 = diameter, center = false);
}

module coincell(height, diameter_pos, diameter_neg) {
    union() {
        translate([0, 0, 0.2])
            cylinder(h = height - 0.2, d1 = diameter_pos, d2 = diameter_pos);
        translate([0, 0, 0.01])
            cylinder(h = 0.2, d1 = diameter_neg, d2 = diameter_neg + 0.4);
    }
}


