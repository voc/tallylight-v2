$fn = 100;
id = 34 * 2 + 1;
od = id + 2;
base_height = 1.5;
height = 17;

module screw() {
    cylinder(3.5, 6 / 2, 6 / 2);
    cylinder(23.2, 3.2 / 2, 3.2 / 2);
}

module hex_nut() {
    cylinder(2.5, 6.5 / 2, 6.5 / 2, $fn = 6);
}

module screw_with_nut() {
    screw();
    translate([0, 0, 23.2 - 2.5]) hex_nut();
}

module screw_post_top() {
    difference() {
        union() {
            cylinder(13.5, 3, 3);
            cylinder(5, 5, 5);
        };
        cylinder(13.5, 3.2 / 2, 3.2 / 2);
    };
}

module screw_post_bottom() {
    translate([0, 0, -4]) difference() {
        cylinder(4, 3, 3);
        cylinder(4, 3.2 / 2, 3.2 / 2);
    };
}

module pcb() {
    // PCB
    difference() {
        cylinder(1.6, id / 2, id / 2);
        cylinder(1.6, 16 / 2, 16 / 2);
    };
    translate([0, 0, 1.6]) union() {
        // Ethernet port
        translate([12.5, -18 / 2, 0]) cube([25, 18, 13.5]);
        // USB port
        translate([24.190, 17.208, 3.5 / 2]) rotate([0, 0, 34.5]) translate([3, 0, 0]) cube([10, 9.5, 3.5], center=true);
        // Button
        translate([-id / 2 - 15, -4.2 / 2, 0]) union() {
            // actual button
            cube([20, 4.2, 6]);
        }
    }  
}

module pcb_extra_features_bottom() {
    // THT joints
    translate([0, 0, -2.5]) {
        cylinder(2.5, id / 2 - 2, id / 2 - 2);                
    }
    translate([0, 0, 1.6]) union() {
        // LEDs
        translate([0, 0, -0.5]) cylinder(3, (od - 1) / 2, (od - 1) / 2);
        // Button
        translate([-id / 2 - 15, -3.7 / 2, 0]) union() {
            // extended slot
//            translate([0, 0, -10]) cube([20, 3.7, 10]);
        }
    }
}

module pcb_extra_features_top() {
    // THT joints
    translate([0, 0, -2.5]) {
        cylinder(2.5, id / 2 - 2, id / 2 - 2);                
    }
    translate([0, 0, 1.6]) union() {
        // LEDs
        translate([0, 0, -0.5]) cylinder(3, (od - 1) / 2, (od - 1) / 2);
        // Button
        translate([-id / 2 - 15, -4.2 / 2, 0]) union() {
            // extended slot
            translate([0, 0, -10]) cube([20, 4.2, 10]);
        }
    }
}

module case_top() {
    // Parts affected by extra PCB features
    difference() {
        union() {
            // base
            cylinder(base_height, od / 2, od / 2);
            // base wall shape
            translate([0, 0, base_height]) difference() {
                cylinder(height, od / 2, od / 2);
                cylinder(height, id / 2, id / 2);
            }
            translate([0, 0, base_height]) {
                translate([18.032521, -12.58848, 0]) screw_post_top();
                translate([17.992645, 12.65957, 0]) screw_post_top();
                translate([-21.994568, 0.038583, 0]) screw_post_top();
            }
        }
        // PCB features
        union() {
            translate([0, 0, base_height + 1.6 + 13.5]) rotate([180, 0, 0]) union() {
                pcb();
                pcb_extra_features_top();
            }
            translate([18.032521, -12.58848, 0]) screw_with_nut();
            translate([17.992645, 12.65957, 0]) screw_with_nut();
            translate([-21.994568, 0.038583, 0]) screw_with_nut();
        };
    }
    // Parts not affected by extra PCB features
    difference() {
        union() {
            translate([0, 0, base_height]) {
                translate([18.032521, -12.58848, 0]) screw_post_top();
                translate([17.992645, 12.65957, 0]) screw_post_top();
                translate([-21.994568, 0.038583, 0]) screw_post_top();
            }
        }
        // PCB features
        union() {
            translate([0, 0, base_height + 1.6 + 13.5]) rotate([180, 0, 0]) union() {
                pcb();
            }
            translate([18.032521, -12.58848, 0]) screw_with_nut();
            translate([17.992645, 12.65957, 0]) screw_with_nut();
            translate([-21.994568, 0.038583, 0]) screw_with_nut();
        };
    }
    //translate([0, 0, base_height + 1.6 + 13.5]) rotate([180, 0, 0]) pcb();
    //translate([18.032521, -12.58848, 0]) screw_with_nut();
    //translate([17.992645, 12.65957, 0]) screw_with_nut();
    //translate([-21.994568, 0.038583, 0]) screw_with_nut();
}

module case_bottom() {
    difference() {
        translate([0, 0, base_height * 2 + height ]) {
            translate([18.032521, -12.58848, 0]) screw_post_bottom();
            translate([17.992645, 12.65957, 0]) screw_post_bottom();
            translate([-21.994568, 0.038583, 0]) screw_post_bottom();
            translate([0, 0, -4]) difference() {
                cylinder(4, (id - 0.5) / 2, (id - 0.5) / 2);
                cylinder(4, (id - 2) / 2, (id - 2) / 2);
            }
            // 1/4" insert support column
            translate([0, 0, -13.7 + 4.7 - base_height]) cylinder(13.7, (8 + 3.5 * 2) / 2, (8 + 3.5 * 2) / 2);
        }
        union() {
            translate([0, 0, base_height + 1.6 + 13.5]) rotate([180, 0, 0]) union() {
                pcb();
            }
            // 1/4" insert hole
            translate([0, 0, base_height + height - 13.7 + 4.7]) cylinder(13.7, 8 / 2, 8 / 2);
        }
    }

    difference() {
        translate([0, 0, base_height + height]) union() {
            // base
            cylinder(4.7, od / 2, od / 2);
            // 1/4" insert support column
            translate([0, 0, -13.7 + 4.7]) cylinder(13.7, (8 + 3.5 * 2) / 2, (8 + 3.5 * 2) / 2);
        }
        // PCB features
        union() {
            translate([0, 0, base_height + 1.6 + 13.5]) rotate([180, 0, 0]) union() {
                pcb();
                pcb_extra_features_bottom();
            }
            translate([18.032521, -12.58848, 0]) screw_with_nut();
            translate([17.992645, 12.65957, 0]) screw_with_nut();
            translate([-21.994568, 0.038583, 0]) screw_with_nut();
            // 1/4" insert hole
            translate([0, 0, base_height + height - 13.7 + 4.7]) cylinder(13.7, 8 / 2, 8 / 2);
        };
    }
    //translate([0, 0, base_height + 1.6 + 13.5]) rotate([180, 0, 0]) pcb();
    //translate([18.032521, -12.58848, 0]) screw_with_nut();
    //translate([17.992645, 12.65957, 0]) screw_with_nut();
    //translate([-21.994568, 0.038583, 0]) screw_with_nut();
}

translate([40, 0, 0]) {
    translate([-80, 0, 23]) rotate([0, 180, 0]) color("red") case_bottom();
    color("blue") case_top();
}