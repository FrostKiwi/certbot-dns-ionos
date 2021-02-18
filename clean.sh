#!/bin/sh
# Certbot clean script for the IONOS DNS API
# Don't forget to include the public prefix and the secret here as well

help_msg()
{
    echo "Certbot cleaning script for the IONOS DNS API"
    echo "(accoding to https://developer.hosting.ionos.com/docs/dns on the 25.12.20)"
    echo "auth.sh and clean.sh need to be supplied with the \"public prefix\" and \"secret\""
    echo "Author https://github.com/FrostKiwi/certbot-dns-ionos"
    echo
    echo "Example usage, both auth.sh and clean.sh need the API keys supplied:"
    echo "certbot certonly --manual --preferred-challenges=dns --manual-auth-hook \"/scipts/auth.sh -p e205cabb31b9423cb085e82676520949 -s Atfb71WgxNhwgp6zmJFVDLIxlNrg52d58fjBhTTBxOlH1CQ1nspd6qyxqCHtjtQUkb44FJVnDg3UnxMlTmMHpg\" --manual-cleanup-hook \"/scripts/clean.sh -p e205cabb31b9423cb085e82676520949 -s Atfb71WgxNhwgp6zmJFVDLIxlNrg52d58fjBhTTBxOlH1CQ1nspd6qyxqCHtjtQUkb44FJVnDg3UnxMlTmMHpg\" -d example.com"
    echo
    echo "Options:
    	 -p Public prefix, as provided by the IONOS API
	 -s Secret key, as provided by the IONOS API
	 -q Disable all stdout output
	 -h Display this help message"
    exit 2
}

while getopts d:p:s:qh flag
do
    case "${flag}" in
	h) help_msg;;
	p) PUBLIC_PREFIX=${OPTARG};;
	s) SECRET=${OPTARG};;
	q) QUIET=T;;
    esac
done

# Remove *.
# Wildcard handling is indentical
CERTBOT_DOMAIN_NOSTAR=$(echo $CERTBOT_DOMAIN | awk '{gsub("\\*\\.", "");print}')

# Check for Secret Key
if [ -z "$SECRET" ]
    then
	if [ -z "$QUIET" ]; then echo "Missing API secret key"; fi
	exit
fi
# Check for Public Prefix
if [ -z "$PUBLIC_PREFIX" ]
    then
	if [ -z "$QUIET" ]; then echo "Missing API public prefix"; fi
	exit
fi

# Get Domain-Zone ID
if [ -z "$QUIET" ]
    then
	echo Getting Zone-ID
	ZONE_ID=$(curl -s -X GET "https://api.hosting.ionos.com/dns/v1/zones/" -H "X-API-Key: $PUBLIC_PREFIX.$SECRET" -H "accept: */*" -H "Content-Type: application/json" | jq -r ".[]|select(.name==\"$CERTBOT_DOMAIN_NOSTAR\")|.id")
	echo -e "ZoneID: \033[0;32m$ZONE_ID\033[0m"
    else
	ZONE_ID=$(curl -s -X GET "https://api.hosting.ionos.com/dns/v1/zones/" -H "X-API-Key: $PUBLIC_PREFIX.$SECRET" -H "accept: */*" -H "Content-Type: application/json" | jq -r ".[]|select(.name==\"$CERTBOT_DOMAIN_NOSTAR\")|.id")
fi

# Get List of records
if [ -z "$QUIET" ]
    then
	echo Getting List of DNS records
	RECORDS=$(curl -s -X GET "https://api.hosting.ionos.com/dns/v1/zones/$ZONE_ID" -H "X-API-Key: $PUBLIC_PREFIX.$SECRET" -H "accept: */*" -H "Content-Type: application/json")
	echo $RECORDS | jq
    else
	RECORDS=$(curl -s -X GET "https://api.hosting.ionos.com/dns/v1/zones/$ZONE_ID" -H "X-API-Key: $PUBLIC_PREFIX.$SECRET" -H "accept: */*" -H "Content-Type: application/json")
fi

# remove challenge from the record list
if [ -z "$QUIET" ]
    then
	echo Record to be removed
	echo $RECORDS | jq -r ".records|.[]|select(.name==\"_acme-challenge.$CERTBOT_DOMAIN_NOSTAR\")"
fi

REMOVE_ID=$(echo $RECORDS | jq -r ".records|.[]|select(.name==\"_acme-challenge.$CERTBOT_DOMAIN_NOSTAR\")|.id")

if [ -z "$QUIET" ]
    then
	echo Removing record
	curl -s -X DELETE "https://api.hosting.ionos.com/dns/v1/zones/$ZONE_ID/records/$REMOVE_ID" -H "X-API-Key: $PUBLIC_PREFIX.$SECRET" -H "accept: */*" -H "Content-Type: application/json"
    else
	curl -s -X DELETE "https://api.hosting.ionos.com/dns/v1/zones/$ZONE_ID/records/$REMOVE_ID" -H "X-API-Key: $PUBLIC_PREFIX.$SECRET" -H "accept: */*" -H "Content-Type: application/json"
fi
