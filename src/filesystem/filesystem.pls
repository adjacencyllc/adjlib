////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//**
//** filesystem.pls
//** 
//** This file contains the external and local functions for the filesystem library. This library provides functions for
//** simplified working with files and directories using the PL/B language and the native file system, without using
//** specialized DLLs, APIs, or other external dependencies.
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

    // require the constant includes for this library
    include "filesystem\filesystem.inc:ADJLIB_SRC"

// names/bit masks for file attributes under Windows OS
#FILEENTRY_ATTR_COUNT   const           "13"
#fileEntryAttrNames     dim             20[#FILEENTRY_ATTR_COUNT]:
                                        ("read_only"),("hidden"),("system"),("directory"):
                                        ("archive"),("encrypted"),("normal"),("temporary"),("sparse_file"):
                                        ("reparse_point"),("compressed"),("offline"),("not_content_indexed")                                              
#fileEntryAttrMasks     integer         2[#FILEENTRY_ATTR_COUNT]:
                                        ("0x01"),("0x02"),("0x04"),("0x10"),("0x20"),("0x40"),("0x80"),("0x100"):
                                        ("0x200"),("0x400"),("0x800"),("0x1000"),("0x2000")

#OS_SLASH               init            "\"    // determined by the runtime, probably need to change this for Linux

//*
//* Ensure that a path name ends with a trailing slash. If the path name is empty, this function does nothing. If the
//*  input parameter has no room for a trailing slash, a FORMAT exception is thrown.
//*
//* @param pPathName - the path name to which a trailing slash should be added
//* @return FILESYSTEM_ERR_NONE if the function is successful. 
//*         FILESYSTEM_ERR_EMPTY if the path name is empty.
//*
//* @throws FORMAT (F00) if the path name has no room for a trailing slash
//*
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
AddTrailingSlashToPath function 
pPathName               dim             ^
    entry
pUninitialized          dim             ^       // only present for intentionally causing an F04 error
fp                      integer         2       // form pointer of the input variable
errorAddress dim 8
errorTrap    dim 1
errorSubcode dim 5
errorModule  dim 260

    // fail early if the path name is empty
    count fp in pPathName
    return using FILESYSTEM_ERR_EMPTY if (fp = 0)

    // if the path name doesn't already end in a slash, add one
    movefptr pPathName to fp
    endset pPathName
    if (pPathName != #OS_SLASH)
        append #OS_SLASH to pPathName
        goto error_eos if eos
    endif
    reset pPathName to fp

    return using FILESYSTEM_ERR_NONE

error_eos   

    // No room to append a slash to the path name. Try throwing an exception first. If the exception has been handled, 
    //  this returns control to the caller's error handler
    exceptdoex format,"EOS in AddTrailingSlashToPath, path name too long"
    functionend
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//*
//* Get information about a file or directory and store it in a record of type fileEntry. 
//*
//* @param pFileEntry - the record in which to store the file information, which must be declared LIKE fileEntry_DEF
//* @param plbFilenameParts - up to 10 parts of the file name, each part up to 260 characters long. The parts are 
//*  concatenated from left to right to form the full file name. The file name may be in any valid PL/B format, including
//*  using PLBVOL or $MACROS.
//*
//* @return FILESYSTEM_ERR_NONE if the function is successful.
//*         FILESYSTEM_ERR_NOT_FOUND if the file is not found.
//*
//* @throws FORMAT (F00) if the resolved path name exceeds 259 characters.
//*
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
GetFileEntry function
pFileEntry              record          likeptr fileEntry_DEF
plbFilenameParts        dim             261[10]     // up to 10 parts of the file name, concatenated to form the full file name
    entry
plbFilename             dim             261         // the full file name, up to 260 characters long
filesize                integer         8           // file size in bytes, according to the OS
attributes              integer         2           // file attributes bytes, according to the OS
writeTime               dim             14          // file write time, according to the OS, in YYYYMMSSHHMMSS format
attributeIndex          integer         1           // loop counter
attrMasks               like            #fileEntryAttrMasks  // masks for extracting individual file attributes
osPath                  dim             260         // path name of the file, according to the OS
osName                  dim             260         // name of the file, according to the OS

    // make sure the fileEntry record is clear, in case we don't find the file
    clear pFileEntry
    pack plbFilename from plbFilenameParts
    findfile plbFilename,filesize=filesize,attributes=attributes,write=writeTime,path=osPath,name=osName

    // fail early if the file is not found
    return using FILESYSTEM_ERR_NOT_FOUND if not equal

    // this will throw a FORMAT exception if the path name is too long
    call addTrailingSlashToPath using osPath

    // unpack the attribute info into the fileEntry record. The attribute is a 2 byte integer, with each bit 
    //  representing a different attribute (see #fileEntryAttrNames and #fileEntryAttrMasks for details)
    for attributeIndex from 1 to #FILEENTRY_ATTR_COUNT
        and attributes with attrMasks[attributeIndex]
        if not zero
            // put the attribute into the corresponding attr element of the fileEntry record
            store 1 with attributeIndex into pFileEntry.attr
        endif
    repeat   

    if (pFileEntry.attr.directory)
        pack pFileEntry.type from "d"
    else
        pack pFileEntry.type from "f"
    endif

    // store the rest of the file system info into the fileEntry record
    pack pFileEntry.path from osPath
    pack pFileEntry.name from osName
    pack pFileEntry.writeTime from writeTime
    move filesize to pFileEntry.fileSize

    return using FILESYSTEM_ERR_NONE
    
    functionend
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
