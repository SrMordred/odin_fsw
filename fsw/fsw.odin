package fsw

import "core:fmt"
import "core:mem"
eprintf :: fmt.eprintf;

//  events that are being whatched now. 
//  May change if needed
FSW_WATCHING_EVENTS : DWORD : 
    FILE_NOTIFY_CHANGE_FILE_NAME | 
    FILE_NOTIFY_CHANGE_DIR_NAME  |
    FILE_NOTIFY_CHANGE_LAST_WRITE;

FSW :: struct {
    allocator : mem.Allocator,
    iocp_handler: HANDLE,
    buffer: []byte,
    fws_id_list: [dynamic]^FSW_ID
}

FSW_ID :: struct {
    overlapped: OVERLAPPED,
    handle: HANDLE,
    path: string
}

FSW_Event_Type :: enum {
    CREATED,
    REMOVED,
    MODIFIED,
    RENAMED,
}

FSW_Event :: struct {
    filename: string,
    old_filename:string,
    event: FSW_Event_Type 
}

fsw_create :: proc ( buffer_size:= 16 * 1024, allocator:= context.allocator ) -> (FSW, DWORD) {
    iocp := CreateIoCompletionPort(INVALID_HANDLE, nil, 0,1);
    if iocp == INVALID_HANDLE do return FSW{}, GetLastError();

    return FSW{ 
        allocator = allocator,
        iocp_handler = iocp, 
        buffer = make([]byte, buffer_size, allocator),
        fws_id_list = [dynamic]^FSW_ID{} 
    }, 0;
}

fsw_add_dir :: proc (fsw: ^FSW, path: string) -> DWORD {
    wide_path := utf8_to_wstring( path, context.temp_allocator );
    handle    := CreateFileW( wide_path , 
        FILE_LIST_DIRECTORY,
        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, 
        nil, 
        OPEN_EXISTING,
        FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OVERLAPPED, 
        nil
    );

    if handle == INVALID_HANDLE {
        eprintf("ERROR: CreateFileW\n");
        return GetLastError();
    }

    if CreateIoCompletionPort(handle, fsw.iocp_handler , 0, 1) == INVALID_HANDLE {
        eprintf("ERROR: CreateIoCompletionPort\n");
        return GetLastError();
    }

    fsw_id :      = new( FSW_ID, fsw.allocator );
    fsw_id.handle = handle;
    fsw_id.path   = path;

    append(&fsw.fws_id_list, fsw_id );

    if ReadDirectoryChangesW(
        fsw_id.handle, 
        &fsw.buffer[0],
        u32( len(fsw.buffer) ),
        true,
        FSW_WATCHING_EVENTS,
        nil, 
        &fsw_id.overlapped, 
        nil) == BOOL(false) 
    {
        eprintf( "ReadDirectoryChangesW failed! \n");
        return GetLastError();
    }

    return 0;
}

fsw_get_events :: proc ( fsw: ^FSW )  -> []FSW_Event {
    overlapped: ^OVERLAPPED;
    n_of_bytes := DWORD(0);
    comp_key   := ULONG_PTR(0); //have no idea why i need this, but it wont work without it

    if GetQueuedCompletionStatus(fsw.iocp_handler, &n_of_bytes, &comp_key, &overlapped, 0) == BOOL(false) {
        return []FSW_Event{};
    }

    events := make( [dynamic]FSW_Event, context.temp_allocator );
    event_old_filename:= "";

    notifications := (^FILE_NOTIFY_INFORMATION)( &fsw.buffer[0] );
    
    for {

        filename_len    := int( notifications.file_name_length );
        filename_w      := Wstring(&notifications.file_name[0]);
        filename        := wstring_to_utf8( auto_cast filename_w , (filename_len / size_of( type_of(filename_w^))), context.temp_allocator );
        action          := notifications.action;

        event_filename := filename;
        event_event_type: FSW_Event_Type;

        switch action {
            case FILE_ACTION_ADDED:
                event_event_type = .CREATED;
            case FILE_ACTION_REMOVED:
                event_event_type = .REMOVED;
            case FILE_ACTION_MODIFIED:
                event_event_type = .MODIFIED;
            case FILE_ACTION_RENAMED_OLD_NAME:
                event_old_filename = event_filename;
            case FILE_ACTION_RENAMED_NEW_NAME:
                event_event_type = .RENAMED;
            case:
                eprintf("{} - Unknow action {} \n", event_filename, action );
        }

        // Transform rename_old, rename_new into one event
        if action != FILE_ACTION_RENAMED_OLD_NAME {
            append(&events, FSW_Event{ event_filename, event_old_filename, event_event_type }); 
            event_old_filename = "";
        }

        if notifications.next_entry_offset == 0 do break;
        notifications = (^FILE_NOTIFY_INFORMATION)( uintptr(notifications) + uintptr(notifications.next_entry_offset) );
    }

    //  When event is captured i need to call it again
    //  this is the right way ??

    fsw_id := (^FSW_ID)(overlapped);
    if ReadDirectoryChangesW(
        fsw_id.handle, 
        &fsw.buffer[0],
        u32( len(fsw.buffer) ),
        true ,
        FSW_WATCHING_EVENTS,
        nil , 
        &fsw_id.overlapped, 
        nil ) == BOOL(false) 
    {
        eprintf( "ReadDirectoryChangesW failed! \n");
    }

    return events[:];
}

fsw_destroy :: proc( fsw: ^ FSW ) {
    for ptr in fsw.fws_id_list {
        CloseHandle(ptr.handle);
        free(ptr);
    }
    CloseHandle( fsw.iocp_handler );
    delete(fsw.fws_id_list);
    delete(fsw.buffer);
}