A small, quick and efficient multipurpose server, which your can enable and disable instantly:
- A HTTP/S proxy server that allows websites or other users to use your PC as a middleman (which can bypass websites that block their own IP addresses)
- A SMTP server/emulator that allows testing mail clients by letting them use your PC as a mail server, thus displaying the messages and optionally even send them away

## Installation
None.

## Usage
Just run the program, choose your usage and click Start.
### HTTP/S
To let a website or someone else's browser enter sites through you as a middleman:
* Define your website or someone else's browser to use your external IP as a proxy (the program will show you which IP to use).
### SMTP
To get SMTP messages:
1. Send a message from local mail clients (like https://github.com/lwcorp/lwblat) to SMTP server address such as 127.0.0.1 (which is your own computer).
1. The program will show the message and make the mailer think the message was actually sent.
1. The program can optionally not just emulate SMTP but actually act as SMTP and send messages away.
<br />But beware mail recipients [like Gmail block unregistered SMTP servers]([https://support.google.com/mail/?p=NotAuthorizedError](https://support.google.com/mail/answer/10336))!
### Advanced usage
In a possibly unique fashion, the server supports not just TCP but also UDP connections!
<br />With UDP being unpredictable and not really suited for a 2-sided communication, testing it could lead to some interesting results.

### System Requirements
Windows 200X, Windows XP, Windows Vista, Windows 7-11

### Screenshots
![image](https://github.com/user-attachments/assets/fc9cf92c-dee7-422d-9f00-12d947aaf8d5)
![image](https://github.com/user-attachments/assets/5a6f1469-9fdd-4f46-8201-d75d13488d39)
