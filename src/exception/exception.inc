////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//**
//** exception.inc
//** 
//** This file contains the definitions for improved exceptions (exceptdoex) used by the ADJLIB exception library.
//**
//** @Dependencies: none
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    %IFNDEF S$EXCEPTION$                // variables in the UDA scope
S$EXCEPTION$            dim             %783    // exception message can only be passed via literal or globam
EXCEPTION_STRING        define          "DIM 1024 // exception message string, DEFINEd in adjlib exception/exception.inc"
    %ENDIF

    %IFNDEF #VERSION                    // namespaced variables in the UDA scope
#VERSION                form            "000.1" // major/minor version of the exception handling system
#CALLSTACK              dim             4096    // buffer for storing call stack before throwing exception
#EXT_EXCEPTDOEX         external        "exception.plc:ADJLIB_BIN;exceptdoexFunc"
    %ENDIF

    %IF MDEFINED(exceptdoex) = 1        // exceptdoex is defined as a macro, do not include a second time
    %ELSEIF MDEFINED(exceptdoex) = 3    // exceptdoex is defined as a macro, do not include a second time
    %ELSE                               // exceptdoex is not defined, include the macro

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* exceptdoex macro 
//* we use a macro here, so that if the exception parameter is not valid, a compiler error will be given. This allows
//* the programmer to use the same syntax as exceptdo
//*
//* usage: exceptdoex {event},{message}
//*  where:
//*      event: the name of the exception to throw. This must be one of the following: 
//*              Cfail, Dbfail, Format, Io, Object, Parity, Spool, User
//*
//*    message: the message to display/pass to the calling instruction
//*
//* This verb enhances the behavior of exceptdo in the following ways:
//*
//*  - exceptdo is ignored if there is no active exception handler. exceptdoex behaves as if there was a runtime error
//*     of the specified type, so failing to handle an exception will result in a simulated runtime error.
//*  - sets S$ERROR$ with the error address, module name, and error code. The error code will be C00 for Cfail, D00 for
//*     Dbfail, F00 for Format, I00 for Io, O00 for Object, P00 for Parity, S00 for Spool, and L00 for User.
//*  - if the exception is handled, S$ERROR$ will be passed to the exception handler as if it were a runtime error. The
//*     exception message will be stored in a special global variable called S$EXCEPTION$
//*  - S$RETVAL will be set to 2, indicating a fatal runtime error.
//*  - if the exception is not handled, a message will be displayed in the console or as an alert dialog, depending on
//*     runtime environment.
//*  - after the exception message is displayed, the program will stop with a simulated runtime error.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
exceptdoex              MACRO           &EXCEPTION,&MESSAGE="No message available",&OFFSET="0"
    EXCEPTCHECK &EXCEPTION              // compiler check to make sure @&exception is a valid exception name
    GETMODE *DUMPCRSTACK=#CALLSTACK     // get the call stack for the exception
    CALL #EXT_EXCEPTDOEX USING "&EXCEPTION",&MESSAGE,&OFFSET,#CALLSTACK
    MEND
    %ENDIF
