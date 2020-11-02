package main

import "fsw"
import "core:fmt"
import "core:time"

main :: proc (){
    using fsw;
    
    //  Create a new file system watcher
    fsw, err_code := fsw_create();
    defer fsw_destroy(&fsw);

    //  add new folder to watch
    err_code = fsw_add_dir(&fsw, "." );
    //  looping for events
    for { 
        
        for evt in fsw_get_events( &fsw ) {
            fmt.printf("{}\n", evt);
            // sleep one second here to not kill your cpu :)
            time.sleep( time.Millisecond );
        }
    }
    //  err_code is GetLastError() of windows api
}