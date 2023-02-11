
# Bash script to check data in website 'have i been pwned?'

__Description:__\
Script allows to scan a lot of passwords/email/domains from the txt file. \
Script display data from the server and at the same time creates file and write data to further processing. \
***I don't sure about working email, because I don't have a API key to check this function.***

Data source: [have i been pwned?]( https://haveibeenpwned.com) \
API Version: v3 \
For script working needs _curl_.

__Examples of input file:__

_Hashes_
```
5BAA61E4C9B93F3F0682250B6CF8331B7EE68FD8 
A61F846C5CEC7B6933A475F44BD2898D4F583963  
```
_Passwords_
```
somepass1
somepass2
```
_Emails_
```
somemail@mail.com
somemail@icloud.com
```
_Domains_
```
youtube.com
google.com 
```

__Example of output file (password and "pwned" count)__
```
password1:200
password2:120
```
__Usage example:__
```
bash pwn.sh -p filename.txt
```

```
-i Display help text.
-p Passwords for check.
-e Emails for check.
-h Hashes for check.
-d Domains for check.
-k API key.(Required for email)
```
