$fn = 100;
id = 34 * 2 + 1;
od = id + 2;
base_height = 1.5;
height = 17;
e = 0.1;
e2 = e / 2;
max_component_height = 13.7;

module screw() {
    cylinder(3.5, 6 / 2, 6 / 2);
    cylinder(23.2, 3.2 / 2, 3.2 / 2);
}

module hex_nut(height=2.5) {
    cylinder(height, 6.5 / 2, 6.5 / 2, $fn = 6);
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
        translate([-id / 2, 0, 0]) union() {
            // actual button
            translate([0, -4, 0]) cube([5, 8, 8]);
            translate([-15, -4.2 / 2, 1.5]) cube([20, 4.2, 4.5]);
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

module pcb_extra_features_lightguide() {
    // Ethernet port downward extension
    translate([12.5, -18 / 2, -8]) cube([25, 18, 13.5]);
    // Thickened PCB
    translate([0, 0, -0.2]) difference() {
        cylinder(1.6, id / 2, id / 2);
        cylinder(1.6, 16 / 2, 16 / 2);
    };

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

module lightguide_() {
    height = 1 + 2 + 1;
    offset = 1;
    lip = 3;
    // top half
    translate([0, 0, -offset]) difference() {
        cylinder(height, (od + 1) / 2, (od + 1) / 2);
        translate([0, 0, -e2]) cylinder(height + e, (od - 5) / 2, (od - 5) / 2);
    }
    translate([0, 0, -offset + height]) difference() {
        cylinder(lip, (od - 2) / 2, (od - 2) / 2);
        translate([0, 0, -e2]) cylinder(lip + e, (od - 5) / 2, (od - 5) / 2);
    }
    // bottom half
/*
    translate([0, 0, -offset - height]) difference() {
        cylinder(height, (od + 1) / 2, (od + 1) / 2);
        translate([0, 0, -e2]) cylinder(height + e, (od - 5) / 2, (od - 5) / 2);
    }
    translate([0, 0, -offset - height - lip]) difference() {
        cylinder(lip, (od - 2) / 2, (od - 2) / 2);
        translate([0, 0, -e2]) cylinder(lip + e, (od - 5) / 2, (od - 5) / 2);
    }
*/
}

module lightguide() {
    difference() {
        translate([0, 0, 1.6]) lightguide_();
        union() {
            pcb();
            pcb_extra_features_lightguide();
        }
    }
}

module case_top_lightguide_() {
    lightguide_height = 1.6 - 1 + 2 + 1 + 1;
    // Parts affected by extra PCB features
    difference() {
        translate([0, 0, -lightguide_height]) union() {
            // base
            cylinder(base_height, (od + 1) / 2, (od + 1) / 2);
            // base wall shape
            translate([0, 0, base_height]) difference() {
                cylinder(height, (od + 1) / 2, (od + 1) / 2);
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
        translate([0, 0, -lightguide_height]) union() {
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

pcb_thickness = 1.6;
lightguide_offset = -1;
lightguide_height = pcb_thickness + lightguide_offset + 1 + 2 + 1;

module screw_post_top_lightguide(height) {
    difference() {
        union() {
            translate([0, 0, height - 5]) cylinder(5, 5, 5);
            cylinder(height, 3, 3);
        };
        cylinder(height, 3.2 / 2, 3.2 / 2);
    };
}

module case_top_lightguide() {
    height = pcb_thickness + max_component_height - lightguide_height;
    top_plate_thickness = 1.5;
    screw_head_depth = 3.2;
    screw_head_radius = 3;
    
    difference() {
        union() {
            // outer wall
            translate([0, 0, lightguide_height])  difference() {
                cylinder(height, (od + 1) / 2, (od + 1) / 2);
                union() {
                    // inner void
                    translate([0, 0, -e2]) cylinder(height + e, (od - 5) / 2, (od - 5) / 2);
                    // lightguide
                    translate([0, 0, -e2]) cylinder(3 + e2, (od - 2 + 0.5) / 2, (od - 2 + 0.5) / 2);
                }
            }
            difference() {
                union() {
                    // screw posts
                    translate([0, 0, pcb_thickness]) {
                        post_height = max_component_height;
                        translate([18.032521, -12.58848, 0]) screw_post_top_lightguide(post_height);
                        translate([17.992645, 12.65957, 0]) screw_post_top_lightguide(post_height);
                        translate([-21.994568, 0.038583, 0]) screw_post_top_lightguide(post_height);
                    }
                    // top plate
                    translate([0, 0, pcb_thickness + max_component_height]) {
                        cylinder(top_plate_thickness, (od + 1) / 2, (od + 1) / 2);
                    }
                }
                translate([0, 0, pcb_thickness + max_component_height + top_plate_thickness - screw_head_depth]) {
                    translate([18.032521, -12.58848, 0]) cylinder(screw_head_depth + 3, screw_head_radius, screw_head_radius);
                    translate([17.992645, 12.65957, 0]) cylinder(screw_head_depth + 3, screw_head_radius, screw_head_radius);
                    translate([-21.994568, 0.038583, 0]) cylinder(screw_head_depth + 3, screw_head_radius, screw_head_radius);
                }
            }
        }
        pcb();
    }
}

module screw_post_bottom_lightguide(height) {
    translate([0, 0, -height]) difference() {
        cylinder(height, 3, 3);
        cylinder(height, 3.2 / 2, 3.2 / 2);
    };
}

module case_bottom_lightguide() {
    offset_pcb = pcb_thickness + lightguide_offset;
    height_above_pcb = 2.5; // Minimum required to clear all solder joints
    height = offset_pcb + height_above_pcb;
    
    bottom_plate_thickness = 4;
    nut_depth = 2.6;
    
    difference() {
        union() {
            // outer wall
            translate([0, 0, offset_pcb - height])  difference() {
                cylinder(height, (od + 1) / 2, (od + 1) / 2);
                union() {
                    // inner void
                    translate([0, 0, -e2]) cylinder(height + e, (od - 5) / 2, (od - 5) / 2);
                    // lightguide
                    translate([0, 0, -e2]) cylinder(3 + e2, (od - 2 + 0.5) / 2, (od - 2 + 0.5) / 2);
                }
            }
            difference() {
                union() {
                    // screw posts
                    translate([0, 0, 0]) {
                        post_height = height_above_pcb;
                        translate([18.032521, -12.58848, 0]) screw_post_bottom_lightguide(post_height);
                        translate([17.992645, 12.65957, 0]) screw_post_bottom_lightguide(post_height);
                        translate([-21.994568, 0.038583, 0]) screw_post_bottom_lightguide(post_height);
                        
                        translate([0, 0, -post_height]) cylinder(post_height, 8 / 2 + 4, 8 / 2 + 4);
                    }
                    // bottom plate
                    translate([0, 0, -height_above_pcb - bottom_plate_thickness]) {
                        cylinder(bottom_plate_thickness, (od + 1) / 2, (od + 1) / 2);
                    }
                }
                translate([0, 0, -height_above_pcb - bottom_plate_thickness]) {
                    translate([18.032521, -12.58848, 0]) hex_nut(nut_depth);
                    translate([17.992645, 12.65957, 0]) hex_nut(nut_depth);
                    translate([-21.994568, 0.038583, 0]) hex_nut(nut_depth);

                    translate([18.032521, -12.58848, 0]) cylinder(5, 3.2 / 2, 3.2 / 2);
                    translate([17.992645, 12.65957, 0]) cylinder(5, 3.2 / 2, 3.2 / 2);
                    translate([-21.994568, 0.038583, 0]) cylinder(5, 3.2 / 2, 3.2 / 2);
                    
                    cylinder(10, 8 / 2, 8 / 2);
                }
            }
        }
        pcb();
    } 
}

color("white") lightguide();
//pcb();
//color("blue") translate([0, 0, base_height + height]) rotate([180, 0, 0]) case_top_lightguide_();
color("blue") case_top_lightguide();
color("green") case_bottom_lightguide();

// printable
//!translate([0, 0, 16.8]) rotate([180, 0, 0]) case_top_lightguide();
//!translate([0, 0, 2.5 + 3 + 1]) case_bottom_lightguide();

/*
translate([40, 0, 0]) {
    translate([-80, 0, 23]) rotate([0, 180, 0]) color("red") case_bottom();
    color("blue") case_top();
}
*/

/*
translate([40, 0, base_height + 13 + 1.6 / 2]) rotate([90, 0, -18 + 90]) translate([0, 0, -50]) import("/home/tsys/Downloads/tallylight_stl/ImageToStl.com_tallylight/ImageToStl.com_tallylight.stl");
*/
