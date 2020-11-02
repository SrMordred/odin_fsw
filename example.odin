package main

import "fsw"
import "core:fmt"
import "core:time"

main :: proc (){
    using fsw;
    
    //  Create a new file system watcher
    //  fsw_create(buffer_sze = 1024 * 16, allocator = context.allocator);
    fsw, err_code := fsw_create();
    defer fsw_destroy(&fsw);

    //  add new folder to watch
    err_code = fsw_add_dir(&fsw, "." );
    //  looping for events
    for { 
        //  you can also do 
        //  fsw_get_events( &fsw , .BLOCKING)
        for evt in fsw_get_events( &fsw ) {
            fmt.printf("{}\n", evt);
            // sleep one second here to not kill your cpu :)
            time.sleep( time.Millisecond );
        }
    }
    //  err_code is GetLastError() of windows api
}