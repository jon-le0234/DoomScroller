use <quickthread.scad>

// Comments structure:
// HEADING 1
// Heading 2
// heading 3

// TABLE OF CONTENTS
// OVERVIEW
    // Purpose
// VARIABLES
    // Parametric variables 
    // Optional variables 
    // Constants
// POLYGONS

// OVERVIEW

// Purpose
// Parametric model for the DoomScroller clamp
// https://www.printables.com/model/569377-the-mini-doomscroller-a-portable-smartphone-tripod
// Finally crumbled and was forced to learn OpenSCAD for a model that needed to be parameterized.

// VARIABLES

// 1. Parametric Variables

// device_width
device_width = 80;
device_height = 10;
// using "_height" to align with OpenSCAD's use of height for Z-axis
// normally would refer to it as device_depth when device is facing you and Z-axis travels through the screen, but that would be too confusing here
device_depth = 160;

// Optional Variables

// distance to determine strength of adhesion keep clamp frame's left-top prism adhered to left-bottom prism
prism_connector_width = 7;

// distance for clamp left-top prism to hang over the device bezel
bezel_overhang = 2;

// CONSTANTS

// clamp frame
clamp_frame_base_height = 8;
clamp_frame_base_depth = 15;

// clamp screw
clamp_nut = 8;

// clamp screw distance 
// SAFETY FIRST: adding more than 2 mm to 3 mm of clamping distance means you could crush a device
clamp_screw_distance = 2;

// clamp movable jaw
clamp_movable_jaw_cube_x = 3;
clamp_movable_jaw_cube_y = 25;
clamp_movable_jaw_cube_z = 25;

// clamp movable jaw key
// would normally define closer to the 
clamp_movable_jaw_key_cube_y = 7;
clamp_movable_jaw_key_cube_z = 2;

// overlap factor for joining OpenSCAD objects
overlap = 0.001;

// POLYGONS

// Polygon dimensions are defined just above the polygon functions. Then translation units are listed below them.
// That makes it easier to locate and edit the variables.
// Also makes the code much more verbose, but this is also my first major OpenSCAD project.

// Device
device_cube_x = device_width;
device_cube_y = device_depth;
device_cube_z = device_height;

device_cube_translation_y = -device_depth/2 + clamp_frame_base_depth/2;
device_cube_translation_z = clamp_frame_base_height;

//translate([0,device_cube_translation_y,device_cube_translation_z]) cube([device_cube_x, device_cube_y, device_cube_z]);

// Clamp Frame

// clamp frame base
base_cube_x = device_width - clamp_screw_distance;
base_cube_y = clamp_frame_base_depth;
base_cube_z = clamp_frame_base_height;

// cube to reduce print of clamp base
clamp_base_reduce_cube_x = base_cube_x - 1;
clamp_base_reduce_cube_y = base_cube_y - 2;
clamp_base_reduce_cube_z = 2 + overlap;

clamp_base_reduce_cube_translate_y = 1;
clamp_base_reduce_cube_translate_z = 6;

// cube to create opening between clamp base border and screw key
clamp_base_border_key_cube_x = 1 + 2*overlap;
clamp_base_border_key_cube_y = clamp_movable_jaw_key_cube_y;
clamp_base_border_key_cube_z = clamp_movable_jaw_key_cube_z + 2*overlap;

clamp_base_border_key_cube_translate_x = base_cube_x - 1 - overlap;
clamp_base_border_key_cube_translate_y = clamp_frame_base_depth/2 - clamp_base_border_key_cube_y/2;
clamp_base_border_key_cube_translate_z = 6;

// subtract clamp_base_reduce from clamp_base
difference() {
cube([base_cube_x, base_cube_y, base_cube_z]);
    // print reduction
translate([0, clamp_base_reduce_cube_translate_y, clamp_base_reduce_cube_translate_z]) cube([clamp_base_reduce_cube_x, clamp_base_reduce_cube_y, clamp_base_reduce_cube_z]);
    // border-key opening
translate([clamp_base_border_key_cube_translate_x, clamp_base_border_key_cube_translate_y, clamp_base_border_key_cube_translate_z]) cube([clamp_base_border_key_cube_x, clamp_base_border_key_cube_y, clamp_base_border_key_cube_z]);
}

// prism module taken from user manual:
// https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Primitive_Solids#polyhedron
// modified variables to better represent how it will appear
module prism(x, y, z){
      polyhedron(//pt 0        1        2        3        4        5
              points=[[0,0,0], [x,0,0], [x,y,0], [0,y,0], [0,y,z], [x,y,z]],
              faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
              );
      }

// left-bottom prism of clamp frame
// translated to left side of clamp frame cube, then rotated 90º about Z-axis
// rotating then translating makes for trouble
left_bottom_prism_x = clamp_frame_base_depth;
left_bottom_prism_y = device_height/2;
left_bottom_prism_z = device_height/2 + 1;
      
left_bottom_prism_translate_z = clamp_frame_base_height;

translate([0, 0, left_bottom_prism_translate_z]) rotate([0, 0, 90]) prism(left_bottom_prism_x, left_bottom_prism_y, left_bottom_prism_z);

// left-top prism of clamp frame
// translated to left side of clamp frame cube, then rotated 90º about X- and Z-axes
left_top_prism_x = clamp_frame_base_depth;
left_top_prism_y = device_height/2 + 1;
left_top_prism_z = device_height/2 + bezel_overhang;

left_top_prism_translate_x = -device_height/2;
left_top_prism_translate_z = clamp_frame_base_height + left_bottom_prism_z;

translate([left_top_prism_translate_x, 0, left_top_prism_translate_z]) rotate([90,0,90]) prism(left_top_prism_x, left_top_prism_y, left_top_prism_z);

// cube to join clamp base and left-bottom prism
cube_base_prism_x = device_height/2 + overlap;
cube_base_prism_y = clamp_frame_base_depth;
cube_base_prism_z = clamp_frame_base_height + overlap;

cube_base_prism_translate_x = cube_base_prism_x - overlap;

translate([-cube_base_prism_translate_x, 0, 0]) cube([cube_base_prism_x, cube_base_prism_y, cube_base_prism_z]);

// cube to define clamp frame prisms' adhesions area
// also join clamp left-bottom and left-top prisms
left_prisms_cube_x = prism_connector_width + overlap;
left_prisms_cube_y = clamp_frame_base_depth;
left_prisms_cube_z = clamp_frame_base_height + left_bottom_prism_z + left_top_prism_y;

cube_left_prisms_translate_x = left_prisms_cube_x + left_bottom_prism_y - overlap;

translate([-cube_left_prisms_translate_x, 0, 0]) cube([left_prisms_cube_x, left_prisms_cube_y, left_prisms_cube_z]);

// Clamp screw

// screw
screw_diameter = 15;
screw_length = clamp_screw_distance + clamp_movable_jaw_cube_x + clamp_nut + overlap;
screw_pitch = 1.5;

screw_translate_x = base_cube_x - overlap;
screw_translate_y = clamp_frame_base_depth/2;
screw_translate_z = (device_height-2)/2;

// screw flattening top
screw_flat_top_cube_x = screw_diameter/2 - 4;
screw_flat_top_cube_y = screw_diameter;
screw_flat_top_cube_z = screw_length + 2*overlap;

screw_flat_top_cube_translate_x = 4;
screw_flat_top_cube_translate_y = -screw_diameter/2;
screw_flat_top_cube_translate_z = -overlap;

// screw flattening bottom
screw_flat_bottom_cube_x = screw_diameter/2 - 4;
screw_flat_bottom_cube_y = screw_diameter;
screw_flat_bottom_cube_z = screw_length + 2*overlap;

screw_flat_bottom_cube_translate_x = 4;
screw_flat_bottom_cube_translate_y = -screw_diameter/2;
screw_flat_bottom_cube_translate_z = -overlap;

// screw key
// mixing z and x because of order of operations required for translation and rotation later
screw_key_cube_x = clamp_movable_jaw_key_cube_z + overlap;
screw_key_cube_y = clamp_movable_jaw_key_cube_y;
screw_key_cube_z = screw_length + 2*overlap;

screw_key_cube_translate_x = -4 - overlap;
screw_key_cube_translate_y = -screw_key_cube_y/2;
screw_key_cube_translate_z = -overlap;

translate([screw_translate_x, screw_translate_y, screw_translate_z]) rotate([0, 90, 0]) 
difference() {
isoThread(d = screw_diameter, h = screw_length, pitch = screw_pitch, angle=40, internal=false,$fn=60);
translate([screw_flat_top_cube_translate_x, screw_flat_top_cube_translate_y, screw_flat_top_cube_translate_z]) cube([screw_flat_top_cube_x, screw_flat_top_cube_y, screw_flat_top_cube_z]);
mirror([1, 0, 0])
translate([screw_flat_bottom_cube_translate_x, screw_flat_bottom_cube_translate_y, screw_flat_bottom_cube_translate_z]) cube([screw_flat_bottom_cube_x, screw_flat_bottom_cube_y, screw_flat_bottom_cube_z]);
translate([screw_key_cube_translate_x, screw_key_cube_translate_y, screw_key_cube_translate_z]) cube([screw_key_cube_x, screw_key_cube_y, screw_key_cube_z]);

}
//
