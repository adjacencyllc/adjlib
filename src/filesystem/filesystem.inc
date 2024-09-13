////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//**
//** filesystem.inc
//** 
//** This file contains the definitions for the fileEntry and fileEntryAttr records, as well as the error constants used
//** by the filesystem module.
//**
//** @Dependencies: ADJLIB exception library
//**
//** @Copyrignt: This source file, as well as the rest of the files contained in the Adjacency PLB Libraries (ADJLIB)
//** are copyrighted (C) 2024 by Adjacency Global Solutions LLC.
//**
//** @License: CC BY-SA 4.0
//** Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit 
//** https://creativecommons.org/licenses/by-sa/4.0/
//**
//** You are free to:
//**  - Share: copy and redistribute the material in any medium or format for any purpose, even commercially.
//**  - Adapt — remix, transform, and build upon the material for any purpose, even commercially.
//**  - The licensor cannot revoke these freedoms as long as you follow the license terms, including but not limited to:
//**
//**  TERMS:
//**  - Attribution - You must give appropriate credit , provide a link to the license, and indicate if changes were 
//**    made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or 
//**    your use.
//**  - ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under 
//**    the same license as the original.
//**  - No additional restrictions - You may not apply legal terms or technological measures that legally restrict 
//**    others from doing anything the license permits.
//**
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // require the exception module so that we can throw terminal exceptions
    include "exception\exception.inc:ADJLIB_SRC"

    %IFNDEF fileEntryAttr_DEF           // include guard to only define once
// record definition for file attributes
fileEntryAttr_DEF       record          definition
read_only               form            1
hidden                  form            1
system                  form            1
directory               form            1
archive                 form            1
encrypted               form            1
normal                  form            1
temporary               form            1
sparse_file             form            1
reparse_point           form            1
compressed              form            1
offline                 form            1
not_content_indexed     form            1
                        recordend

// record definition for file (and directory) entries
fileEntry_DEF           record          definition
type                    dim             1
name                    dim             260
path                    dim             260
writeTime               dim             14 
fileSize                integer         8
attr                    record          like fileEntryAttr_DEF
                        recordend
    %ENDIF                              // end of include guard

// error constants returned by filesystem functions
FILESYSTEM_ERR_NONE     const           "0"   
FILESYSTEM_ERR_EMPTY    const           "1"   
FILESYSTEM_ERR_NOT_FOUND const          "2"
