.\" gdiffmk acscf-00e.nr acscf-00.nr >d
.\" gdiffmk acscf-2012May01.nr acscf-00.nr >d
.\" gdiffmk ../svn/doc/drafts/acscf-00.nr acscf-00.nr >d
.\" nroff -ms -Tascii d >t
.\" nroff -ms -Tascii acscf-00.nr >t
.\" sed -e 's/FORMFEED\[Page/        ^L\[Page/' t | pg -n5 >acscf-2013May04.txt
.pl 10.0i
.po 0
.ll 72n
.lt 72n
.nr LL 72n
.nr LT 72n
.nr PI 3n
.de FO
'bp
..
.      \" Sh - Section Header (SH) replacement
.de Sh
.ti \\n(.iu
.RT
.\".if \\n(1T .sp
.RT
.ne 6
..
.      \" Nh - Numbered Header (NH) with TOC
.de Nh
.RT
.\".if \\n(1T .sp
.\".if !\\n(1T .BG
.RT
.ne 6
.nr NS \\$1
.if !\\n(.$ .nr NS 1
.if !\\n(NS .nr NS 1
.nr H\\n(NS +1
.if !\\n(NS-4 .nr H5 0
.if !\\n(NS-3 .nr H4 0
.if !\\n(NS-2 .nr H3 0
.if !\\n(NS-1 .nr H2 0
.if !\\$1 .if \\n(.$ .nr H1 1
.if \\$1S \{\
.      nr NS \\n(.$-1
.      nr H1 \\$2
.      nr H2 \\$3
.      nr H3 \\$4
.      nr H4 \\$5
.      nr H5 \\$6
.\}
.ds SN \\n(H1
.ti \\n(.iu
.if \\n(NS-1 .as SN .\\n(H2
.if \\n(NS-2 .as SN .\\n(H3
.if \\n(NS-3 .as SN .\\n(H4
.if \\n(NS-4 .as SN .\\n(H5
\\*(SN.  \\$2 \\$3 \\$4 \\$5 \\$6 \\$7 \\$8 \\$9
.br
.\" TOC
.\" (non-top-level sections)
.ie \\n(NS-1 \{\
.      nr Pd \\n(PD
.      nr PD 0
.      XS
.      nr jj \\n(NS-1*3+5
\h'|\\n(jjn'\\*(SN\h'|18n'\\$2 \\$3 \\$4 \\$5 \\$6 \\$7 \\$8 \\$9
.      XE
.      nr PD \\n(Pd
.\}
.\" (top-level sections)
.el \{\
.      XS
\h'|5n'\\*(SN.\h'|12n'\\$2 \\$3 \\$4 \\$5 \\$6 \\$7 \\$8 \\$9
.      XE
.\}
..
.de XX
.XS
\h'|5n'\\$1 \\$2 \\$3 \\$4 \\$5 \\$6 \\$7 \\$8 \\$9
.XE
..
.nr Yr \n(yr+1900
.ds LF Simpson, Vixie
.ds CF expires after 6 months
.ds RF FORMFEED[Page \\n(PN]
.ds LH RFC DRAFT
.ds CH ACSCF
.ds RH \*(DY
.ad l
.LP
.tl 'INTERNET-DRAFT''W A Simpson'
.tl '''DayDreamer'
.tl '''P Vixie'
.tl '''ISC'
.tl 'Intended status: Experimental''\*(DY'
.af PN i
.sp 2
.ce 3
Defiance Address-Change Signaling -
Concepts and Facilities
draft-simpson-acscf-2013May04
.sp 2
.\" another attempt to turn off hyphenation for groff
.nh
.hlm 0
.hym 100
.\" for -ms, must turn off hyphenation after first para (sigh)
.hy 0
.ig
.Sh
Abstract
.LP
.RS
This is an introduction to
cooperating bridge relay address pools.
These servers are accessed using ephemeral address-change signaling,
and coordinated by an Address Pool Registration Protocol (APRP).
Address Pools are provisioned with sufficient
quantity,
quality,
and
diversity,
frustrating efforts of censors to
predict,
map,
or
block
the Internet Protocol (IP) addresses.
.RE
..
.ig

.Sh
Copyright Notice
.LP
.RS
Copyright (c) 2011 IETF Trust and the persons identified as the
document authors. All rights reserved.

This document is subject to BCP 78 and the IETF Trust's Legal
Provisions Relating to IETF Documents
(http://trustee.ietf.org/license-info) in effect on the date of
publication of this document. Please review these documents
carefully, as they describe your rights and restrictions with
respect to this document.

This document may contain material from IETF Documents or IETF
Contributions published or made publicly available before November
10, 2008.  The person(s) controlling the copyright in some of this
material may not have granted the IETF Trust the right to allow
modifications of such material outside the IETF Standards Process.

This document may not be modified, and derivative works of it
may not be created, except to format it for publication as an
RFC or to translate it into languages other than English.
.RE

.Sh
Status of this Memo
.LP
.RS
This Internet-Draft is submitted in full conformance with the
provisions of BCP 78 and BCP 79.

Internet-Drafts are working documents of the Internet Engineering
Task Force (IETF). Note that other groups may also distribute
working documents as Internet-Drafts. The list of current
Internet-Drafts is at http://datatracker.ietf.org/drafts/current.

Internet-Drafts are draft documents valid for a maximum of six
months and may be updated, replaced, or obsoleted by other
documents at any time. It is inappropriate to use
Internet-Drafts as reference material or to cite them other than as
"work in progress."
.RE
..
.nr Pn \n%+1
.P1
.bp 1
.af PN 1
.Nh 1 Introduction
.LP
.RS
Internet sites are frequently blocked by
government and institutional firewalls.
Content filtering firewalls capture and analyze network traffic
to autonomously determine what to block,
checking for predefined signatures or sensitive keywords.

If the censor simply denies access to the Internet Protocol (IP) network itself,
blocked users can no longer benefit from confidentiality protocols
that assist in evading local censorship [DM2006].
When an adversary controls the connection to the Internet,
and associated IP addresses become known over time,
current protocols are easy to circumvent:
.IP " - "
by blocking direct communication with the service itself,
.IP " - "
by blocking communication with a service discovery component,
.IP " - "
by blocking access entry points
distributed by service discovery
and/or
listed in a communal service directory,
.IP " - "
by scanning
suspect IP addresses or address blocks
for service response fingerprints
and preemptively blocking them,
or
.IP " - "
by filtering based on the fingerprint of the protocol.
.LP
Service discovery and access entry points are
insufficiently numerous
and change infrequently.
A well-funded adversary can locate them all.

This document proposes techniques for
averting scanning and avoiding blocking of
service discovery
and
access entry points.
Address Pools are provisioned with sufficient
quantity,
quality,
and
diversity,
frustrating efforts of censors to
predict,
map,
or
block
the IP addresses.

Although all service responses and protocols have a fingerprint,
this design attempts to mimic other wide-spread protocols and services.
It is intended to be used together with other mitigation efforts.
.RE
.sp 2
.Nh 2 Rejected Alternatives
.LP
.RS
Volunteer facilities for service discovery and access entry points
are often inadequate and insecure.
Consumer grade infrastructure
is easily swamped by traffic volumes,
causing an inadvertent Denial of Service (DoS).

Combining service discovery with access entry points
is very likely to be compromised.
If a user is an adversary or cooperating with an adversary,
this information could be quickly blocked.

The One Time Telescope (OTT) proposal
involved a larger than practical (O(10**6))
inventory of IP addresses
and had inadequate protection against
DoS attacks,
scanning,
and
traffic analysis.

Other alternatives
are mentioned throughout this document.
.RE
.sp 2
.Nh 2 Terminology
.LP
.RS
The key words
"MAY",
"MUST, "MUST NOT",
"OPTIONAL", "RECOMMENDED", "REQUIRED",
"SHOULD", and "SHOULD NOT"
in this document
are to be interpreted as described in [RFC2119].
.IP "access entry point  " 17
Compound term encompassing the combined concepts of
access, authentication, authorization, and entry point.
Not dependent on a particular technology.
Distinguished from service discovery.
.IP "Address Pool Operator  " 17
The management organization administering the APRAdb.
.IP "Address Pool Provider  " 17
An Internet Service Provider (ISP)
supplying IP addresses
and/or network data center facilities
to the Address Pool Operator.
.IP "APRP  " 17
Address Pool Registration Protocol.
.IP "APRAdb  " 17
Address Pool Registration Administrative database.
.IP "Defiance User Agent  " 17
A client-side mechanism that accesses these protocol(s) and service(s),
expected to be implemented as an extension of the [Tor] mechanism.
Details are
beyond the scope of this specification.
.IP "DUA  " 17
Defiance User Agent.
.IP "peer  " 17
The other end of a Transmission Control Protocol (TCP) session.
.IP "user  " 17
A person who operates a Defiance User Agent.
.RE
.sp 2
.Nh 1 Adversary Model
.LP
.RS
In the usual security tradition,
this model aims to defeat a strong adversary.
By defending against this adversary,
the model inherits protection against weaker adversaries as well [DM2006].

A general design will work for citizens of censored countries,
for whistleblowers in firewalled corporate networks,
and for people in unanticipated oppressive situations.
Designing with a variety of adversaries in mind
takes advantage of the fact that various adversaries
will be in different stages of the arms race,
so a resource blocked in one locale can still be useful in others.
.RE
.sp 2
.Nh 2 Adversary Strengths
.LP
.RS
This strong adversary is assumed to be a nation-state
or state-sponsored technology group
having modern skills and tools.
.IP "1) "
They are capable of inspecting and analyzing network traffic,
both at the superficial header level and by deep packet inspection.
.IP "2) "
They are patient and well resourced.
.RS
.IP "a) "
They have sufficient computational processing and storage
to build extensive social maps of users.
.IP "b) "
They have contractors and other assets around the world
who aid their censorship.
.RE
.IP "3) "
If their traffic analysis leads them to
suspect IP addresses or address blocks
are being used for censorship bypass,
they can scan those network address blocks.
These scans might appear from anywhere in the world
using contractors or other assets.
Preventing scans entirely
might be taken as sufficient provocation to immediately block those
IP addresses or address blocks.
.IP "4) "
They control access to the Domain Name System (DNS) [RFC1034] [RFC1035].
.RS
.IP "a) "
They can detect every direct user request for censored sites,
either in real-time or after the fact.
.IP "b) "
By blocking a request,
they can prevent a user from learning requested DNS information.
.IP "c) "
By modifying the response,
or by replacing the response with entirely false information,
they can redirect a user to a different service or site than the user intended.
.IP "d) "
Without DNS security ([RFC4033] et seq.),
interceptions would be undetectable.
Yet the absence of DNS security is commonplace,
and most tools will continue without any user notification.
.IP "e) "
If DNS security is required,
there might not be any valid responses.
.RE
.IP "5) "
They can create counterfeit certificates used for
Transport Layer Security (TLS) [RFC5246].
.RS
.IP "a) "
They can detect every direct user request for censored sites,
either in real-time or after the fact.
.IP "b) "
By blocking a request,
they can prevent a user from completing a TLS connection.
.IP "c) "
By modifying the response,
or by replacing the response with entirely false information,
they can perform a Monkey-In-The-Middle (MITM) interception.
While relaying traffic between peers,
they could undetectably copy or modify the information.
.RE
.IP "6) "
They will eventually locate all previously used information assets
such as bridge or tunnel entry points,
rendezvous points,
and traffic aggregation points.
.LP
As a second-order effect,
censors aim to chill citizens' behavior
by creating an impression that their online activities are monitored
[DM2006].
.RE
.sp 2
.Nh 2 Adversary Weaknesses
.LP
.RS
On the other hand,
the model assumes that the censors (or their governments)
would like to have a working,
useful Internet [DM2006].
There are economic,
political,
and social factors
that prevent limiting access to only a tiny list of sites
or outlawing the Internet entirely.
.IP "1) "
Users have some control over their hardware and software.
The user will be able to fetch a genuine version of the software,
rather than one supplied by an adversary.
They don't have any spyware installed,
there are no cameras watching their screens,
etc.

Unfortunately,
in some situations these threats are only too real.
Software-based security systems are poorly equipped to handle a user
who is entirely observed and controlled by an adversary.
.IP "2) "
Complete blocking of specific content is not a goal.
Censors typically recognize that perfect censorship is
both impossible and unnecessary.
If "undesirable" information is known only to a few,
further censoring efforts can be focused elsewhere.

Never-the-less,
censors are willing to block innocuous content
(such as the bulk of a newspaper's reporting)
in order to censor other content distributed through the same channels
(that newspaper's coverage of the censored country).
When Address Pool Providers are revealed,
it is possible that all traffic through that provider will be blocked.
.IP "3) "
Firewalls have limited processing and storage.
An adversary is unable to correlate every connection and packet
in every stream on the local or regional network in real-time.
.IP "4) "
There will be a time lag between an adversary detecting assets,
and their ability to block usage of that specific asset.

Without sufficient time,
compared to both human reactions
and automated expiration of ephemeral services,
rapid rotation of Address Pool reserves
is likely to be futile.
.IP "5) "
While various censorship regimes can coordinate and share notes,
there will be a time lag between one adversary learning about assets,
or overcoming another facet of the design,
and sharing that information with other adversaries.
This information is most commonly shared via intermediaries,
such as censorship supporting vendors of
firewalls,
intrusion detection,
and other middleware.

Without sufficient time,
acquisition and allocation of Address Pool resources
is likely to be futile.
.RE
.sp 2
.ne 10
.Nh 1 Solution Overview
.LP
.RS
Rather than a few thousand well-known access entry points,
tens (or hundreds) of thousands of ephemeral IP addresses are
coordinated by Address Pool Operators
via central APRAdb servers
and regional Gateways.

Relay-based blocking resistance designs generally have two main components:
a discovery component and a relay component [DM2006].
This design includes an Address-Change Signaling
transition to obfuscate these main components.
.IP "1) "
Ephemeral contact information is distributed to
each user (or small group of users).
.IP "2) "
The DUA initiates contact with an apparently innocuous server.
This Initial Gateway returns a token (cookie).
.IP "3) "
The DUA delays for a specified period of time.
During this time,
the user or DUA continues contacting other innocuous sites.
.IP "4) "
The DUA contacts another apparently innocuous server.
This Redirect Gateway verifies the Initial Contact
and returns a short partial list of available ephemeral Bridge Relays.
.IP "5) "
The DUA distributes censorship evading traffic among the Bridge Relays
using equal cost multi-path (ECMP) techniques.
.IP "6) "
The user or DUA continues contacting other innocuous sites
as cover traffic to disguise interest in these
contact and/or bridge relay Gateways.
.LP
.Sh
Design Considerations:
.RS
IP addresses frequently change between contacts
from mobile devices.
Conversely,
the IP address remains the same for multiple users who
share connections behind a Network Address Translator (NAT) [RFC3022].

Therefore,
this protocol MUST NOT depend upon any IP address for security.
The protocol generates a different token (cookie)
for each separate contact sequence.

IP addresses change frequently during normal network operations.
This sequence of steps is intended to take advantage of
any firewall's limited processing and storage
by spreading contacts over time
(see section "Adversary Weaknesses" item 3).

Generation of cover traffic
by a user or DUA is
beyond the scope of this specification.
.RE

.Sh
Rejected alternatives:
.RS
Combining Initial Contact and Redirect Contact
would require (O(N**2)) verification,
searching the entire Gateway database cache of
distributed contact information for
every user (or small group of users).
This search will be impractical.

More than two (2) contacts might become too obvious.
Security protocols are safer with the fewest steps,
unless there's a technical reason for extra steps
(such as splitting computationally expensive steps
to avoid a DoS attack,
as in Photuris [RFC2522]).

Earlier versions of this proposal
silently discarded all Initial Contacts,
or Redirect Contacts and Bridge Relay connections
that did not occur during the specified period of time.
Relying on the IP address of the contacts
to validate the contact sequence
would not work for mobile users or multiple users behind a NAT.

Moreover,
this was identified as a possible traffic analysis vulnerability.
Whenever ephemeral IP addresses are contacted by a non-participant,
this behavior is now a controllable parameter.
.RE
.RE
.sp 2
.Nh 2 Address-Change Signaling
.LP
.RS
A central feature of this solution is Address-Change Signaling,
produced by the timing of contacts to a sequence of IP addresses.
Each contact appears indistinguishable from innocuous background traffic.
This is expected to be most efficacious in locations
where other traffic is frequently transmitted,
such as Internet cafes
or behind a NAT in a larger organization.

It is essential that there is no unusual pattern to detect
by an adversary monitoring user traffic.
Each contact uses only standard techniques,
mimicking common browsing and network access.

An adversary scanning IP address blocks
will not discover the contact and/or bridge relay Gateways.
Without the correct sequence and timing,
the Gateway does not respond to the contact
or returns an innocuous response.

.Sh
Design Considerations:
.RS
This term is similar to "frequency-change signaling"
(a well-known technique for more than a century),
where one or more discrete frequencies correspond to
each desired significant condition of a radio or telegraph code.
For example,
different frequencies are used for control and data communication.

Related forms of signaling have also been used with
Frequency Hopping Spread Spectrum,
where the pseudo-random frequency sequence is keyed by a secret.

Internet Protocol (IP) addresses
correspond to frequencies in this design.
.RE

.Sh
Rejected alternatives:
.RS
Another similar idea is "port knocking".
Contacts are made to a secret sequence of
Transmission Control Protocol (TCP) or User Datagram Protocol (UDP) ports
at a single IP address.
Without the correct sequence,
the desired port will remain closed,
defeating active remote scanning for open ports and services.

A multiple [RFC2616] HTTP GET sequence
is similar to port knocking.
Contacts are made to a secret sequence of relative paths
at a single HTTP Host
and/or secret sequence of Hosts
at a single IP address.

Any unusual knocking traffic pattern is readily detected by an adversary
and communication to the IP address could be blocked rapidly
(see section "Adversary Strengths" item 1).
.RE
.RE
.sp 2
.Nh 2 Address Pools
.LP
.RS
These contact and/or bridge relay Gateways
will use the Address Pool Registration Protocol (APRP)
to register IP addresses widely distributed
throughout many hundreds of small blocks
(4 to 256 addresses per block).
Ephemeral IP addresses will be scheduled
sparingly,
sparsely,
and
unpredictably,
preventing immediate identification by an adversary.
.RE
.sp 2
.Nh 2 Address Leases
.LP
.RS
Deployment will use the same techniques that miscreant botnets and spammers
utilize to evade detection.
Address blocks will be leased from Address Pool Providers around the world.
Indeed,
this will be a good opportunity for re-purposing
blocks that are already poisoned in network blocking lists
due to prior spamming.

Each provider will carve out sub-nets of their IP address space
that is globally reachable
via the Border Gateway Protocol (BGP) [RFC4271].
The set of IP sub-nets made available is expected to change over time.
Since this resource will be sparsely used,
the IP address supply is expected to be generous.

An IP sub-net
may be revoked at any time
by the Address Pool Operator.
Usage will drain by attrition,
as ephemeral contact addresses and/or bridge relay identities expire.
The sub-net can eventually be removed from the Address Pools
and used for other purposes.
.RE
.sp 2
.ne 10
.Nh 1 Servers
.LP
.RS
APRAdb servers will communicate
with contact and/or bridge relay Gateways using APRP,
maintaining
.IP "1) "
Address Pool sub-net registration,
.IP "2) "
the state of each pool IP address,
.IP "3) "
provisioning for
each user (or small group of users),
.IP "4) "
a contact history log,
and
.IP "5) "
assignment of the ephemeral Bridge Relay(s).
.LP
Ephemeral IP addresses will periodically alternate
usage as contact and/or bridge relays.
Each pool IP address has a state
(idle, initial, redirect, relay, unusable).
Each contact IP address has a history
(assignments, contacts, timeouts).

The Secure Shell (SSH) protocol ([RFC4251] et seq.)
is used for APRP authentication, confidentiality, and integrity.
SSH provides "keep alives" for black hole prevention
and to detect peer failure.
.RE
.sp 2
.Nh 2 Database Servers
.LP
.RS
APRAdb servers
will use a hub and spoke model.
The hub will consist of
an active primary master node
and a hot-standby backup node.
This reduces the number of interconnections between Gateways
(compared to a full mesh)
and facilitates maintenance operations.

Regional APRAdb servers MAY be deployed
to further reduce network latency.
These servers will self-select pairs of master and backup nodes.
Details are
beyond the scope of this specification.

.Sh
Design Considerations:
.RS
Locally deployed servers are less vulnerable to
monitoring (or physical tampering).
While the IP address(es) and physical location
are revealed by observation of Gateway traffic,
there is less concern that they might be remotely compromised.
They do not run most commonly vulnerable services
(such as HTTP).
The Address Pool Operator MUST use best current practices
for securing these servers.
.RE

.Sh
Rejected alternatives:
.RS
APRAdb servers
do not use [Tor] Hidden Service Protocol "rendezvous points"
to hide their locations.
This would considerably increase network latency,
and could increase vulnerability to a DoS congestion attack.
Although APRP traffic is handled in parallel with DUA responses,
all servers and services SHOULD respond as consistently as practicable
to inhibit traffic analysis
of differences in response timing
(see section "Adversary Strengths" items 1 and 3).
.RE
.RE
.sp 2
.Nh 2 Gateways
.LP
.RS
Deployment of contact and/or bridge relay Gateways
will use regional virtual servers
installed in a data center
at each Address Pool Provider location
to reduce network latency.
Each such Gateway will accept multiple IP addresses
within the Address Pool sub-net.
Deployment SHOULD use available IP addresses
interleaved with other local servers.

Each Gateway registers its Address Pool IP addresses
with the APRAdb using APRP.
Whenever both APRAdb master and backup SSH sessions are closed,
the Gateway will cease responding to contacts
until SSH communication is re-established.

.Sh
Design Considerations:
.RS
Remotely deployed Gateways are more vulnerable to
monitoring (or physical tampering) by an untrusted provider,
who could be suborned by an adversary.
Operations and protocols MUST NOT reveal confidential information.
Protocol data passing through the Gateways
MUST NOT reveal any long-term identities and secrets.

SSH will not be a conspicuous connection between servers,
as it is commonly used for logging, monitoring, and other operations.
APRP signaling from the contact and/or bridge relay Gateways
is intended to mimic common system logs
sent to a log server.

Never-the-less,
configuration information and traffic for the SSH connections will reveal
the current location of the APRAdb servers
and in some cases a relationship between Gateways.
This could be used to correlate incoming contacts
with traffic retained by an adversary or an untrusted provider.

Although the pattern of contacts will be observable,
APRP traffic to each Gateway is
combined over a single monitoring connection
to inhibit traffic analysis
that reveals the current usage of each ephemeral IP address.
The varied mix of operations is expected
to inhibit traffic analysis
of specific users in real-time.
.RE
.RE
.sp 2
.Nh 2 Routing via Tunnels
.LP
.RS
Future deployment will improve operational scaling by tunneling
additional Address Pool sub-nets to previously deployed Gateways.
While reducing operational expense,
this facilitates rapid and flexible deployment.

Each IP sub-net will be tunneled via an interior router supplied
by the Address Pool Operator
or by the Address Pool Provider.
Both dynamic and static routing models SHOULD be made
available in implementations.

Dynamic routing such as OSPF or RIP
would reduce configuration complexity.
Once an IP sub-net has been configured,
the router could both advertise it via the dynamic routing protocol
(thus achieving reachability)
and also register its sub-nets with the Gateway
(thus achieving utility).

Since any logic or configuration errors in the Address Pool router could
affect the provider's entire network,
some providers are expected to be extremely cautious about allowing an
outside router to participate in the network's dynamic routing.
If IP sub-nets are routed statically,
then the Address Pool router and
the provider's other routers
will be independently configured.
Each such IP sub-net will be registered in the Address Pools via APRP.

The routed traffic is carried to Gateways
over a tunnel protocol,
such as GRE, IPsec, L2TP, MPLS, SSH, etc.
The choice will depend on available routing equipment.
The tunnel SHOULD terminate at the topologically closest
regional Gateway
to reduce network latency.

.Sh
Design Considerations:
.RS
It is essential that there is no unusual pattern to detect
by an adversary monitoring user traffic.
Each tunnel uses only standard techniques.

While inspecting and analyzing network traffic,
an adversary could observe any
reduction of the Maximum Transmission Unit (MTU).
The tunnel overhead MUST use commonly deployed MTUs.
Protocols that do not shrink the MTU will be preferred.

While scanning network address blocks,
an adversary could observe any
changes in network latency
(see section "Adversary Strengths" item 3).
Deployment MUST use only contiguous network blocks,
without any telltale interleaving with other local servers.

Compared to remotely deployed Gateways,
monitoring (or tampering) by an untrusted provider
will not reveal as much information.
All traffic passing through the router(s) is secured.
Configuration information and traffic will not reveal
the current location of the APRAdb servers,
nor contact and/or bridge relay Gateways
deployed at other providers.
.RE
.RE
.sp 2
.Nh 2 Hostile Areas
.LP
.RS
Forward deployment into hostile areas is possible
only where routing via tunnel protocol(s) is feasible
and without undue interruption.
As these tunnels would
otherwise converge upon and reveal
extant Gateways,
they MUST operate over a multi-hop tunnel network
(potentially revealing Address Pool Providers).

.Sh
Design Considerations:
.RS
That poses a problem:
is the tunnel protocol used over the routing network
more readily detected than the [Tor] network itself?

Another problem:
this would not use the same method of setup.
There's no proof-of-life and proof-of-work.

Until these questions are answered,
forward deployment into hostile areas is
beyond the scope of this specification.
.RE
.RE
.sp 2
.ne 10
.Nh 1 Gateway Provisioning
.LP
.RS
Each Gateway configuration will include
a list of IP address blocks it serves.
The Gateway database cache is initialized with these IP addresses
in the idle state.

During Discovery Provisioning (below),
the APRAdb updates the status of IP addresses
at the contact and/or bridge relay Gateways
with the designated provisioning information.
The update includes the current state for each IP address,
a list of specific IP address ranges that are allowed access
(defaulting to all),
and additional details specific to each state.

The distribution mechanism MAY request
a delay for activating the contact addresses.
These updates are queued by the APRAdb
and sent later.
During the delay,
these IP addresses MAY be used for other services.

After an indication that an adversary has blocked an IP address,
or an IP address is the current destination of a DoS attack,
the APRAdb will update these IP address(es) as unusable.
The update MAY include
a list of specific IP address ranges that are denied access
(defaulting to all).

.Sh
Design Considerations:
.RS
Algorithms for address assignment are
beyond the scope of this specification.
.RE
.RE
.sp 2
.ne 30
.Nh 2 Bridge Relay List
.LP
.RS
A variable length array of Bridge Relays is transmitted from
the APRAdb to the Redirect Gateway,
and thence to the DUA.
An example,
in [RFC4627] application/json format:
.DS L
[
   {
      "Contact": {
         "IP_address": "198.51.100.33",
         "Encapsulations": [
            {
               "IP_subheader": 6,
               "Discriminator": 443
            }
         ]
      },
      "BR_Access": {
         "br_expiration": 3600,
         "br_identity": "7QDBkvCA1-B9K_U0vrQx1A",
         "br_secret": "Zm9vYmFy"
      }
   },
   {
      "Contact": {
         "IP_address": "203.0.113.44",
         "Encapsulations": [
            {
               "IP_subheader": 6,
               "Discriminator": 443
            }
         ]
      },
      "BR_Access": {
         "br_expiration": 7200,
         "br_identity": "A1xQrv0U_K9B-1ACvkBDQ7",
         "br_secret": "yFmYv9mZ"
      }
   }
]
.DE
.RS
Nota Bene: example values above are illustrative,
and SHOULD NOT be used in operation.
.RE
.RE
.sp 2
.ne 15
.Nh 1 Discovery Provisioning
.LP
.RS
Each user (or small group of users)
is provided
a pair of contact addresses,
a pair of timing values in seconds,
and a secret passphrase.

An example,
in [RFC4627] application/json format:
.DS L
{
   "initial" : "192.0.2.11",
   "redirect" : "192.0.2.22",
   "wait" : 95,
   "window" : 112,
   "passphrase" : "OUST COAT FOAL MUG BEAK TOTE"
}
.DE
Another example,
with URL shorteners:
.DS L
{
   "initial" : "bit.ly/7hkjeE",
   "redirect" : "bit.ly/Eejkh7",
   "wait" : 95,
   "window" : 112,
   "passphrase" : "OUST COAT FOAL MUG BEAK TOTE"
}
.DE
.RS
Nota Bene: example values above are illustrative,
and SHOULD NOT be used in operation.
.RE
.LP
The distribution mechanism is expected to involve
proof-of-life and proof-of-work.
Distributing this contact information to users is
beyond the scope of this specification.

Although there is no expiration field,
this contact information MUST be limited in time.
The distribution mechanism MAY request
a delay for activating the contact addresses,
or a longer period of validity.
By default,
these contacts will be available immediately,
and valid for 24 hours.

.Sh
Design Considerations:
.RS
Distribution of provisioning
is very likely to be compromised.
Users might share the information with each other,
or share a connection behind a NAT.

Therefore,
these addresses SHOULD be the least valuable,
such as retired Bridge Relays
or addresses that have been blocked by another adversary
(see section "Adversary Weaknesses" items 4 and 5).
Algorithms for address assignment are
beyond the scope of this specification.
.RE
.RE
.sp 2
.ne 10
.Nh 2 Contact Addresses
.LP
.RS
By default,
the contacts are standard string forms for IP addresses.
These addresses SHOULD NOT be Domain Names for the actual servers,
as this could leave an audit trail,
and/or permit an adversary to modify DNS values in transit.
This specification MUST avoid reliance on DNS
(see section "Adversary Strengths" item 4).

URL scheme names [RFC3986] are not included in the contact string.
When using the address,
the chosen URL scheme name MUST be appropriate to the expected contact.
.IP
The demonstration implementation will use
"http://" and "https://"
for the Initial Contact and Redirect Contact respectively.
.IP
Future implementations will use
"http://"
for both the Initial Contact and Redirect Contact.
.RE
.sp 2
.ne 10
.Nh 3 URL Shorteners
.LP
.RS
The contact addresses MAY be URL shorteners
(for example, "bit.ly/7hkjeE").
Use of URL shorteners allows contacts to change
from time to time without additional notice to users.

Interception or modification of URL shorteners is
considered to be unlikely,
as that would interfere with operation of the Internet for many users.
However,
all implementations MUST be capable of
bypassing the DNS portion of the URL shortener,
substituting standard string forms for IP addresses
(the above example resolves to "168.143.172.53/7hkjeE").

In addition,
URL shorteners MAY be time dependent:
calculated based on the current date,
and obscured by a cryptographic hash using the passphrase.
Details are
beyond the scope of this specification.

Moreover,
the URL scheme name within the shortener Redirect result MUST match
that used for the expected contact.
.IP
The demonstration implementation will use
"http://" and "https://"
for the Initial Contact and Redirect Contact respectively.
.IP
Future implementations will use
"http://"
for both the Initial Contact and Redirect Contact.
.RE
.sp 2
.ne 10
.Nh 3 URL Schemes
.LP
.RS
The Initial Contact uses "http://"
as it is less likely to be blocked or detected.
All traffic is exchanged in the clear,
and chosen to mimic common websites.

By default,
the [RFC2616] HTTP response will be
a mirror of a common website
or an actual website with plausible content.
(See [DM2006] sections 4.5 and 9.3.)
.IP
The demonstration Redirect Contact uses "https://"
to verify the Initial Contact
and protect the list of available ephemeral Bridge Relays.
.IP
Future implementations will use
"http://"
for both the Initial Contact and Redirect Contact.
.LP
This step requires
confidentiality,
mutual authentication,
and Perfect Forward Secrecy.

.Sh
Design Considerations:
.RS
This specification MUST avoid reliance on TLS ciphersuites
that are vulnerable to MITM attacks
(see section "Adversary Strengths" item 5).

Unfortunately,
current [RFC4279] "Pre-Shared Key" (PSK)
ciphersuites do not provide privacy protection
for the psk_identity.
Worse,
they are sufficiently different from a common TLS exchange
that they are readily detected by an adversary
and communication to the IP address could be blocked rapidly
(see section "Adversary Strengths" item 1).

This design will migrate to non-standard ciphersuites
that better protect the connection.
Details are
beyond the scope of this specification.
[Nota Bene: this phase was not implemented,
to avoid conflicting with similar (ab)use of the TLS exchange fields
by the SAFER CURVEBALL project.]

In the future,
other scheme pairs will be implemented.
For example,
the Redirect scheme could also be "http://"
with a suitable camouflaged protocol that provides
confidentiality,
mutual authentication,
and Perfect Forward Secrecy.
.RE
.RE
.sp 2
.ne 10
.Nh 3 HTTP GET
.LP
.RS
By default,
[RFC2616] HTTP GET will always use the minimal path "/"
and version 1.1:
.DS L
   GET / HTTP/1.1
.DE
Where URL shorteners are used,
they could contain a more specific path.
This path would be the same for
each user (or small group of users)
sharing the contact address pair.
It does not provide any additional signaling.

.Sh
Design Considerations:
.RS
The server root path ("/") is the most commonly used.
While other paths
could pass identification tokens (or other signals)
to the contact Gateway,
any unusual pattern is readily detected by an adversary
and communication to the IP address could be blocked rapidly
(see section "Adversary Strengths" item 1).

Consider an adversary who is afraid of false positives
and doesn't want to instantly block every IP address
marked by a single observation.
Multiple contacts with predictable fingerprints
increase the likelihood that
the number of observations pass a certain threshold.
This design minimizes distinguishing characteristics.
.RE

.Sh
Rejected alternatives:
.RS
A multiple [RFC2616] HTTP GET sequence
may avoid fingerprinting in some instances,
but available intrusion detection systems
are already able to detect this subterfuge.

Other paths are more difficult to emulate
and return relevant innocuous content.
There is no provisioning information
indicating length or style of path.
Paths that do not match other sites providing similar content
would provide an unusual pattern and predictable fingerprint
(see section "Adversary Strengths" item 2).

Randomized paths are readily distinguished,
as they rarely appear in practice.
While apparently random paths do appear in some cases
(for example,
photograph or video websites),
sending an actual randomized path
would most likely repeatedly result in
the HTTP 404 Not Found error message
or some other custom error page.
.RE
.RE
.sp 2
.ne 10
.Nh 3 HTTP Host
.LP
.RS
The [RFC2616] HTTP Host header field
MUST be included.
Absence would provide
an unusual pattern that is readily detected by an adversary
and communication to the IP address could be blocked rapidly
(see section "Adversary Strengths" item 1).

The Host field usually contains a DNS name for the website.
The DNS avoidance requirement (above)
precludes reliance on DNS names
(see section "Adversary Strengths" item 4).

By default,
the Host field contains an IP address.
When a DNS inverse address lookup provides a canonical name,
that name will be used instead.
.RE
.sp 2
.ne 10
.Nh 3 HTTPS Certificates
.LP
.RS
Although the [RFC5246] DH_anon ciphersuites
would be more natural for this environment,
they are rarely used.
The DHE_RSA combination is believed to be fairly common.

Each IP address MUST have its own DHE_RSA certificate.
This certificate is primarily for window dressing.
Instead,
the security of the protocol
depends on mutual authentication of the contact passphrase
and an ephemeral secret for each Bridge Relay.

.Sh
Design Considerations:
.RS
The Ephemeral Diffie-Hellman (DHE) ciphersuites
provide Perfect Forward Secrecy (PFS).

By default,
the certificates will be self-signed.
For greater verisimilitude,
the server could be a mirror of a common website
or an actual website with plausible content.
(See [DM2006] sections 4.5 and 9.3.)

Future versions of this protocol hope to
eliminate certificates entirely.
But hope is not a plan.
.RE
.RE
.sp 2
.ne 10
.Nh 2 Contact Timing
.LP
.RS
Timing delays serve as a "security by obscurity"
safeguard against detection.
The values determine timing between contacts,
allow sufficient time for contact to occur,
and provide a time limit on replays.

These timing parameters
MUST be different for
each user (or small group of users)
sharing the contact address pair.
For example,
a DUA might be configured with delay values 95 and 112.
Another DUA might use 100 and 120.
There is likely to be considerable overlap between users.

Moreover,
the product (multiplying the two values)
MUST be different for
each user (or small group of users)
sharing the contact address pair.
This assists in authentication processing.

In addition to the delay functionality,
these timing parameters are
a limited form of 2 to 6 digit
Personal Identification Number (PIN).
Although these digits are interdependent and might be derived from observation,
they provide an identity substitute for
each user (or small group of users)
sharing the contact address pair.
This also assists in anonymizing long-term log information,
as any IP addresses need not be retained.

.Sh
Design Considerations:
.RS
The timing values are appropriate for terrestrial communication.
Longer distances would need commensurately longer periods.
.RE
.RE
.sp 2
.ne 10
.Nh 2 Contact Passphrase
.LP
.RS
The passphrase prevents adversaries from
indirect discovery of the ephemeral Bridge Relay(s).
An interloper who can intercept or modify a TLS connection
will fail the final verification.

The passphrase uses the [RFC2289] One-Time Password System dictionary.
This provides a 64-bit secret key with an additional 2 bits of checksum.

All passphrase generators MUST calculate this checksum.
All passphrase calculations MUST verify this checksum
as part of the operation of decoding.
.RE
.sp 2
.ne 10
.Nh 2 Ephemeral Results
.LP
.RS
Ephemeral identities and secrets are generated
for each separate contact sequence.
Every user will obtain a different identity and secret
for each ephemeral Bridge Relay,
and they will expire expeditiously.

If a user is an adversary or cooperating with an adversary,
these Bridge Relays could be quickly blocked.
Only a small subset of available IP addresses will be given to
each user (or small group of users).

These ephemeral Bridge Relays are the "crown jewel",
the goal of Address-Change Signaling.
This step requires
confidentiality,
mutual authentication,
and Perfect Forward Secrecy.

.Sh
Confidentiality
.LP
.RS
Without confidentiality,
all Bridge Relays would be revealed to an adversary
and could be quickly blocked.
.RE

.Sh
Mutual Authentication
.LP
.RS
Separate identities and secrets
prevent impersonation of another user
and subsequent breaches of confidentiality.
Proofs of security for key exchange require
authentication of the ephemeral secret key
by both parties.
.RE

.Sh
Perfect Forward Secrecy
.LP
.RS
Compromised identities and secrets
MUST NOT violate the confidentiality of any current traffic
nor any earlier traffic.
.RE
.RE
.sp 2
.ne 10
.Nh 1 Contacts
.LP
.RS
DUA headers are chosen to emulate popular browsers.
If possible,
the user's default browser is determined and emulated.
.RE
.sp 2
.ne 10
.Nh 2 Initial Contact
.RS
.DS L
DUA                    Initial
==========             =======
HTTP GET            ->
  Referer*
                   <-  HTTP
                         Set-Cookie+
.DE
The DUA contacts the "initial" Gateway with HTTP.
A time-dependent HTTP Set-Cookie is returned to the DUA,
along with innocuous content.

The DUA SHOULD NOT send another HTTP GET request to this Gateway
until after the delay "window" seconds has elapsed.

If a URL shortener was used,
the HTTP Referer [sic] header field value SHOULD be set to the original URL.
Otherwise,
the Referer is not sent.

The Gateway MUST transmit one or more [RFC6265] Set-Cookie string(s).
The cookie-name SHOULD be any commonly implemented value,
such as ".ASPXAUTH", "PREF", etc.
The cookie-value MUST be unique
for its Initial Gateway,
but need not be unique among all Initial Gateways.

.Sh
Design Considerations:
.RS
It is theoretically trivial to defeat the Initial Contact.
A well-financed MITM might intercept and replace every Cookie.
If the adversary can track all cookies on the downstream side,
and restore them on the upstream side as they are used,
Internet services will not be disrupted.
It is assumed that an adversary will not have this capability
(see section "Adversary Weaknesses" item 3).

A significant volume of Initial Contacts
could be handled by the Gateway.
These contacts might be innocuous,
scans by an adversary,
or a DoS attack.
The Initial Gateway does not retain any additional state
for each Initial Contact.
.RE
.RE
.sp 2
.ne 15
.Nh 2 Redirect Contact
.RS
.DS L
DUA                    Redirect
==========             ========
HTTPS               ->
                   <-  HTTPS
HTTP GET            ->
  Referer*
                   <-  HTTP
                         bridge relay(s)+
                           Camouflage*
                           Contact
                           br_expiration
                           br_identity
                           br_secret
.DE
The DUA delays for "wait" seconds,
then contacts the "redirect" Gateway by
specifying a ciphersuite
using a time-dependent verification_key
generated from its passphrase
and the Hello random (timed) values.

If a URL shortener was used,
the HTTP Referer [sic] header field value SHOULD be set to the original URL.
Otherwise,
the Referer is not sent.

This Gateway consults its provisioning status
for verification information.
If the contact is authenticated and authorized,
it returns a short list of ephemeral Bridge Relays.

Each relay specifies a randomly generated
ephemeral br_identity and br_secret
that is different for every user and relay pairing.
The br_identity MUST be unique
for its Bridge Relay,
but need not be unique among all Bridge Relays.

.Sh
Design Considerations:
.RS
A significant volume of Redirect Contacts
could be handled by the Gateway.
These contacts might be innocuous,
scans by an adversary,
or a DoS attack.
Provision for filtering contacts is REQUIRED.
These contacts will be discarded after expiration of the delay window.
.RE
.RE
.sp 2
.ne 15
.Nh 2 Bridge Relays
.RS
.DS L
DUA                    Relay(s)
==========             ========
HTTPS               ->
                   <-  HTTPS
HTTP GET            ->
                   <-  HTTP
.DE
The DUA contacts Bridge Relays by
specifying a ciphersuite
using another time-dependent verification_key
generated from its ephemeral br_secret
and the Hello random (timed) values.

This Gateway consults its provisioning status
for verification information.
If the contact is authenticated and authorized,
it permits access.
.RE
.sp 2
.ne 15
.XX ACKNOWLEDGMENTS
Acknowledgments
.LP
.RS
This document parallels text originally in [DM2006],
combined with more stringent requirements of Defiance,
and text from various other drafts by the same author
(such as Photuris, PIPE, and TCPCT).

Roger Dingledine
and
George Kadianakis
made substantial contributions and suggestions.

Jeroen Massar
provided motivation for several rejected alternatives.
.RE
.ig
.sp 2
.ne 15
.XX IANA CONSIDERATIONS
IANA Considerations
.LP
.RS
This document has no IANA actions.

[RFC Editor: please remove this section prior to publication.]
.RE
..
.sp 2
.ne 15
.XX OPERATIONAL CONSIDERATIONS
Operational Considerations
.LP
.RS
Any implementation of this specification SHOULD be configurable,
separately for each port or connection.

Each APRAdb and Gateway configuration will include
the public keys for all systems.

Each Gateway configuration will include
a list of IP address blocks it serves.

Additional details are found in [ACSIS].
.RE
.sp 2
.ne 15
.XX SECURITY CONSIDERATIONS
Security Considerations
.LP
.RS
This protocol was based on currently available tools,
by experienced network protocol designers with an interest in cryptography,
rather than by cryptographers with an interest in network protocols.
This specification is intended to be readily implementable
without requiring an extensive background in cryptology.

Never underestimate traffic analysis!
It's surmised that well-funded,
secret institutions
are far ahead of the public cryptology field.

In particular,
every protocol will leave a fingerprint.
This attempts to avoid as many known issues as practicable,
providing agility and flexibility
to resist analysis.

Under a Denial of Service (DoS) attack,
this is designed to fail softly.
Each Gateway database cache is read-mostly,
supporting a large number of contacts.
When SSH connections are blocked by traffic,
the Gateway will cease responding to contacts
until SSH communication is re-established.

Other security considerations
are mentioned in Design Considerations throughout this document.
.RE
.sp 2
.ne 25
.XX NORMATIVE REFERENCES
Normative References
.RS
.LP
.IP "[RFC2119]  " 12
Bradner, S.,
"Key words for use in RFCs to Indicate Requirement Levels",
BCP 14,
.\" Harvard University,
March 1997.
.IP "[RFC2289]  " 12
Haller, N.,
Metz, C.,
Nesser, P.,
and
M. Straw,
"A One-Time Password System",
STD 61,
RFC 2289,
February 1998.
.IP "[RFC2616]  " 12
Fielding, R.,
Gettys, J.,
Mogul, J.,
Frystyk, H.,
Masinter, L.,
Leach, P.,
and
T. Berners-Lee,
"Hypertext Transfer Protocol -- HTTP/1.1",
RFC 2616,
June 1999.
.IP "[RFC4251]  " 12
Ylonen, T.
and
C. Lonvick, Ed.,
"The Secure Shell (SSH) Protocol Architecture",
RFC 4251,
January 2006.
.IP "[RFC4279]  " 12
Eronen, P.,
Ed.,
and
H. Tschofenig,
Ed.,
"Pre-Shared Key ciphersuites for Transport Layer Security (TLS)",
RFC 4279,
December 2005.
.IP "[RFC4627]  " 12
Crockford, D.,
"The application/json Media Type for JavaScript Object Notation (JSON)",
RFC 4627,
July 2006.
.IP "[RFC5246]  " 12
Dierks, T.
and
E. Rescorla,
"The Transport Layer Security (TLS) Protocol Version 1.2",
RFC 5246,
August 2008.
.IP "[RFC6265]  " 12
Barth, A.,
"HTTP State Management Mechanism",
RFC 6265,
April 2011.
.RE
.sp 2
.ne 10
.XX INFORMATIVE REFERENCES
Informative References
.RS
.LP
.IP "[ACSIS]  " 12
Simpson, W.,
and
P. Vixie,
"Defiance Address-Change Signaling -
Implementation and Specification",
work in progress,
draft-simpson-acsis-2012Dec08
.IP "[DM2006]  " 12
Dingledine, R.,
and
N. Mathewson,
"Design of a blocking-resistant anonymity system Tor Project technical report",
November 2006.
https://svn.torproject.org/svn/projects/design-paper/blocking.html
.IP "[RFC1034]  " 12
Mockapetris, P.,
"Domain names - concepts and facilities",
STD 13,
RFC 1034,
November 1987.
.IP "[RFC1035]  " 12
Mockapetris, P.,
"Domain names - implementation and specification",
STD 13,
RFC 1035,
November 1987.
.IP "[RFC2522]  " 12
Karn, P.
and
W. Simpson,
"Photuris: Session-Key Management Protocol",
RFC 2522,
March 1999.
.IP "[RFC3022]  " 12
Srisuresh, P.,
and
K. Egevang,
"Traditional IP Network Address Translator (Traditional NAT)",
January 2001.
.IP "[RFC3986]  " 12
Berners-Lee, T.,
Fielding, R.,
and
L. Masinter,
"Uniform Resource Identifier (URI): Generic Syntax"
STD 66,
RFC 3986,
January 2005.
.IP "[RFC4033]  " 12
Arends, R.,
Austein, R.,
Larson, M.,
Massey, D.,
and
S. Rose,
"DNS Security Introduction and Requirements",
RFC 4033,
March 2005.
.IP "[RFC4271]  " 12
Rekhter, Y.
and
T. Li,
"A Border Gateway Protocol 4 (BGP-4)",
RFC 1771,
March 1995.
.IP "[Tor]  " 12
Dingledine, R.,
and
N. Mathewson,
"Tor Protocol Specification".
https://gitweb.torproject.org/torspec.git?a=blob_plain;hb=HEAD;f=tor-spec.txt
.RE
.sp 2
.ne 15
.XX CONTACTS
Author's Address
.LP
.RS
Questions about this document can be directed to:
.RS
.DS L
William Allen Simpson
DayDreamer
Computer Systems Consulting Services
1384 Fontaine
Madison Heights, Michigan  48071

    William.Allen.Simpson@Gmail.com
.DE
.DS L
Paul Vixie
Internet Software Consortium
950 Charter Street
Redwood City, California  94063

    vixie@isc.org
.DE
.RE
.RE
.\" TOC
.bp \n(Pn
.af PN i
.if \n(VS>=40 .vs \n(VSu
.if \n(VS<=39 .vs \n(VSp
.ll \n(LLu
.lt \n(LTu
.ta \n(LLu-5n \n(LLuR
.in 0
.nf
.rs
.\" tl ''\f3\s+2Table of Contents\s-2\f1''
.sp
.TC x
