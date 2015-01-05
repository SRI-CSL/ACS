.\" gdiffmk acsis-00f.nr acsis-00.nr >d
.\" gdiffmk acsis-2012May01.nr acsis-00.nr >d
.\" gdiffmk ../svn/doc/drafts/acsis-00.nr acsis-00.nr >d
.\" nroff -ms -Tascii d >t
.\" nroff -ms -Tascii acsis-00.nr >t
.\" sed -e 's/FORMFEED\[Page/        ^L\[Page/' t | pg -n5 >acsis-2013May04.txt
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
.ds CH ACSIS
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
Implementation and Specification
draft-simpson-acsis-2013May04
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
This specification details interactions and traffic coordinating
cooperating bridge relay address pools.
These servers are accessed using ephemeral address-change signaling,
and coordinated by an Address Pool Registration Protocol (APRP).
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
This specification describes the details of address-change signaling
and the Address Pool Registration Protocol (APRP).
.ig
central database

remote operational cache

limited

security
..
This document is preliminary,
and "[...]" indicates areas to be updated based on implementation experience.

This document assumes that
the reader is familiar with the related document
"Defiance Address-Change Signaling -
Concepts and Facilities" [ACSCF],
where matching section titles
provide important background for this specification.
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
.IP "APRP  " 17
Address Pool Registration Protocol.
.IP "APRAdb  " 17
Address Pool Registration Administrative database.
.IP "byte  " 17
An 8-bit quantity;
also known as "octet" in standardese.
.IP "Defiance User Agent  " 17
A client-side mechanism that accesses these protocol(s) and service(s),
expected to be implemented as an extention of the [Tor] mechanism.
Details are
beyond the scope of this specification.
.IP "DUA  " 17
Defiance User Agent.
.IP "silently discard" 17
The implementation discards the packet
without further processing.
The implementation SHOULD provide the capability of logging the error,
including the contents of the silently discarded packet,
and SHOULD record the event in a statistics counter.
.IP "user  " 17
A person who operates a Defiance User Agent.
.IP "<number>" 17
A decimal value.
Unless otherwise specified,
these numbers are expected to be positive integers
with a maximum of at least 2**23.
.IP "<string>" 17
A quote delimited value.
Unless otherwise specified,
<string> MUST NOT be NUL terminated.
.RE
.sp 2
.ne 10
.Nh 2 Gateway Provisioning (Simplified)
.RS
.DS L
                       Gateway                APRAdb
                       =======                ======
                       Request Status      ->
                         IP_state idle
                                          <-  Accept (Ack)
.DE
As a Gateway (re-)starts,
it contacts the APRAdb to register its IP addresses.
.RE
.sp 2
.ne 15
.Nh 2 Discovery Provisioning (Simplified)
.RS
.DS L
DUA                    Gateway                APRAdb
==========             =======                ======
(unspecified)       ->
                       Request User        ->
                                          <-  Accept (Ack)
                   <-  (unspecified)
.DE
The DUA contacts the Discovery Provisioning server,
that in turn obtains the contact information.
This server MAY be co-located with a Gateway (illustrated),
or MAY be a separate entity at an independent location.
The method of contact is
beyond the scope of this specification.
.DS L
                       Gateway(s)             APRAdb
                       ==========             ======
                                          <-  Request Status
                                                IP_state relay
                       Accept (Ack)        ->
                                          <-  Request Status
                                                IP_state redirect
                       Accept (Ack)        ->
                                          <-  Request Status
                                                IP_state initial
                       Accept (Ack)        ->
.DE
The APRAdb updates Gateway(s)
with the contact information.
.RE
.sp 2
.ne 15
.Nh 2 Initial Contact (Simplified)
.RS
.DS L
DUA                    Initial                APRAdb
==========             =======                ======
HTTP GET            ->
  Referer*
                   <-  HTTP
                         Set-Cookie+

                       Request Initial     ->
                                          <-  Accept (Ack)
.DE
The DUA contacts the Initial Gateway.
Each contact is logged.
.RE
.sp 2
.ne 15
.Nh 2 Redirect Contact (Simplified)
.RS
.DS L
DUA                    Redirect               APRAdb
==========             ========               ======
HTTP GET            ->
  Referer*
                   <-  HTTP
                         bridge relay(s)+
                           Camouflage*
                           Contact
                           br_expiration
                           br_identity
                           br_secret

                       Request Redirect    ->
                                          <-  Accept (Ack)
.DE
The DUA delays for a specified number of seconds,
then contacts the Redirect Gateway.
When the contact is authenticated and authorized,
it returns a short list of ephemeral Bridge Relays.
Each contact is logged.
.RE
.sp 2
.ne 15
.Nh 2 Bridge Relay (Simplified)
.RS
.DS L
DUA                    Relay(s)               APRAdb
==========             ========               ======
HTTP GET            ->
                   <-  HTTP

                       Request Relay       ->
                                          <-  Accept (Ack)
.DE
The DUA contacts these Bridge Relays.
Each contact is logged.
.DS L
                       Gateway(s)             APRAdb
                       ==========             ======
                                          <-  Request Status
                                                IP_state relay
                       Accept (Ack)        ->
                                          <-  Request Status
                                                IP_state redirect
                       Accept (Ack)        ->
.DE
The APRAdb updates Gateway(s)
with new contact information.
.RE
.sp 2
.ne 10
.Nh 1 Transactions
.LP
.RS
APRP is a stream of [RFC4627] JSON text,
represented as a virtual JSON ordered array.
The virtual array "[" and "]" are omitted.

A message consists of a variable number of JSON arrays and objects.
Other JSON values are silently discarded.

Each message MUST commence with a transaction object.
When the object is not valid,
the entire message is silently discarded.

The message is concluded by the next transaction object,
or by closing the connection.
Asynchronous bidirectional transactions are supported.

Multiple elements of an array or members of an object
are separated by a comma (value-separator).
The final element or member SHOULD NOT be followed by a comma.

JSON is case-sensitive.

.Sh
Design Considerations:
.RS
Although JSON has no inheritance feature,
this specification uses the convention
that an object name string followed by a comma
(or closing brace or bracket)
instead of a colon (name-separator)
indicates the position of a previously specified named Attribute.
Whenever such a named Attribute is listed within a JSON array,
its name string and colon are not sent.

JSON has no whitespace requirement.
Although definitions and examples are indented
with each member on a separate line,
the transmitted message will eliminate whitespace.
For diagnostic convenience,
each message SHOULD be followed by CRLF.

Each transaction is a stream
and is never cached as an entire object.
No element or member will exceed 65,535 bytes.
.RE
.RE
.sp 2
.ne 15
.Nh 2 Transaction_Accept (Ack)
.RS
.DS L
"Transaction_Accept": <number>
.DE
.IP "<number>  " 17
a copy of the received Transaction field
causing this Transaction_Accept.
.LP
Transaction_Accept concludes any previous transaction in this direction,
but does not start a new transaction.

If every Attribute received in a Transaction_Request is recognizable
and all values are acceptable,
then the implementation MUST transmit
Transaction_Accept.

Transaction_Accept is followed by Attributes
that convey information used to
provide specific configuration information
necessary to begin delivery of services to the user.

On reception of Transaction_Accept,
the <number> field
is matched with a pending Transaction_Request.
When the value is not valid,
the entire message is silently discarded.
.RE
.sp 2
.ne 15
.Nh 2 Transaction_Modify (Nak)
.RS
.DS L
"Transaction_Modify": <number>
.DE
.IP "<number>  " 17
a copy of the received Transaction field
causing this Transaction_Modify.
.LP
Transaction_Modify concludes any previous transaction in this direction,
but does not start a new transaction.

If every Attribute received in a Transaction_Request is recognizable
and some values are not acceptable,
then the implementation MUST transmit
Transaction_Modify.

Attributes without value fields (boolean attributes) MUST use the
Transaction_Reject reply instead.
.ig
All acceptable Attributes are filtered out of the Transaction_Modify,
but otherwise
the Attributes from the Transaction_Request MUST NOT be reordered.

Each Attribute that is allowed only a single instance
MUST be modified to a value acceptable to the Transaction_Modify sender.
The default value MAY be used,
when this differs from the requested value.

When a particular Attribute
can be listed more than once with different values,
the Transaction_Modify MUST include a separate Attribute
for every value acceptable to the Transaction_Modify sender,
including acceptable values that were present in the Transaction_Request.

An implementation may be configured to request the negotiation of
a specific Attribute.
If that Attribute is not listed,
then that Attribute MAY be appended to the list of Nak'd
Attributes in order to prompt the receiver to include that Attribute
in its next Transaction_Request packet.
Any value fields for the Attribute MUST indicate
values acceptable to the Transaction_Modify sender.
..

On reception of Transaction_Modify,
the <number> field
is matched with a pending Transaction_Request.
When the value is not valid,
the entire message is silently discarded.
.ig
Reception of a valid Transaction_Modify indicates that a new Transaction_Request
MAY be sent with the Attributes modified as specified in
the Transaction_Modify.
When multiple instances of an Attribute are present,
the implemention SHOULD select a single value
to include in its next Transaction_Request.

Some Attributes have a variable length.
Since the Nak'd Attribute has been modified,
the implementation MUST be able to handle an Attribute length
that is different from the original Transaction_Request.

The Transaction_Modify MAY also be used to send
additional authentication configuration information or queries.
In this case,
a new Transaction_Request SHOULD be sent
after the additional information becomes available.
..
.RE
.sp 2
.ne 15
.Nh 2 Transaction_Reject
.RS
.DS L
"Transaction_Reject": {
   "Received_Transaction": <number>,
   "Received_Attribute": <string>
}
.DE
.IP "Received_Transaction <number> " 17
a copy of the received Transaction field
causing this Transaction_Reject.
.IP "Received_Attribute <string>  " 17
a copy of the received Attribute JSON object name
causing this Transaction_Reject.
.LP
Transaction_Reject concludes any previous transaction in this direction,
but does not start a new transaction.

If any Attribute or Transaction_Request received
is not recognizable or is not acceptable for use
(as configured by an administrator),
then the implementation MUST transmit
Transaction_Reject.

When more than one Received_Attribute is rejected in the same transaction,
another Transaction_Reject is sent for each such Attribute.

On reception of Transaction_Reject,
the Rejected-Transaction
is matched with a pending Transaction_Request.
When the value is not valid,
the entire message is silently discarded.
.RE
.sp 2
.ne 15
.Nh 2 Transaction_Request
.RS
.DS L
"Transaction_Request": {
   "Transaction": <number>,
   "Request": <string>
}
.DE
.IP "Transaction <number> " 17
aids in matching requests and replies.
Initially zero (0).
Incremented by one (1) for each new transaction.
Wraps from 2**23-1 to zero (0).

Nota Bene: avoid complications of unsigned number representations;
comparisons MUST use equality tests.
.IP "Request <string>  " 3
.RS
.IP "Idle  " 14
When a transaction is not immediately followed by another transaction,
this SHOULD be used as a temporary transaction termination
instead of closing the connection.
In this case,
the Transaction value is not incremented;
any response refers to the original Transaction_Request.
.IP "Initial  " 14
Logs each Initial Contact.
.IP "Redirect  " 14
Logs each Redirect Contact.
.IP "Relay  " 14
Logs each Bridge Relay Contact.
.IP "Status  " 14
Updates the Address Pool.
.IP "User  " 14
Registers Discovery Provisioning.
.RE
.LP
Transaction_Request concludes any previous transaction in this direction.

When the connection is not closed,
another Transaction_Request will be sent with a new Transaction value.

Transaction_Reject of Transaction_Request
indicates the Request field
is not recognizable or is not acceptable for use
(as configured by an administrator),
and is also a special indicator of any internal operational failure.
The occurance SHOULD be reported and logged.
.RE
.sp 2
.ne 15
.Nh 1 Common Attributes
.LP
.Nh 2 AP_state Attribute
.RS
.DS L
"AP_state": <string>
.DE
.IP "<string>  " 3
.RS
.IP "idle  " 14
The IP address range enters the holding state.
Existing contacts are permitted to continue.
New contacts are silently discarded.
.IP "initial  " 14
Used for Initial Contacts.
.IP "redirect  " 14
Used for Redirect Contacts.
.IP "relay  " 14
Used for Bridge Relays.
.IP "unusable  " 14
The IP address range enters the poisoned state.
Existing contacts are immediately terminated.
New contacts from listed IP address blocks are silently discarded.
.RE
.LP
This Attribute is
immediately followed by
a JSON array of
IP_block Attributes.
.RE
.ig
.sp 2
.ne 10
.Nh 2 AP_status Attribute
.RS
.DS L
"AP_status": {
   "AP_timer": <number>,
   "AP_state": <string>
}
.DE
.IP "AP_timer <number>  " 17
Time in this state
(in seconds).
.IP "AP_state <string>  " 17
Same as AP_state Attribute.
.LP
(Currently unused.)

This Attribute is
immediately followed by
a JSON array of
IP_block Attributes.
One or more such objects are always transmitted
in a variable length JSON array.
.RE
..
.sp 2
.ne 10
.Nh 2 IP_address Attribute
.RS
.DS L
"IP_address": <string>
.DE
.IP "<string>  " 17
4 to 39 bytes:
string representation of a unicast IP address.
This MUST NOT be a long decimal, octal, or hexadecimal number.
Each IP version has its distinguished format.
(For example, see [RFC5952].)
.LP
This Attribute is frequently transmitted
as the second member of a JSON object.
.RE
.sp 2
.ne 10
.Nh 2 IP_block Attribute
.RS
.DS L
"IP_block": {
   "IP_bits": <number>,
   "IP_address": <string>
}
.DE
.IP "IP_bits <number>  " 17
0 to 32 (or 128).
The power of two indicating the size of the block.
(The number of least significant zero bits in the interface netmask.)
That is,
0 is 1 address,
1 is 2 addresses,
etc.
.IP "IP_address <string>  " 17
Same as IP_address Attribute.
.LP
This Attribute is always transmitted
in a variable length JSON array.
.RE
.sp 2
.ne 10
.Nh 2 IP_blocks Attribute
.RS
.DS L
"IP_blocks": [
   "IP_block",
   ...
]
.DE
A JSON array of one (or more)
IP_block Attribute(s).
The semantics are dependent upon the context.
.RE
.sp 2
.ne 10
.Nh 2 IP_subheader Attribute
.RS
.DS L
"IP_subheader": <number>
.DE
.IP "<number>  " 17
0 to 255.
.LP
The next header (or transport protocol) following the IP header.
Usually,
this value is 6 (TCP).
.RE
.sp 2
.ne 10
.Nh 2 Discriminator Attribute
.RS
.DS L
"Discriminator": <number>
.DE
.IP "<number>  " 17
0 to 2**16 - 1 for common IP_subheader ports,
0 to 2**32 - 1 otherwise.
.LP
Usually,
this value is well-known for each URI scheme [RFC3986].
.RE
.sp 2
.ne 10
.Nh 2 Encapsulation Attribute
.RS
.DS L
"Encapsulation": {
   "IP_subheader": <number>,
   "Discriminator": <number>
}
.DE
.IP "IP_subheader <number>  " 17
Same as IP_subheader Attribute.
.IP "Discriminator <number>  " 17
Same as Discriminator Attribute.
Optional,
dependent upon the IP_subheader.
.LP
This Attribute is always transmitted
in a variable length JSON array.
.RE
.sp 2
.ne 10
.Nh 2 Encapsulations Attribute
.RS
.DS L
"Encapsulations": [
   "Encapsulation",
   ...
]
.DE
A JSON array of one (or more)
Encapsulation Attribute(s).
The semantics are dependent upon the context.
.RE
.sp 2
.ne 10
.Nh 2 Contact Attribute
.RS
.DS L
"Contact": {
   "IP_address": <string>,
   "Encapsulations"
}
.DE
.IP "IP_address <string>  " 17
Same as IP_address Attribute.
.IP "Encapsulations  " 17
Same as Encapsulations Attribute (array).
.RE
.sp 2
.ne 10
.Nh 2 Contact_pairing Attribute
.RS
.DS L
"Contact_pairing": [
   "Contact",
   "Contact"
]
.DE
The first Contact Attribute is the remote (client) system.
The second Contact Attribute is the local (server) system;
sent to distinguish multiply "homed" systems
or service on multiple ports.
.RE
.sp 2
.ne 10
.Nh 2 Contact_logging Attribute
.RS
.DS L
"Contact_logging": {
   "count": <number>,
   "delay": <number>
}
.DE
.IP "count <number>  " 17
Contacts since last logging entry for the same Contact_pairing Attribute.
Normally one (1).
.IP "delay <number>  " 17
Seconds since last logging entry for the same Contact_pairing Attribute.
When the pair has never been recorded,
MUST be zero (0).
.LP
This Attribute immediately follows the Contact_pairing Attribute,
and assists in consolidating repeated logging messages.
.RE
.sp 2
.ne 10
.Nh 1 Scheme-specific Attributes
.LP
.Nh 2 Camouflage Attribute
.RS
.RS
.DS L
"Camouflage": {
   "method": <string>,
   "scheme": <string>
}
.DE
.IP "method <string>  " 17
Implementation dependent.
.IP "scheme <string>  " 17
A well-known URI scheme [RFC3986].
Typically,
"http".
.LP
This Attribute is optional.
When not present,
no camouflage is available.
.RE
.sp 2
.ne 10
.Nh 2 HTTP_Cookie Attribute
.RS
.DS L
"HTTP_Cookie": <string>
.DE
.IP "<string>  " 17
0 to 4,096 bytes.
[RFC6265]
.LP
When sent from the APRAdb to a Gateway,
this includes embedded formatting
that is replaced at the time of subsequent transmission:
.IP "%V#u"
unsigned decimal
.IP "%V#U"
[RFC4648] base64url
.IP "%V#x"
lower case hexadecimal
.IP "%V#X"
upper case hexadecimal
.LP
where # is a REQUIRED decimal number
indicating the total output characters in this field.
When a leading zero (0) is present,
small values have leading zero(es) in the
most significant digits.

This Attribute is always transmitted
in a variable length JSON array
(an empty array MUST NOT be omitted).
.RE
.sp 2
.ne 10
.Nh 2 HTTP_Referer Attribute
.RS
.DS L
"HTTP_Referer": <string>
.DE
.IP "<string>  " 17
0 to 255 bytes:
also known as IRI, URI, or URL.

Note [RFC2616] specifies:
"The HTTP protocol does not place any a priori limit on the length of a
URI. Servers MUST be able to handle the URI of any resource they serve,
and SHOULD be able to handle URIs of unbounded length if they provide
GET-based forms that could generate such URIs."

This specification deliberately limits the length.
On reception,
any HTTP Referer [sic] header field exceeding this length
MUST be silently discarded
without sending via APRP.
In practice,
any expected URL shortener
is likely to be considerably shorter.
.LP
This Attribute is always transmitted
in a variable length JSON array
(an empty array MUST NOT be omitted).
.RE
.sp 2
.ne 10
.Nh 1 Security Attributes
.LP
.RS
This design is security protocol independent.
The chosen protocol MUST provide
confidentiality,
mutual authentication,
and Perfect Forward Secrecy.

These attributes are now specified in companion transport documents.
.RE
.sp 2
.ne 15
.Nh 2 Security_logging Attribute
.RS
.DS L
"Security_logging": {
}
.DE
A JSON object containing
attributes for diagnostic purposes.
See companion transport documents.
.LP
This Attribute is used for debugging connections,
and MUST NOT be transmitted during normal operations,
as it provides a target for an adversary.
.RE
.sp 2
.ne 10
.Nh 1 User Provisioning Attributes
.LP
.RS
These are externally visible Attributes,
or lists of such Attributes.
.RE
.sp 2
.ne 15
.Nh 2 BR_Access Attribute
.RS
.DS L
"BR_Access": {
   "br_expiration": <number>,
   "br_identity": <string>,
   "br_secret": <string>
}
.DE
.IP "br_expiration <number>  " 17
Time remaining until the ephemeral identity and secret expire
(in seconds).
.IP "br_identity <string>  " 17
64 to 128 bytes:
48 to 96 random bytes,
base64url encoded before transmission.
Upon receipt,
this value is used in calculations as transmitted.
.IP "br_secret <string>  " 17
43 to 86 bytes:
16 to 64 random bytes,
base64url encoded before transmission
and decoded before use in calculations.
.LP
(See example in [ACSCF] section "Bridge Relay List".)
.RE
.sp 2
.ne 15
.Nh 2 BR_Access_List Attribute
.RS
.DS L
"BR_Access_List": [
   "BR_Access",
   ...
]
.DE
A JSON array of one (or more)
BR_Access Attribute(s) indicating the current access parameters.
.RE
.sp 2
.ne 15
.Nh 2 BR_Contact_List Attribute
.RS
.DS L
"BR_Contact_List": [
   {
      "Contact",
      "BR_Access_List"
   },
   ...
]
.DE
A JSON array of one (or more)
JSON object(s) containing:
.IP " * " 3
a Contact Attribute indicating the Bridge Relay.
.IP " * " 3
a BR_Access_List Attribute (array) indicating the current access parameters.
.RE
.sp 2
.ne 15
.Nh 2 BR_Transport_List Attribute
.RS
.DS L
"BR_Transport_List": [
   {
      "Camouflage",
      "Encapsulations",
      "BR_Access_List"
   },
   ...
]
.DE
A JSON array of one (or more)
JSON object(s) containing:
.IP " * " 3
an optional Camouflage Attribute.
.IP " * " 3
an Encapsulations Attribute (array).
.IP " * " 3
a BR_Access_List Attribute (array) indicating the current access parameters.
.RE
.sp 2
.ne 15
.Nh 2 Discovery_Access Attribute
.RS
.DS L
"Discovery_Access": {
   "wait": <number>,
   "window": <number>,
   "passphrase": <string>
}
.DE
.IP "wait <number>  " 17
4 to 300
(seconds).
Redirect wait;
the minimum delay between Initial Contact and Redirect Contact.
The "wait" MUST be less than the "window" value.
See [ACSCF] section "Contact Timing".
.IP "window <number>  " 17
"wait" + 4 to 60
(seconds).
Redirect window;
the maximum delay between Initial Contact and Redirect Contact.
The difference between the "wait" and "window" values
MUST be greater than or equal to 4,
SHOULD be greater than 12,
and SHOULD NOT be greater than 60.
See [ACSCF] section "Contact Timing".
.IP "passphrase <string>  " 17
18 to 29 bytes.
See [ACSCF] section "Contact Passphrase".
.LP
(See additional details in [ACSCF] section "Discovery Provisioning".)
.RE
.sp 2
.ne 15
.Nh 2 Discovery_Access_List Attribute
.RS
.DS L
"Discovery_Access_List": [
  {
     "Discovery_Access",
     "BR_Contact_List"
  },
  ...
]
.DE
A JSON array of one (or more)
JSON object(s) containing:
.IP " * " 3
a Discovery_Access Attribute indicating the current contact parameters.
.IP " * " 3
a BR_Contact_List Attribute indicating the Bridge Relay(s).
.RE
.sp 2
.ne 15
.Nh 2 Discovery_Interval Attribute
.RS
.DS L
"Discovery_Interval": <string>
.DE
.IP "<string>  " 17
3 to 33 bytes:
[ISO 8601:2004] time interval format
as modified by [RFC3339].
Default: 86,400 seconds as "P1D" or "P24H".

A standard date and time indicates
the minimum time before the Gateway starts
listening for an Initial Contact.
When not present,
indicates immediate effect.

The duration range is
360 to 86,400 seconds.
This indicates
the maximum time before the Gateway stops
listening for an Initial Contact.
The minimum is the Discovery_Access maximum.
.LP
The actual elapsed time will be limited by the Discovery_Access "window".
.RE
.sp 2
.ne 15
.Nh 2 Discovery_Provisioning Attribute
.RS
.DS L
"Discovery_Provisioning": {
   "when": <string>,
   "initial": <string>,
   "redirect": <string>,
   "wait": <number>,
   "window": <number>,
   "passphrase": <string>
}
.DE
.IP "when <string>  " 17
Optional.
See Discovery_Interval Attribute.
.IP "initial <string>  " 17
Same as IP_address Attribute.
In the alternative,
same as HTTP_Referer Attribute.
.IP "redirect <string>  " 17
Same as IP_address Attribute.
In the alternative,
same as HTTP_Referer Attribute.
.IP "wait <number>  " 17
See Discovery_Access Attribute.
.IP "window <number>  " 17
See Discovery_Access Attribute.
.IP "passphrase <string>  " 17
See Discovery_Access Attribute.
.LP
Although the named elements correspond to the similar
Discovery_Access
and
Discovery_Interval
Attributes,
nested attributes are not used to avoid human confusion.

(See additional details in [ACSCF] section "Discovery Provisioning".)
.RE
.sp 2
.ne 20
.Nh 1 Gateway Provisioning Details
.LP
.Nh 2 Address Pool Creation
.RS
.DS L
{
   "Transaction_Request"
},
{
   "AP_state": "idle"
},
{
   "IP_blocks"
}
.DE
As a Gateway completes the SSH connection to each APRAdb master and backup,
it sends a Transaction_Request
with the Request field set to "Status",
followed by:
.IP " * " 3
an AP_state Attribute set to "idle".
.IP " * " 3
a JSON array of only one
IP_block Attribute indicates the target IP address or range.
.LP
When the IP address ranges are not contiguous,
the AP_state Attribute sequence is repeated
in another transaction for each IP_block Attribute.

Upon reception,
APRP returns a transaction result:
.IP "Accept (Ack)  "
The IP_block was added to the APRAdb as "ready",
or its APRAdb state was changed from "drain" to "ready".

Changes to the status of the Gateway will be indicated by
subsequent maintenance transactions.
This refreshes a Gateway after restart.
.IP "Modify (Nak)  "
The current APRAdb state is "block".
.LP
No additional Attributes are sent.

When a Gateway with more than one existing SSH connection
switches to another connection,
these messages SHOULD NOT be sent again.

[...]
.RE
.sp 2
.ne 10
.Nh 2 Address Pool Deletion
.RS
.DS L
{
   "Transaction_Request"
},
{
   "AP_state": "unusable"
},
{
   "IP_blocks"
}
.DE
When Gateway control of designated Address Pool IP addresses is revoked
(or upon loss of contact with an IP sub-net router via its tunnel),
it sends a Transaction_Request
with the Request field set to "Status",
followed by:
.IP " * " 3
an AP_state Attribute set to "unusable".
.IP " * " 3
a JSON array of only one
IP_block Attribute indicates the target IP address or range.
.LP
When the IP address ranges are not contiguous,
the AP_state Attribute sequence is repeated
in another transaction for each IP_block Attribute.

Upon reception,
APRP returns a transaction result:
.IP "Accept (Ack)  "
The APRAdb state was changed from "ready" to "drain".

Changes to the status of the Gateway will be indicated by
subsequent maintenance transactions.
.IP "Modify (Nak)  "
The current APRAdb state was "block",
or
the IP_block was missing from the APRAdb.
.LP
No additional Attributes are sent.

Whenever both APRAdb master and backup SSH sessions are closed,
the Gateway will cease responding to contacts
until SSH communication is re-established.

In either case,
the APRAdb indicates the IP_block will "drain"
until a later AP_state "idle"
(see section "Address Pool Creation" above)
restores the IP_block to "ready" state.

[...]
.RE
.sp 2
.ne 10
.Nh 2 Address Pool Maintenance
.LP
.RS
When the APRAdb updates the status of IP addresses on a Gateway,
it sends a Transaction_Request
with the Request field set to "Status",
followed by:
.IP " * " 3
an AP_state Attribute.
.IP " * " 3
a JSON array of one (or more)
IP_block Attribute(s).
The first specified IP_block indicates the target IP address or range.
Any additional members of the array
specify IP address ranges that are allowed access to
the first specified IP_block.
Blocked contacts are silently discarded.
When no additional members are listed,
access is allowed for all IP sources
that are not otherwise specified as unusable.
.LP
The AP_state indicates any additional Attributes
that immediately follow the IP_block array.

When the IP address ranges are not contiguous
or there are multiple status updates
for the same Gateway
combined in the same transaction,
the AP_state Attribute sequence is repeated.

Although described (below) alphabetically,
updates MUST be sent in a specific order to
ensure that Gateways are properly prepared for concurrent contacts:
unusable,
idle,
relay,
redirect,
initial.

Upon reception,
APRP returns a transaction result:
.IP "Accept (Ack)  "
When the Gateway detects no conflicts with existing information,
the specified IP_block(s) are updated.
.IP "Modify (Nak)  "
Otherwise,
the current status of each specified IP_block is indicated
(updates are not applied).
.LP
[...]
.RE
.sp 2
.ne 15
.Nh 3 Address Pool Idle
.RS
.DS L
{
   "Transaction_Request"
},
{
   "AP_state": "idle"
},
{
   "IP_blocks"
}
.DE
Only one IP_block is specified per AP_state.

No additional Attributes.
.RE
.sp 2
.ne 30
.Nh 3 Address Pool Initial Contacts
.RS
.DS L
{
   "Transaction_Request"
},
{
   "AP_state": "initial"
},
{
   "IP_blocks"
},
{
   "Encapsulations"
},
[
   "Contact",
   ...
],
{
   "HTTP_Cookies": [
      "HTTP_Cookie",
      ...
   ],
},
{
   "HTTP_Referers": [
      "HTTP_Referer",
      ...
   ]
}
.DE
The first specified IP_block MUST indicate a single IP_address;
the IP_bits field is zero (0).

Immediately following the IP_block array:
.IP " * " 3
an Encapsulations Attribute (array).
.IP " * " 3
a JSON array of one (or more)
Contact Attribute(s) indicating the matching Redirect Contacts.
.IP " * " 3
a JSON array of one (or more)
HTTP_Cookie Attribute(s) indicating the cookie-name part(s) to be used.
.IP " * " 3
a JSON array of zero (or more)
HTTP_Referer Attribute(s) indicating any expected URL shortener
specific to this IP_address.
When the HTTP_Referers array is empty,
this object SHOULD NOT be transmitted.
.LP
The IP_block(s) MAY serve multiple ports concurrently;
the AP_state Attribute sequence is repeated.
.RE
.sp 2
.ne 35
.Nh 3 Address Pool Redirect Contacts
.RS
.DS L
{
   "Transaction_Request"
},
{
   "AP_state": "redirect"
},
{
   "IP_blocks"
},
{
   "Encapsulations"
},
[
   "Contact",
   ...
],
{
   "HTTP_Cookies": [
      "HTTP_Cookie",
      ...
   ],
},
{
   "HTTP_Referers": [
      "HTTP_Referer",
      ...
   ]
},
"Discovery_Access_List"
.DE
The first specified IP_block MUST indicate a single IP_address;
the IP_bits field is zero (0).

Immediately following the IP_block array:
.IP " * " 3
an Encapsulations Attribute (array).
.IP " * " 3
a JSON array of one (or more)
Contact Attribute(s) indicating the matching Initial Contacts.
.IP " * " 3
a JSON array of one (or more)
HTTP_Cookie Attribute(s) indicating the cookie-name part(s) to be used.
.IP " * " 3
a JSON array of zero (or more)
HTTP_Referer Attribute(s) indicating any expected URL shortener
specific to this IP_address.
When the HTTP_Referers array is empty,
this object SHOULD NOT be transmitted.
.IP " * " 3
a Discovery_Access_List Attribute indicating the designated Bridge Relay(s)
and current access parameters.
.LP
The IP_block(s) MAY serve multiple ports concurrently;
the AP_state Attribute sequence is repeated.
.RE
.sp 2
.ne 20
.Nh 3 Address Pool Relays
.RS
.DS L
{
   "Transaction_Request"
},
{
   "AP_state": "relay"
},
{
   "IP_blocks"
},
"BR_Transport_List"
.DE
The first specified IP_block MUST indicate a single IP_address;
the IP_bits field is zero (0).

Immediately following the IP_block array,
a BR_Transport_List Attribute (array) indicating the contact
and current access parameters.
.LP
The IP_block(s) MAY serve multiple ports concurrently.
.RE
.sp 2
.ne 15
.Nh 3 Address Pool Unusable
.RS
.DS L
{
   "Transaction_Request"
},
{
   "AP_state": "unusable"
},
{
   "IP_blocks"
}
.DE
The first specified IP_block indicates the target IP address or range.
Any additional members of the array
specify IP address ranges that are denied access to
the first specified IP_block.
When no additional members are listed,
access is denied for all IP sources.
(Note this is the inverse of other states.)

No additional Attributes.

This AP_state supercedes all others.
Conflicting information is removed.

The IP_block(s) MAY allow service for other IP address ranges.
.RE
.sp 2
.ne 10
.Nh 1 Discovery Provisioning Details
.RS
.DS L
DUA                    Gateway                APRAdb
==========             =======                ======
(unspecified)       ->
                       Request User        ->
                                          <-  Accept (Ack)
                   <-  (unspecified)
.DE
.RE
.sp 2
.ne 25
.Nh 2 Discovery Request
.RS
.DS L
{
   "Transaction_Request"
},
{
   "Contact_pairing"
},
{
   "Contact_logging"
},
{
   "Discovery_Interval"
},
{
   "AP_state": "unusable"
},
{
   "IP_blocks"
}
.DE
As each Discovery Provisioning process
completes the SSH connection to its APRAdb,
it sends a Transaction_Request
with the Request field set to "User",
followed by:
.IP " * " 3
a Contact_pairing Attribute (array).
.IP " * " 3
a Contact_logging Attribute (object).
.LP
When the Contact_logging Attribute "count" member equals one (1),
followed by:
.IP " * " 3
a Discovery_Interval Attribute.
.IP " * " 3
zero (or more)
JSON object(s) containing:
.RS
.IP " * " 3
an AP_state Attribute set to "unusable".
.IP " * " 3
a JSON array of only one
IP_block Attribute indicates the unusable IP address or range.
.RE

When the IP address ranges are not contiguous,
the AP_state Attribute sequence is repeated.
.LP
The distribution mechanism is expected to involve
proof-of-life and proof-of-work.
Distributing this contact information to users is
beyond the scope of this specification.

The unusable IP address ranges provide feedback
about difficulties with prior contacts,
together with other contact history learned via logging (below).
This user report SHOULD NOT be determinative,
as an adversary with sufficient resources and time
could issue repeated requests
poisoning the IP address space.

Upon reception,
APRP returns a transaction result:
.IP "Accept (Ack)  "
When the APRAdb has no current information about the remote (client) IP_address,
the APRAdb uses the Contact Attributes to
select appropriate initial, redirect, and relays,
and issues initial, redirect, and relay Status updates as needed.
.IP "Modify (Nak)  "
Otherwise,
[...]
.LP
.RE
.Nh 2 Discovery Accept
.RS
.DS L
{
   "Transaction_Accept"
},
"Discovery_Provisioning"
.DE
When the Discovery Provisioning process is successful,
it receives a Transaction_Accept,
followed by:
.IP " * " 3
a Discovery_Provisioning Attribute (object).
.RE
.sp 2
.ne 10
.Nh 1 Contact Details
.LP
.RS
HTTP header fields are in order of document presentation,
but MAY be transmitted in any order to
emulate specific clients and servers.
Additional fields MAY be present.
Many standard fields are omitted for convenience.

This protocol depends upon successful end-to-end transmission of certain fields.
HTTP header fields utilized by this protocol MUST be
passed from the DUA to the [RFC2616] origin server (O)
and vice versa.

Every HTTP request MUST specify [RFC2616] Cache-Control "max-age" of zero (0),
forcing any cache(s) to revalidate all responses.

The Gateway SHOULD return both [RFC2616] Date and Expires header fields.
If present,
the Expires date MUST be equal to the Date header value.
This indicates that the response has "already expired."

The Gateway SHOULD return the [RFC2616] Pragma: no-cache header field.

The Gateway SHOULD return the [RFC2616] Cache-Control header field.
.RE
.sp 2
.ne 20
.Nh 2 Initial Contact
.RS
.DS L
DUA                    Initial                APRAdb
==========             =======                ======
HTTP GET            ->
  Referer*
                   <-  HTTP
                         Set-Cookie+

                       Request Initial     ->
                                          <-  Accept (Ack)
.DE
When the Redirect Contact will be handled by this Gateway
and the current session was initiated
during the wait delay of a previous session
that has not yet made the Redirect Contact,
the contact is ignored
(returns a default response).
The attempt SHOULD be counted or logged
by the Initial Gateway.

In any case,
there is no difference in the Gateway response transmitted to the DUA.
.RE
.sp 2
.ne 10
.Nh 3 Initial Referer
.LP
.RS
If a URL shortener was used,
the HTTP Referer [sic] header field value SHOULD be set to the original URL.
Otherwise,
the Referer is not sent.

When the HTTP Referer header field is received,
but does not match any expected URL shortener,
the contact is ignored
(returns a default response).
The attempt SHOULD be counted or logged
by the Initial Gateway.

In any case,
there is no difference in the Gateway response transmitted to the DUA.
.RE
.sp 2
.ne 10
.Nh 3 Initial Set-Cookie(s)
.LP
.RS
The Gateway MUST transmit one or more [RFC6265] Set-Cookie string(s).
The value(s) is/are
randomly generated for each connection,
and
encoded according the variable format field indicated by the APRAdb.

The cookie-name(s) and cookie-value(s) are saved
by the DUA for the next contact,
but MUST NOT be returned with any HTTP or HTTPS request.
Any other attributes are discarded.
If more than one Set-Cookie is present,
the cookie-names are sorted alphabetically
and the cookie-values are concatenated
(most significant to least significant as transmitted)
before further use in calculations.
.RE
.sp 2
.ne 15
.Nh 2 Initial Logging
.RS
.DS L
{
   "Transaction_Request"
},
{
   "Contact_pairing"
},
{
   "Contact_logging"
},
{
   "HTTP_Cookies": [
      "HTTP_Cookie",
      ...
   ],
},
{
   "HTTP_Referers": [
      "HTTP_Referer",
      ...
   ]
}
.DE
The Gateway sends a Transaction_Request to its APRAdb,
with the Request field set to "Initial",
followed by:
.IP " * " 3
a Contact_pairing Attribute (array).
.IP " * " 3
a Contact_logging Attribute (object).
.LP
When the Contact_logging Attribute "count" member equals one (1),
followed by:
.IP " * " 3
a JSON array of one (or more)
HTTP_Cookie Attribute(s) indicating the token (cookie) sent.
.IP " * " 3
a JSON array of zero or one
HTTP_Referer Attribute indicating
the HTTP Referer header field was present.
When the HTTP_Referers array is empty,
this object SHOULD NOT be transmitted.
.LP
This transaction is handled in parallel with
the Initial Contact response.
.RE
.sp 2
.ne 20
.Nh 2 Initial-Redirect Update
.RS
.DS L
                       Redirect               APRAdb
                       ========               ======
                                          <-  Request Initial
                       Accept (Ack)        ->
.DE
When the Redirect Contact will be handled by another Gateway,
the APRAdb sends a Transaction_Request to the Redirect Gateway
with the Request field set to "Initial",
followed by
the Initial Logging message (above).

On reception,
APRP returns a transaction result:
.IP "Accept (Ack)  "
The session is authorized.
The Redirect Gateway retains
Cookie values for the next contact.
.IP "Modify (Nak)  "
The current session was initiated
during the wait delay of a previous session
that has not yet made the Redirect Contact.
The contact is ignored
(returns a default response).
The attempt SHOULD be counted or logged
by the APRAdb.
.LP
This transaction is subsequent to
the Initial Contact response.
The "wait" and "window" delays MUST permit ample time for the update.

.Sh
Design Considerations:
.RS
When both Initial Contact and Redirect Contact
are assigned to the same Gateway,
any ordered pairing is possible.
In this case,
there MAY be fewer Initial Contact IP address assignments
than Redirect Contact IP address assignments.
A smaller number of users need be assigned the same pair,
and the verification search will be shorter.

When assigned to different Gateways,
this design requires a direct relationship between contacts.
As there are fewer possible pairs,
a larger number of users will be assigned the same pair,
and the verification search will be longer.

To eliminate duplicate update messages to different Gateways,
there MUST NOT be fewer Initial Contact IP address assignments
than Redirect Contact IP address assignments.
There MAY be additional Initial Contact IP address assignments.
.RE
.RE
.sp 2
.ne 20
.Nh 2 Redirect Contact
.RS
.DS L
DUA                    Redirect               APRAdb
==========             ========               ======
HTTP GET            ->
  Referer*
                   <-  HTTP
                         Set-Cookie+
                         bridge relay(s)+
                           Camouflage*
                           Contact
                           br_expiration
                           br_identity
                           br_secret

                       Request Redirect    ->
                                          <-  Accept (Ack)
.DE
The Redirect session is delayed
for a random amount of time
between the "wait" and "window" parameters.
Although the randomization range is specified in units of seconds,
the actual randomly-chosen value SHOULD NOT be in units of whole seconds,
but rather in units of the highest available timer resolution.

When the handshake is successful,
the Gateway selects Bridge Relays
and chooses associated unallocated BR_Access parameters
with the shortest remaining expiration.
It sends these to the DUA.
.RE
.sp 2
.ne 10
.Nh 3 Redirect Referer
.LP
.RS
If a URL shortener was used,
the HTTP Referer [sic] header field value SHOULD be set to the original URL.
Otherwise,
the Referer is not sent.

When the HTTP Referer header field is received,
but does not match any expected URL shortener,
the contact is ignored
(returns a default response).
The attempt SHOULD be counted or logged
by the Redirect Gateway.

In any case,
there is no difference in the Gateway response transmitted to the DUA.
.RE
.sp 2
.ne 30
.Nh 2 Redirect Logging
.RS
.DS L
{
   "Transaction_Request"
},
{
   "Contact_pairing"
},
{
   "Contact_logging"
},
{
   "HTTP_Cookies": [
      "HTTP_Cookie",
      ...
   ],
},
{
   "HTTP_Referers": [
      "HTTP_Referer",
      ...
   ]
},
{
   "Discovery_Access"
},
{
   "Security_logging"
}
.DE
The Gateway sends a Transaction_Request to its APRAdb,
with the Request field set to "Redirect",
followed by:
.IP " * " 3
a Contact_pairing Attribute (array).
.IP " * " 3
a Contact_logging Attribute (object).
.LP
When the Contact_logging Attribute "count" member equals one (1),
followed by:
.IP " * " 3
a JSON array of one (or more)
HTTP_Cookie Attribute(s) indicating the token (cookie) sent.
.IP " * " 3
a JSON array of zero, one, or two
HTTP_Referer Attribute(s) seen.
When the HTTP_Referers array is empty,
this object SHOULD NOT be transmitted.
.IP " * " 3
a Discovery_Access Attribute matching the prior provisioning.
.IP " * " 3
a Security_logging Attribute for diagnostic purposes
(omitted during normal operations).
.LP
Upon reception,
the APRAdb SHOULD generate replacement BR_Access parameters for future contacts,
and update any associated Bridge Relay(s)
prior to this Redirect Gateway.
This permits multiple users to share the same Discovery Provisioning
without sharing the same identities and secrets.

This transaction is handled in parallel with
the Redirect Contact response.
.RE
.sp 2
.ne 10
.Nh 2 Bridge Relay(s)
.RS
.DS L
DUA                    Relay(s)               APRAdb
==========             ========               ======
HTTP GET            ->
                   <-  HTTP

                       Request Relay       ->
                                          <-  Accept (Ack)
.DE
[...]

When the former session identifier is not recognized,
the Gateway will continue the handshake
with a new session identifier,
but ultimately reject this session.

When the session is authorized,
the Gateway will continue the handshake
with a new session identifier.

[...]
.RE
.sp 2
.ne 20
.Nh 2 Bridge Relay Logging
.RS
.DS L
{
   "Transaction_Request"
},
{
   "Contact_pairing"
},
{
   "Contact_logging"
},
{
   "BR_Access"
},
{
   "Security_logging"
}
.DE
The Gateway sends a Transaction_Request to its APRAdb,
with the Request field set to "Relay",
followed by:
.IP " * " 3
a Contact_pairing Attribute (array).
.IP " * " 3
a Contact_logging Attribute (object).
.LP
When the Contact_logging Attribute "count" member equals one (1),
followed by:
.IP " * " 3
a BR_Access Attribute matching the prior provisioning.
.IP " * " 3
a Security_logging Attribute for diagnostic purposes
(omitted during normal operations).
.LP
This transaction is handled in parallel with
the Bridge Relay response.
.RE
.sp 2
.ne 20
.Nh 1 Open issues
.LP
.RS
This document is preliminary,
and "[...]" indicates areas to be updated based on implementation experience.

In most cases,
these issues involve error recovery.
Originally,
the specification anticipated a very small number of implementers,
and unexpected responses would be rare.
Problems could be handled manually,
and systems restarted at any time.

As the number of implementers and operators has expanded,
these "[...]" indicate potential incompatibility that might need explication.

.Sh
Address Pool Creation
.LP
.RS
Problem:
the backup might connect before the master,
and these messages will start with the backup.
But the master is preferred,
and subsequent requests could be sent to the master.
Any outstanding responses MUST be matched
on the now idle backup connection.

Originally,
this was not an issue,
as the entire creation sequence was idempotent
in a single request and response.
But that was precluded by the implemented database.

Solution:
each message is already designed to be idempotent.
Responses MUST NOT be sent until both master and backup
have confirmed the database commit.

Problem:
the SQL doesn't check across multiple Gateways.
Misconfiguration or reconfiguration
could assign the same block to another Gateway.

Solution:
This is not yet handled.
.RE

.Sh
Address Pool Deletion
.LP
.RS
This feature is new,
and the [...] was added as a matter of course.

The latter paragraphs have not been implemented.
.RE

.Sh
Address Pool Maintenance
.LP
.RS
Handling problems and/or failures is not specified.
.RE

.Sh
Discovery Request
.LP
.RS
Handling problems and/or failures is not specified.
.RE

.Sh
Redirect Contact
.LP
.RS
Selecting relays is not well specified.

Interactions with stegotorus are unresolved.
.RE

.Sh
Bridge Relay(s)
.LP
.RS
A considerable amount of detail is missing.
Although the protocol itself is well defined,
the actual processing decisions for relaying are unknown,
especially with regard to stegotorus.

Chaffing and winnowing are not specified.
.RE
.RE
.sp 2
.ne 15
.XX ACKNOWLEDGMENTS
Acknowledgments
.LP
.RS
George Kadianakis
suggested that APRP messages
between the APRAdb and Gateways
be handled in parallel with traffic
between the Gateways and DUA
to inhibit traffic analysis
of differences in response timing.

Jeroen Massar
raised additional concerns about DoS and DDos attacks.
.RE
.sp 2
.ne 15
.XX DESIGN CONSIDERATIONS
Design Considerations
.LP
.RS
The first specification of this protocol
consisted of standard type-length-value binary construction.
The transaction requests and responses are simple remote procedure calls,
and the semantics were based on widespread Internet practices.

The second specification reconstructed the messages utilizing
the full-fledged [RFC4627] JSON syntax.
The given rationale is not all applications would be able to handle binary;
thus a textual serialization would be more universal.
This was based on the premise that extant JSON parsers
correctly handled the JSON syntax.
Investigation showed this to be false.

The third specification restructured the messages,
flattening the protocol into an ordered stream
more like the original specification.
.IP
The stream has no JSON (array or object) container.
Message syntax can be checked by adding the (virtual array) implied "[" and "]".
.IP
Transaction elements consist of an object with only a single member,
where the label unambiguously identifies the element.
.IP
Optional object members were eliminated
by sending them only in the outer (virtual array) stream.
.IP
Arrays of different elements were eliminated
by sending them only in the outer (virtual array) stream.
.LP
These semantics retain the underlying JSON LL(1) or LR(1) grammar,
while hopefully compatible with general JSON libraries.
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
[...]
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

Logging messages provide feedback about contact history for each IP address.
This aids in automatically determining blocked IP addresses.

Under normal circumstances,
logging messages are limited by the "wait" and "window" delays.
During a Denial of Service (DoS) attack,
subsequent logging messages will be held for at least one (1) second,
and the count and hold time delay is provided instead.
During a Distributed Denial of Service (DDoS) attack,
these messages are only reduced by the number of attacking systems.
.RE
.sp 2
.ne 25
.XX NORMATIVE REFERENCES
Normative References
.RS
.LP
.IP "[ISO 8601:2004]  " 12
"Data elements and interchange formats --
Information interchange --
Representation of dates and times",
ISO 8601:2004,
International Organization for Standardization,
December 2004.
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
.IP "[RFC3339]  " 12
Klyne G.
and
C. Newman,
"Date and Time on the Internet: Timestamps",
RFC 3339,
July 2002.
.IP "[RFC3986]  " 12
Berners-Lee, T.,
Fielding, R.,
and
L. Masinter,
"Uniform Resource Identifier (URI): Generic Syntax"
STD 66,
RFC 3986,
January 2005.
.IP "[RFC4251]  " 12
Ylonen, T.
and
C. Lonvick, Ed.,
"The Secure Shell (SSH) Protocol Architecture",
RFC 4251,
January 2006.
.IP "[RFC4627]  " 12
Crockford, D.,
"The application/json Media Type for JavaScript Object Notation (JSON)",
RFC 4627,
July 2006.
.IP "[RFC4648]  " 12
Josefsson, S.,
"The Base16,
Base32,
and Base64 Data Encodings",
RFC 4648,
October 2006.
.IP "[RFC6265]  " 12
Barth, A.,
"HTTP State Management Mechanism",
RFC 6265,
April 2011.
.IP "[ACSCF]  " 12
Simpson, W.,
and
P. Vixie,
"Defiance Address-Change Signaling -
Concepts and Facilities",
work in progress,
draft-simpson-acscf-2013May04
.RE
.sp 2
.ne 10
.XX INFORMATIVE REFERENCES
Informative References
.RS
.IP "[RFC5952]  " 12
Kawamura, S.,
and
M. Kawashima,
"A Recommendation for IPv6 Address Text Representation",
August 2010.
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
