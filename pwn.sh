#!/bin/bash 
#
# Usage example: ./pwn.sh -p filename.txt
# -----------------------------------------------------------------------
# Description: 
# Bash script to check data in website 'have i been pwned?'
# Script allows to scan a lot of passwords/email/domains from the txt file.
# -----------------------------------------------------------------------
# Example of input file: password1
#                        somemail@email.com
#                        youtube.com 
# Example of output file: Password/Email/Domain:pwned count 
#                         password1:400
#                         password2:240
# !For domains script creates json files 
# !Output file doesn't contain clear hashes/passwords/domains/emails
# -----------------------------------------------------------------------
# Data source: https://haveibeenpwned.com
# API Version: v3
# For script working needs curl 


# Email check 
function c_email () {
    email=$OPTARG
    pwned=$(curl -s "https://haveibeenpwned.com/api/v3/breachedaccount/$email hibp-api-key:$apikey" | \
    grep -o '"PwnCount":[0-9]*')

    if [[ $pwned == "" ]]; then
        printf "Email [%s] is clear.\n" $email
    else 
        echo $pwned >> pwn_emails.txt
        for_print=$(echo $pwned | cut -d":" -f2)
        printf "Email [%s] has been seen %d times before.\n" $email $for_print
    fi
    sleep 0.25
}

# Password check 
function c_password () {
    password=$(echo -n "$OPTARG" | shasum)
    password=${password:0:40}
    five=${password:0:5}
    end=${password:5}

    pwned=$(curl -s "https://api.pwnedpasswords.com/range/$five" | tr -d '\r' | grep -i "$end" | \
    cut -d":" -f2)

    if [[ $pwned == "" ]]; then
        printf "Password [%s] is clear.\n" $OPTARG
    else 
        echo "$OPTARG:$pwned" >> pwn_passwords.txt
        printf "Password [%s] has been seen %d times before.\n" $OPTARG $pwned
    fi
    sleep 0.25
}
 
# Hash check 
function c_hash () {
    password=$(echo -n "$OPTARG") # password=OPTARG.
    password=${password:0:40} # Deleting excess symbols.
    five=${password:0:5} # Getting first five letters to pass to the site.
    end=${password:5} # Getting other letters to const for finding the hash then.

    pwned=$(curl -s "https://api.pwnedpasswords.com/range/$five" | tr -d '\r' | grep -i "$end")
    # Create the respone to the server and processing then.

    if [[ $pwned == "" ]]; then # If the hash(password) doesn't exsists in the server, 
      # we execute print. Otherwise, we execute else.
        printf "Hash [%s] is clear.\n" $OPTARG 
    else 
        echo $pwned >> pwn_hashes.txt # Creating and redirect to the file "pwn_hashes.txt".
        # In this file we save results from server.
        for_print=$(echo $pwned | cut -d":" -f2) # Getting count.
        printf "Hash [%s] has been seen %d times before.\n" $OPTARG $for_print
    fi 
    sleep 0.25 # Response limit 0.25000 seconds.
}

# Domains check 
function c_domain () {
    domain=$OPTARG
    pwned=$(curl -s "https://haveibeenpwned.com/api/v3/breaches/?domain=$domain")

    if [[ $pwned == "[]" ]]; then
        printf "Domain [%s] is clear.\n" $domain
    else 
        echo $pwned >> pwn_domains.json
        for_print=$(echo $pwned | grep -o '"PwnCount":[0-9]*' | cut -d":" -f2)
        printf "Domain [%s] has been seen %d times before.\n" $domain $for_print
    fi
    sleep 0.25
}

# Help text 
function info () {
    echo "Bash scipt for checking passwords/emails/domains via 'have i been pwned'."
    echo -ne "Usage example: ./pwn.sh -arg filename.txt\n"
    echo -ne "\t-i\t\tDisplay help text.\n"
    echo -ne "\t-p\t\tPasswords for check .\n"
    echo -ne "\t-e\t\tEmails for check.\n"
    echo -ne "\t-h\t\tHashes for check.\n"
    echo -ne "\t-d\t\tDomains for check.\n"
    echo -ne "\t-k\t\tAPI key.(Required for email)\n"
    echo -ne "I don't sure about email working because I don't have a API key to check emails!!\n"
}

# Execution

if [[ $2 == "" ]]; then 
    echo "You're missing an argument."
    exit 1
fi

while getopts "e:p:h:d:k:i" FLAG; do 
case $FLAG in
    e)  
        (cat $2; echo)| while read OPTARG; do 
        c_email $OPTARG $apikey
        done
        exit 0
        ;;
    p) 
        (cat $2; echo)| while read OPTARG; do 
        c_password $OPTARG
        done 
        exit 0
        ;;
    h)  
        (cat $2; echo)| while read OPTARG; do 
        c_hash $OPTARG
        done 
        exit 0
        ;;
    d)   
        (cat $2; echo)| while read OPTARG; do 
        c_domain $OPTARG
        done 
        exit 0
        ;; 
    k) 
        apikey=$OPTARG
        ;;

    i | *) 
        info 
        exit 0
        ;;
esac
done

info