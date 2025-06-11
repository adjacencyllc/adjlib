# sendmail
This file contains the external and local functions for the sendmail library. This library provides functions for simplified email sending without the need for additional external library dependencies. This module requires INI keyword entries for proper functionality.

## Library Information

### Current Version
version 01.00.0

### Dependencies
None

### Copyrignt
This source file, as well as the rest of the files contained in the Adjacency PLB Libraries (ADJLIB) are copyrighted (C) 2024-2025 by Adjacency Global Solutions LLC.

### License
CC BY-SA 4.0 (Creative Commons Attribution-ShareAlike 4.0 International.) 

To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

You are free to:
- Share: copy and redistribute the material in any medium or format for any purpose, even commercially.
- Adapt — remix, transform, and build upon the material for any purpose, even commercially.
- The licensor cannot revoke these freedoms as long as you follow the license terms, including but not limited to:

### Terms and Conditions
- Attribution - You must give appropriate credit , provide a link to the license, and indicate if changes were 
made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or 
your use.
- ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under 
the same license as the original.
- No additional restrictions - You may not apply legal terms or technological measures that legally restrict 
others from doing anything the license permits.

## API Function Reference

### Sendmail
Send an email message using the SMTP settings from the ini file's "sendmail" section

#### Parameters
`recipientAddresses` DIM 2048 list of valid email addresses, comma-delimited

`subject` DIM 260 subject line of email

`mailBody` DIM 65535 email body content

`attachmentList` DIM 2048 optional list of file attachments, comma-delimited. Leave blank for no attachments

`iniSection` DIM 100 optional INI section to retrieve SMTP info from. Leave blank to default to "sendmail"

#### Return Value
`SENDMAIL_ERROR_NONE` if the mail is successfully sent. `SENDMAIL_ERROR_ANY` if the mail cannot be sent (see S$ERROR$ for additional info).

#### Sample Usage
```
    calls "sendmail;Sendmail" giving result using "nobody@nonsuch.com":
                                                  "Email Subject":
                                                  "This is a test email"
```

### GetVersion
Returns the current sendmail library version number

#### Parameters
None

#### Return Value
`SENDMAIL_VERSION` - DIM string containing version number in nn.nn.n format

#### Sample Usage
```
versionNumber dim 10
    calls "sendmail;GetVersion" giving versionNumber
```    

### GetSMTPSettings
Extract the SMTP settings from the ini file into a record of type SENDMAIL_SMTPINFO.

#### Parameters
`pSmtp` a record of type SENDMAIL_SMTPINFO to be filled with SMTP settings

`iniSection` optional DIM 100 INI section name to read the settings from; if empty, defaults to "sendmail"

#### Return Value
None

#### Sample Usage
```
mySmtp record like SENDMAIL_SMTPINFO
    calls "sendmail;GetSMTPSettings" using mySmtp
```
