//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//**
//** sendmail.pls
//** 
//** This file contains the external and local functions for the sendmail library. This library provides functions for
//** simplified email sending without the need for additional external library dependencies. This module requires INI keyword entries for proper
//** functionality.
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
#SENDMAIL_VERSION                   init            "01.00.0"       // local variable: version of the sendmail module
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    include "./sendmail.inc"                                        // SENDMAIL_SMTPINFO record definition
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//*
//* Send an email message using the SMTP settings from the ini file's "sendmail" section
//*
//* @param recipientAddresses DIM 2048 list of valid email addresses, comma-delimited
//* @param subject DIM 260 subject line of email
//* @param mailBody DIM 65535 email body content
//* @param attachmentList DIM 2048 optional list of file attachments, comma-delimited. Leave blank for no attachments
//* @param iniSection DIM 100 optional INI section to retrieve SMTP info from. Leave blank to default to "sendmail"
//*
//* @return SENDMAIL_ERROR_NONE if the mail is successfully sent. 
//*         SENDMAIL_ERROR_ANY  if the mail cannot be sent (see S$ERROR$ for additional info).
//*
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Sendmail function
recipientAddresses                  dim             2048            // list of recipient email addresses, separated by commas
subject                             dim             260             // subject line of the email
mailBody                            dim             65535           // body of the email message
attachmentList                      dim             2048            // list of attachment file names, separated by commas; can be empty if no attachments
iniSection                          dim             100             // optional INI section where SMTP info should be retrieved from; defaults to sendmail
    entry
iniString                           dim             260             // work string for reading ini file settings
mailSuccessFlag                     form            1               // flag to indicate if the email was sent successfully 
smtp                                record          like SENDMAIL_SMTPINFO  // record to hold the SMTP settings


    // get SMTP settings from an INI file
    call getSMTPSettings using smtp

    // call the proper SMTP function (because some options don't have the ability to be set to false)
    if (smtp.ssl = 0 and attachmentList = "")
        call sendmailPlaintextNoAttachments giving mailSuccessFlag using smtp,recipientAddresses,subject,mailBody
    elseif (smtp.ssl = 0 and attachmentList != "")
        call sendmailPlaintextWithAttachments giving mailSuccessFlag using smtp,recipientAddresses,subject,mailBody,attachmentList
    elseif (smtp.ssl > 0 and attachmentList = "")
        call sendmailEncryptedNoAttachments giving mailSuccessFlag using smtp,recipientAddresses,subject,mailBody
    elseif (smtp.ssl > 0 and attachmentList != "")
        call sendmailEncryptedWithAttachments giving mailSuccessFlag using smtp,recipientAddresses,subject,mailBody,attachmentList
    else
        // invalid settings
        move "M00 Invalid SMTP Settings" to S$ERROR$
        clear mailSuccessFlag
    endif

    return using mailSuccessFlag
    functionend
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//*
//* Returns the current sendmail library version number
//*
//* @return SENDMAIL_VERSION - DIM string containing version number in nn.nn.n format
//*
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
GetVersion function
    entry

    return using #SENDMAIL_VERSION
    functionend
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//*
//* Extract the SMTP settings from the ini file into a record of type SENDMAIL_SMTPINFO
//*
//* @param pSmtp - a record of type SENDMAIL_SMTPINFO to be filled with SMTP settings
//* @param iniSection - optional INI section name to read the settings from; if empty, defaults to "sendmail"
//*
//* @return none
//*
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
GetSMTPSettings function
pSmtp                               record          likeptr SENDMAIL_SMTPINFO
iniSection                          dim             100                             // optional INI section, default is "sendmail"
    entry
iniString                           dim             260

    chop iniSection
    if (iniSection = "")
        pack iniSection from "sendmail"
    endif

    // get the hostname from the ini file, defaulting to an empty string if not set
    pack iniString from iniSection,";hostname"
    clock ini into iniString
    if over
        clear pSmtp.hostname
    else
        move iniString to pSmtp.hostname
    endif

    // get the username from the ini file, defaulting to an empty string if not set
    pack iniString from iniSection,";username"
    clock ini into iniString
    if over
        clear pSmtp.username
    else
        move iniString to pSmtp.username
    endif

    // get the password from the ini file, defaulting to an empty string if not set
    pack iniString from iniSection,";password"
    clock ini into iniString
    if over
        clear pSmtp.password
    else
        move iniString to pSmtp.password
    endif

    // get the port number from the ini file, defaulting to 25 if not set
    pack iniString from iniSection,";port"
    clock ini into iniString
    if over
        move 25 to pSmtp.port
    else
        move iniString to pSmtp.port
    endif

    // get the reply-to email address from the ini file, defaulting to a generic address if not set
    pack iniString from iniSection,";replyto"
    clock ini into iniString
    if over
        move "nobody@nonsuch.com" to pSmtp.replyToEmail
    else
        move iniString to pSmtp.replyToEmail
    endif

    // get the send-from email address from the ini file, defaulting to a generic address if not set
    pack iniString from iniSection,";sendfrom"
    clock ini into iniString
    if over
        move "Nonsuch System Administrator <no-reply@nonsuch.com>" to pSmtp.sendFromString
    else
        move iniString to pSmtp.sendFromString
    endif

    // get the SSL setting from the ini file: positive settings are T/TRUE; Y/YES; or 1; all other settings are equivalent to NO SSL
    pack iniString from iniSection,";ssl"
    clock ini into iniString
    if not over
        uppercase iniString
        switch iniString
        case "T" or "TRUE" or "YES" or "Y" or "1"
            set pSmtp.ssl
        default
            clear pSmtp.ssl
        endswitch
    endif 

    // get a tracelog file name from the ini file if present
    pack iniString from iniSection,";tracelog"
    clock ini into iniString
    if over
        clear pSmtp.tracelog
    else
        move iniString to pSmtp.tracelog
    endif

    functionend
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// send email with no SSL and no attachments
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
sendmailPlaintextNoAttachments lfunction
pSmtp                               record          likeptr SENDMAIL_SMTPINFO
recipientList                       dim             2048
subject                             dim             260
mailBody                            dim             65535
    entry

    clear S$ERROR$
    mailsend pSmtp.hostname,recipientList,pSmtp.sendFromString,subject,mailBody:
             *user=pSmtp.username,*password=pSmtp.password,*port=pSmtp.port,*replyto=pSmtp.replyToEmail,*traceappend=pSmtp.tracelog
    goto error_mail if (S$ERROR$ != "")
    return using SENDMAIL_ERROR_NONE

error_mail
    return using SENDMAIL_ERROR_FAIL
    functionend
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// send email with no SSL and with attachments
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
sendmailPlaintextWithAttachments lfunction
pSmtp                               record          likeptr SENDMAIL_SMTPINFO
recipientList                       dim             2048
subject                             dim             260
mailBody                            dim             65535
attachmentList                      dim             2048
    entry

    clear S$ERROR$
    mailsend pSmtp.hostname,recipientList,pSmtp.sendFromString,subject,mailBody:
             *user=pSmtp.username,*password=pSmtp.password,*port=pSmtp.port,*replyto=pSmtp.replyToEmail,*attachment=attachmentList:
             *traceappend=pSmtp.tracelog

    goto error_mail if (S$ERROR$ != "")
    return using SENDMAIL_ERROR_NONE

error_mail
    return using SENDMAIL_ERROR_FAIL
    functionend
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// send email with SSL and no attachments
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
sendmailEncryptedNoAttachments lfunction
pSmtp                               record          likeptr SENDMAIL_SMTPINFO
recipientList                       dim             2048
subject                             dim             260
mailBody                            dim             65535
    entry

    clear S$ERROR$
    mailsend pSmtp.hostname,recipientList,pSmtp.sendFromString,subject,mailBody:
             *user=pSmtp.username,*password=pSmtp.password,*port=pSmtp.port,*replyto=pSmtp.replyToEmail,*openSSL,*traceappend=pSmtp.tracelog
    goto error_mail if (S$ERROR$ != "")
    return using SENDMAIL_ERROR_NONE

error_mail
    return using SENDMAIL_ERROR_FAIL
    functionend
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// send email with SSL and with attachments
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
sendmailEncryptedWithAttachments lfunction
pSmtp                               record          likeptr SENDMAIL_SMTPINFO
recipientList                       dim             2048
subject                             dim             260
mailBody                            dim             65535
attachmentList                      dim             2048
    entry

    clear S$ERROR$
    mailsend pSmtp.hostname,recipientList,pSmtp.sendFromString,subject,mailBody:
             *user=pSmtp.username,*password=pSmtp.password,*port=pSmtp.port,*replyto=pSmtp.replyToEmail,*attachment=attachmentList,*openSSL:
             *traceappend=pSmtp.tracelog

    goto error_mail if (S$ERROR$ != "")
    return using SENDMAIL_ERROR_NONE

error_mail
    return using SENDMAIL_ERROR_FAIL
    functionend
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
