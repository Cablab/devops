# Networking

In DevOps, you'll be in charge of cloud computing environment and interconnecting containers and other things

## ISO

### OSI Model

- Basic elements of a layered model are:
  - **Service** - a set of actions that a layer offers to a higher layer above it
  - **Protocol** - a set of rules that a layer uses to exchange information
  - **Interfaces** - Communication between layers

Layer #|Layer Name|Data Unit|Role
--- | --- | --- | ---
7 | Application | data | Network process to application
6 | Presentation | data | Data representation & encryption
5 | Session | data | Interhost communication
4 | Transport | segments | End-to-End connections and reliability
3 | Network | packets | Path determination and Logical addressing (IP)
2 | Data Link| frames | Physical Addressing (MAC and LLC)
1 | Physical | bits |Media, signal, and binary transmission

### TCP/IP Protocol Model

Layer # | Layer Name | Common Protocols
--- | --- | ---
4 | Application | telnet, FTP, DHCP, TFTP, HTTP, SMTP, DNS, SNMP
3 | Transport | TCP, UDP
2 | Internet | ICMP, ARP, RARP, IP
1 | Network Interface | 

## Networks and IP

### Private IP Ranges

- **Class A**: 10.0.0.0 - 10.255.255.255
- **Class B**: 172.16.0.0 - 172.31.255.255
- **Class C**: 192.168.0.0 - 192.168.255.255

## Protocols and Ports

### TCP vs UDP

TCP and UDP are layer 4 (transport) protocols. Here are the main differences:

- **Reliability**: TCP is reliable, UDP is not
- **Connection**: TCP is connection oriented, UDP is not
  - TCP performs a 3 way handshake to create and maintain a stable connection. UDP doesn't do this, and doesn't worry about connection at all, so UDP is faster
- **Error Checking**: TCP will do error detection and retransmission, UDP will not
- **Suitability**: TCP is for applications that require guaranteed transmission, UDP is for applications that need to be fast more than they are reliable
  - Protocols built on TCP: FTP, HTTP, HTTPS
  - Protocols built on UDP: DNS, DHCP, TFTP, ARP, RARP

**Common Protocol Port Numbers**

Protocol | Service Name | Port
--- | --- | ---
DNS | Domain Name Service | UDP 53
DNC TCP | DNS over TCP | TCP 53
HTTP | Web | TCP 80
HTTPS | Secure Web (SSL) | TCP 443
SMTP | Simple Mail Transport | TCP 25
POP | Post Office Protocol | TCP 109, 110
SNMP | Simple Network Management | TCP/UDP 161,162
TELNET | Telnet Terminal | TCP 23
FTP | File Transfer Protocol | TCP 20,21
SSH | Secure Shell (terminal) | TCP 22
AFP IP | Apple File Protocol/IP | TCP 447,548

## Networking Commands

- If you want to reference IPs by hostname, you can add a line in `/etc/hosts` that is `<IP address> <hostname>`. That will let you do things like `ping <hostname>` instead of having to use the IP
- See all open TCP ports with `netstat -antp`. If you have a lot and are looking for a specific one, you can use `ps -ef` and grep for a process name. That should give you a PID which you can then do `netstat -antp | grep <PID>` and see which port it's using
  - `ss -tunlp` is the newer version of `netstat -antp`
- `nmap` (not installed by default, must install) can be used to scan open ports on a specified host. You can do `nmap localhost` to see your own, or `nmap <IP>` to check a remote server's
  - **WARNING**: people don't like this and `nmap` is even illegal in some countries
  - `telnet <IP address> <port number>` will attempt to connect to the specified port on the specified host. This is another way you can check if a certain port is open on a remote device
- `dig <FQDN>` can be used to check if DNS resolution is working because it returns the IP address for a specified FQDN
  - `nslookup <FQDN>` is an older version of dig
- `route -n` shows gateways for the host you're on
- `arp` is used to view or add content to the kernel's ARP table
- `mtr` is a live monitoring version of `traceroute`
