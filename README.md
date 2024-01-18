<h1>ASN-SubSearch</h1>
This tool is designed to get extra subdomains and new top-level domains owned by a company. This can expand you scope when doing cyber security audits or bugbounty
It can find domains that other enumeration tools may miss, it does this by scanning an entire ip range of a provided ASN and company.

<h2>WHAT IT CAN DO</h2>
  Creates file: company.ipRange - a list all ip ranges owned by companies ASN<br>
  Creates file: company.ipList - unpacked list of all IP in ASN IP allranges<br>
  Creates file: company.newSubs - A list of the newly found subdomains<br>
  Runs every IP through hakip2host & dnsx to resolve and validate endpoints<br>

<h2>Set-up</h2>
Requires hakluke's tool: <b>hackip2host</b><br>
requires projectdiscovery's tool: <b>dnsx</b>

<h2>Usage</h2>
<code>Options:                      
  -d string   Domain name (required)
  -a int      ASN (optional but preferred)
  -h  Display this help menu</code>
