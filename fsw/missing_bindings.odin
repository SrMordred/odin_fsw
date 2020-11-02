package fsw

import win "core:sys/windows"
import win32 "core:sys/win32"

BOOL                    :: win.BOOL;
DWORD                   :: win.DWORD;
HANDLE                  :: win.HANDLE;
INVALID_HANDLE          :: win.INVALID_HANDLE;
LPDWORD                 :: win.LPDWORD;
LPVOID                  :: win.LPVOID;
PULONG_PTR              :: ^ULONG_PTR;
ULONG_PTR               :: win.ULONG_PTR;

OVERLAPPED              :: win.OVERLAPPED;
LPOVERLAPPED            :: win.LPOVERLAPPED;

// TODO: this is a callback, https://docs.microsoft.com/en-us/windows/win32/api/minwinbase/nc-minwinbase-lpoverlapped_completion_routine
LPOVERLAPPED_COMPLETION_ROUTINE :: rawptr; 

FILE_NOTIFY_CHANGE_DIR_NAME     :: win32.FILE_NOTIFY_CHANGE_DIR_NAME;
FILE_NOTIFY_CHANGE_FILE_NAME    :: win32.FILE_NOTIFY_CHANGE_FILE_NAME;
FILE_NOTIFY_CHANGE_LAST_WRITE   :: win32.FILE_NOTIFY_CHANGE_LAST_WRITE;

FILE_FLAG_BACKUP_SEMANTICS      :: win32.FILE_FLAG_BACKUP_SEMANTICS;
FILE_FLAG_OVERLAPPED            :: win32.FILE_FLAG_OVERLAPPED;
FILE_LIST_DIRECTORY             : DWORD : 0x00000001;
FILE_NOTIFY_INFORMATION         :: win32.File_Notify_Information;

FILE_SHARE_DELETE               :: win32.FILE_SHARE_DELETE;
FILE_SHARE_READ                 :: win32.FILE_SHARE_READ;
FILE_SHARE_WRITE                :: win32.FILE_SHARE_WRITE;

OPEN_EXISTING                   :: win32.OPEN_EXISTING;

FILE_ACTION_ADDED               :: win32.FILE_ACTION_ADDED;
FILE_ACTION_REMOVED             :: win32.FILE_ACTION_REMOVED;
FILE_ACTION_MODIFIED            :: win32.FILE_ACTION_MODIFIED;
FILE_ACTION_RENAMED_OLD_NAME    :: win32.FILE_ACTION_RENAMED_OLD_NAME;
FILE_ACTION_RENAMED_NEW_NAME    :: win32.FILE_ACTION_RENAMED_NEW_NAME;

INFINITE :: win.INFINITE;

foreign {
    CreateIoCompletionPort      :: proc( file_handle: HANDLE, existing_completion_port: HANDLE, completion_key: ULONG_PTR , n_of_concurrent_threads: DWORD  ) -> HANDLE --- ;
    GetQueuedCompletionStatus   :: proc( completion_port: HANDLE, n_of_bytes_transfered: LPDWORD , completion_key: PULONG_PTR, overlapped: ^LPOVERLAPPED, milliseconds: DWORD ) -> BOOL ---;
    ReadDirectoryChangesW       :: proc( hDirectory : HANDLE,lpBuffer:LPVOID, nBufferLength: DWORD, bWatchSubtree: BOOL, dwNotifyFilter: DWORD, lpBytesReturned: LPDWORD, lpOverlapped: LPOVERLAPPED,lpCompletionRoutine: LPOVERLAPPED_COMPLETION_ROUTINE) -> BOOL ---;
}

GetLastError    :: win.GetLastError;
CreateFileW     :: win.CreateFileW;
CloseHandle     :: win.CloseHandle;


Wstring         :: win32.Wstring;
utf8_to_wstring :: win.utf8_to_wstring;
wstring_to_utf8 :: win.wstring_to_utf8;