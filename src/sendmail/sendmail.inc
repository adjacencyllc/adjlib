//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//**
//** sendmail.inc
//** 
//** This file contains the definitions for the SENDMAIL_SMTPINFO record, as well as the error constants used
//** by the sendmail module.
//**
//** @Dependencies: None
//**
//** @Copyrignt: This source file, as well as the rest of the files contained in the Adjacency PLB Libraries (ADJLIB)
//** are copyrighted (C) 2024-2025 by Adjacency Global Solutions LLC.
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    %IFNDEF SENDMAIL_SMTPINFO                                        // include-once directive
SENDMAIL_SMTPINFO                   record          definition
hostname                            dim             260             // hostname or IP address of the SMTP server
username                            dim             260             // username for the SMTP server authentication
password                            dim             260             // password for the SMTP server authentication (unencrypted)
port                                form            5               // port number for the SMTP server (default is 25)
replyToEmail                        dim             260             // email address to use in the reply-to header
sendFromString                      dim             260             // email address to use in the from header, including name and email address
ssl                                 form            1               // SSL setting: 0 for no SSL, 1 for SSL
tracelog                            dim             260             // optional file name for logging the SMTP trace output                                    
                                    recordend

SENDMAIL_ERROR_NONE                 const           "0"             // no error
SENDMAIL_ERROR_FAIL                 const           "1"             // general failure - see S$ERROR$
    %ENDIF                                                          // end include-once directive
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
