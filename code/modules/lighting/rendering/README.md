This rendering section contains wrappers for interacting with the
lighting subsystems light_source_grid variable.

light_source_grid should not be modified or accessed outside of here
to keep the code clean and nice.

The stuff being done here gets extremely confusing and interacts with
byond in very strange ways, so this needs to not have random accesses
to stuff that isn't clearly defined.
