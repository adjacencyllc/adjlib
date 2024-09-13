////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//**
//** exception.pls
//** 
//** This file contains the external functions for the exception library. This library provides functions for exception
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
    include "exception\exception.inc:ADJLIB_SRC"  // required global variable S$EXCEPTION$ required by exceptdoexFunc

//* @function exceptdoexFunc (aliased as verb "exceptdoex")
//*
//* throws an exception with the given message and type. Valid types are Cfail, Dbfail, Format, Io, Object, Parity:
//*  Spool, User. This function is intended to be executed by the verb "exceptdoex" (see exception.inc). The function
//*  will throw the requested exception, and if the exception hasn't been handled with an EXCEPTSET, then the function
//*  will STOP with a simulated runtime error. This improves the default exceptdo behavior of ignoring the instruction 
//*  if an exception handler isn't active.
//*
//* @param exceptionType - the type of exception to throw, string value of (Cfail, Dbfail, Format, Io, Object, Parity,
//*  Spool, User).
//* @param message - the message to display with the exception. (100 characters max)
//* @param offset - the number of call stack frames to skip when determining the caller's address. This is useful when 
//   there is a series of calls that need to be unwound to find the actual caller. Default is 0, maximum is 9.
//* @param callStack - the call stack to use when determining the caller's address. Provided by the caller using the
//   getmode *dumpcrstack instruction. The caller must provide this - since this function resides in an external, it
//   can't see the caller's call stack.
//
//* @return none (this function will stop the program if the exception isn't handled by the caller)
//*
//* @throws Cfail (C00), Dbfail (D00), Format (F00), Io (I00), Object (O00), Parity (P00), Spool (S00), User (U00)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
exceptdoexFunc          function
exceptionType           dim             10      // what type of exception to throw?
message                 dim             100     // the message to display with the exception
offset                  form            "0"     // the number of call stack frames to skip when determining the caller's address
callStack               dim             4096    // buffer to hold the value of the caller's call stack
    entry
callInfo                dim             260[0..9]
callAddress             dim             8
callModule              dim             250
isGuiAvailable          integer         1
alertResult             integer         1
firstExceptionTypeChar  dim             1
CONSOLE_CRLF            init            0x0d,0x0a,0x0d,0x0a
ALERT_CRLF              init            0x7f,0x7f
stringLength            integer         1
errorString             dim             60
messageLine             dim             260[3]
messageLines            dim             783

    // get the caller's address from the stack (offset lets us skip the call that got us to this function)
    explode callStack with ";" into callInfo
    explode callInfo[offset] with "," into callAddress,callModule

    // set the exception name to "Sentence" case
    unpack exceptionType into firstExceptionTypeChar
    lowercase exceptionType
    uppercase firstExceptionTypeChar
    cmove firstExceptionTypeChar to exceptionType

    // left pad the call address with zeros, then prefix with 0x
    squeeze callAddress into callAddress,keep="0123456789ABCDEF"
    loop
        movelptr callAddress to stringLength
        until (stringLength >= 8)
        splice "0" into callAddress with 0
    repeat

    // build an S$ERROR$ style string for storing the error code
    if (callModule = "")
        pack errorString from firstExceptionTypeChar,"00 ",callAddress," 0    "
    else
        pack errorString from firstExceptionTypeChar,"00 ",callAddress," 0    :",callModule
    endif

    // set the global PL/B error codes to indicate an exception occurred
    move 2 to S$RETVAL
    move errorString to S$ERROR$

    // we'll need these later depending on whether we're displaying the message in a GUI or console
    pack messageLine[1] from exceptionType," Exception in ",callModule," at address 0x",callAddress,"."
    pack messageLine[2] from "Message: ",message
    pack messageLine[3] from "Error Code: ",errorString

    // format the message for returning to an exception handler and store it in a special global, since exceptdo
    //  can't pass the message any other way
    implode messageLines with "|" from messageLine
    move messageLines to S$EXCEPTION$
    switch exceptionType
    case "Cfail"
        exceptdo cfail,S$EXCEPTION$
    case "Dbfail"
        exceptdo dbfail,S$EXCEPTION$
    case "Format"
        exceptdo format,S$EXCEPTION$
    case "Io"
        exceptdo io,S$EXCEPTION$
    case "Object"
        exceptdo object,S$EXCEPTION$
    case "Parity"
        exceptdo parity,S$EXCEPTION$
    case "Spool"
        exceptdo spool,S$EXCEPTION$
    case "User"
        exceptdo user,S$EXCEPTION$
    endswitch

    // if we got to this line of code, then the exception wasn't taken because there is no exception handler enabled. 
    //  Display an exception message in the style of a PL/B runtime error, appropriate for the current environment
    getmode *gui=isGuiAvailable
    if (isGuiAvailable)
        // display an alert dialog
        pack messageLines from messageLine[1],ALERT_CRLF,messageLine[2],ALERT_CRLF,messageLine[3]
        alert stop,messageLines,alertResult,"PL/B Runtime Exception"
    else
        // display a console message, with a pause
        pack messageLines from messageLine[1],CONSOLE_CRLF,messageLine[2],CONSOLE_CRLF,messageLine[3]
        display *hd,*n,*n,"PL/B Runtime Exception",*n,*wrapon,messageLines
        pause 3
    endif

    // we already set S$ERROR$, but just to be safe, we're doing it again before we exit
    move 2 to S$RETVAL
    move errorString to S$ERROR$
    stop

    functionend
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
