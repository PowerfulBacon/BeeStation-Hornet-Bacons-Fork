This rendering section contains wrappers for interacting with the
lighting subsystems light_source_grid variable.

light_source_grid should not be modified or accessed outside of here
to keep the code clean and nice.

The stuff being done here gets extremely confusing and interacts with
byond in very strange ways, so this needs to not have random accesses
to stuff that isn't clearly defined.

TODO:
 - Investigate possible crashes on high amounts of small lights
 - Move the shadows to the center of turfs and blur them
 - Remove rotation proc, replace with icon rotations
 - Remake the get_lum_count proc
 - Personal lights shouldnt affect luminosity
 - FIX HARD DELS
 - Fix thrown lights having a messed up offset
 - Make luminsoity updates a slower thing on the subsystem
 ? Add movement icons for moving lights
