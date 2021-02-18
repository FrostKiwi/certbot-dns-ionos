# certbot-dns-ionos
todo: Subdomain handeling for non-wildcard certs<br>
todo: Fix cleanup with multiple domain names<br>
~~todo: Add wildcard cert support~~

These are authentication and cleanup scripts for [certbot's](https://github.com/certbot/certbot) --manual-auth-hook and --manual-cleanup-hook to automate cert creation with the [IONOS DNS API](https://developer.hosting.ionos.com/docs).
These scripts are created accoring to the [BETA DNS API](https://developer.hosting.ionos.com/docs/dns) docs from the 2021-02-18.
By default the authentication scripts waits for 60s to ensure DNS propagation. This can be disabled with "-d 0".

Please note: Just to be sure, the authentication script does not temp-save the API keys for use in the clean-up script. That's why you have to invoke the cleanup script with the API keys again.

More details and usage information is provided by invoking either of the scripts with -h
## Dependencies
Both scripts use [jq](https://github.com/stedolan/jq) and [curl](https://github.com/curl/curl) to manage the API calls.
#### FreeBSD:
```
# pkg install jq curl
```
#### ArchLinux:

```
# pacman -S jq curl
```
#### Ubuntu:

```
# apt-get install jq curl
```

## Usage Output with -h
```
Certbot authentication script for the IONOS DNS API
(accoding to https://developer.hosting.ionos.com/docs/dns on the 25.12.20)
auth.sh and clean.sh need to be supplied with the "public prefix" and "secret"
Author https://github.com/FrostKiwi/certbot-dns-ionos

Example usage, both auth.sh and clean.sh need the API keys supplied:
certbot certonly --manual --preferred-challenges=dns --manual-auth-hook "/scipts/auth.sh -p e205cabb31b9423cb085e82676520949 -s Atfb71WgxNhwgp6zmJFVDLIxlNrg52d58fjBhTTBxOlH1CQ1nspd6qyxqCHtjtQUkb44FJVnDg3UnxMlTmMHpg" --manual-cleanup-hook "/scripts/clean.sh -p e205cabb31b9423cb085e82676520949 -s Atfb71WgxNhwgp6zmJFVDLIxlNrg52d58fjBhTTBxOlH1CQ1nspd6qyxqCHtjtQUkb44FJVnDg3UnxMlTmMHpg" -d example.com

Options:
    	 -p Public prefix, as provided by the IONOS API
	 -s Secret key, as provided by the IONOS API
    	 -d Delay time to wait for DNS record propagation, 0 to disable
	 -q Disable all stdout output
	 -h Display this help message
```
