---
v: 3

title: "dCBOR: A Deterministic CBOR Application Profile"
abbrev: "dCBOR"
docname: draft-mcnally-deterministic-cbor-latest
category: exp
stream: IETF

ipr: trust200902
area: Applications and Real-Time
workgroup: Network Working Group
keyword: Internet-Draft

pi: [toc, sortrefs, symrefs]

author:
 -
    name: Wolf McNally
    organization: Blockchain Commons
    email: wolf@wolfmcnally.com
 -
    name: Christopher Allen
    organization: Blockchain Commons
    email: christophera@lifewithalacrity.com
 -
    name: Carsten Bormann
    organization: Universität Bremen TZI
    email: cabo@tzi.org

normative:
    RFC8949: CBOR
    RFC8610: CDDL
    CDE:
        title: "Bormann, C., \"CBOR Common Deterministic Encoding (CDE)\""
        target: https://datatracker.ietf.org/doc/draft-ietf-cbor-cde/
    IANACDDL:
        title: "Concise Data Definition Language (CDDL)"
        target: https://www.iana.org/assignments/cddl

informative:
    BCSwiftDCBOR:
        title: "McNally, W., \"Deterministic CBOR (dCBOR) for Swift.\""
        target: https://github.com/BlockchainCommons/BCSwiftDCBOR
    BCRustDCBOR:
        title: "McNally, W., \"Deterministic CBOR (dCBOR) for Rust.\""
        target: https://github.com/BlockchainCommons/bc-dcbor-rust
    BCTypescriptDCBOR:
        title: "McNally, W., \"Deterministic CBOR (dCBOR) for Typescript.\""
        target: https://github.com/BlockchainCommons/bc-dcbor-ts
    GordianEnvelope:
        title: "McNally, W., \"Gordian Envelope\""
        target: https://www.ietf.org/archive/id/draft-mcnally-envelope-05.html
    cbor-deterministic:
        title: "Bormann, C., \"cbor-deterministic gem\""
        target: https://github.com/cabo/cbor-deterministic
    cbor-diag:
        title: "Bormann, C., \"CBOR diagnostic utilities\""
        target: https://github.com/cabo/cbor-diag
    cbor-dcbor:
        title: "Bormann, C., \"PoC of the McNally/Allen dCBOR application-level CBOR representation rules\""
        target: https://github.com/cabo/cbor-dcbor

--- abstract

The purpose of determinism is to ensure that semantically equivalent data items are encoded into identical byte streams. CBOR (RFC 8949) defines "Deterministically Encoded CBOR" in its Section 4.2, but leaves some important choices up to the application developer. The CBOR Common Deterministic Encoding (CDE) Internet Draft builds on this by specifying a baseline for application profiles that wish to implement deterministic encoding with CBOR. The present document provides an application profile "dCBOR" that can be used to help achieve interoperable deterministic encoding based on CDE for a variety of applications wishing an even narrower and clearly defined set of choices.

--- middle

# Introduction

CBOR {{-CBOR}} has many advantages over other data serialization formats. One of its strengths is specifications and guidelines for serializing data deterministically, such that multiple agents serializing the same data automatically achieve consensus on the exact byte-level form of that serialized data. This is particularly useful when data must be compared for semantic equivalence by comparing the hash of its contents.

Nonetheless, determinism is an opt-in feature of CBOR, and most existing CBOR codecs put the primary burden of correct deterministic serialization and validation of deterministic encoding during deserialization on the engineer. Furthermore, the specification leaves a number of important decisions around determinism up to the application developer. The CBOR Common Deterministic Encoding (CDE) Internet Draft {{CDE}} builds on the basic CBOR specification by providing a baseline for application profiles that wish to implement deterministic encoding with CBOR.

This document narrows CDE further into a set of requirements for the application profile "dCBOR". These requirements include but go beyond CDE, including requiring that dCBOR decoders validate that encoded CDE conforms to the requirements of this document.

## Conventions and Definitions

{::boilerplate bcp14-tagged}

# Application Profile

The dCBOR Application Profile specifies the use of Deterministic Encoding as defined in {{CDE}} and adds several exclusions and reductions specified in this section.

Just as CDE does not "fork" CBOR, the rules specified here do not "fork" CDE: A dCBOR implementation produces well-formed, deterministically encoded CDE according to {{CDE}}, and existing CBOR or CDE decoders will therefore be able to decode it. Similarly, CBOR or CDE encoders will be able to produce valid dCBOR if handed dCBOR conforming data model level information from an application.

Note that the separation between standard CBOR or CDE processing and the processing required by the dCBOR application profile is a conceptual one: Both dCBOR processing and standard CDE/CBOR processing may be combined into a unified dCBOR/CDE/CBOR codec. The requirements in this document apply to encoding or decoding of dCBOR data, regardless of whether the codec is a unified dCBOR/CDE/CBOR codec operating in dCBOR-compliant modes, or a single-purpose dCBOR codec. Both of these are generically referred to as "dCBOR codecs" in this document.

This application profile is intended to be used in conjunction with an application, which typically will use a subset of CDE/CBOR, which in turn influences which subset of the application profile is used. As a result, this application profile places no direct requirement on what subset of CDE/CBOR is implemented. For instance, there is no requirement that dCBOR implementations support floating point numbers (or any other kind of non-basic integer type, such as arbitrary precision integers or complex numbers) when they are used with applications that do not use them. However, this document does place requirements on dCBOR implementations that support negative 64-bit integers and 64-bit or smaller floating point numbers.

## Common Deterministic Encoding Conformance

dCBOR encoders:

1. MUST only emit CBOR conforming "CBOR Common Deterministic Encoding (CDE)" {{CDE}}, including mandated preferred encoding of integers and floating point numbers and the lexicographic ordering of map keys.

dCBOR decoders:

2. MUST validate that encoded CBOR conforms to the requirements of {{CDE}}.
{:start="2"}

## Duplicate Map Keys

CBOR {{-CBOR}} defines maps with duplicate keys as invalid, but leaves how to handle such cases to the implementor (§2.2, §3.1, §5.4, §5.6). {{CDE}} provides no additional mandates on this issue.

dCBOR encoders:

1. MUST NOT emit CBOR maps that contain duplicate keys.

dCBOR decoders:

2. MUST reject encoded maps with duplicate keys.
{:start="2"}

## 65-bit Negative Integers

dCBOR limits the valid encodings of integers to those that can be contained in a 64-bit machine register, either as a signed (int64) or unsigned (uint64) integer. This includes values in the range `DCBOR_INT` = \[-2<sup>63</sup>, 2<sup>64</sup>-1\]. As always with CBOR, whether the value is interpreted as non-negative or negative depends on whether it is encoded as a major type 0 or 1 value.

CBOR integers in the range `NEG_65` = \[-2<sup>64</sup>, -2<sup>63</sup> - 1\] require 65 bits of precision, and are thus not representable in typical machine-sized integers. `NEG_65` major type 1 values are invalid in dCBOR.

dCBOR encoders:

1. MUST NOT encode major type 1 CBOR values in `NEG_65`.

dCBOR decoders:

2. MUST reject major type 1 CBOR values in `NEG_65`.
{:start="2"}

Specific applications will, of course, further restrict ranges of integers that are considered valid for the application, based on their position and semantics in the CBOR data item.

## Numeric Reduction

The purpose of determinism is to ensure that semantically equivalent data items are encoded into identical byte streams. Numeric reduction ensures that semantically equal numeric values (e.g. `2` and `2.0`) are encoded into identical byte streams (e.g. `0x02`) by encoding "Integral floating point values" (floating point values with a zero fractional part) as integers when possible.

dCBOR implementations that support floating point numbers:

1. MUST check whether floating point values to be encoded have the numerically equal value in `DCBOR_INT` as defined above. If that is the case, it MUST be converted to that numerically equal integer value before encoding it. (Preferred encoding will then ensure the shortest length encoding is used.) If a floating point value has a non-zero fractional part, or an exponent that takes it out of `DCBOR_INT`, the original floating point value is used for encoding. (Specifically, conversion to a CBOR bignum is never considered.)

This also means that the three representations of a zero number in CBOR (`0`, `0.0`, `-0.0` in diagnostic notation) are all reduced to the basic integer `0` (with preferred encoding `0x00`).

Note that this reduction means some valid CDE/CBOR maps are not valid dCBOR maps, as numeric reduction can result in duplicate keys, for example, this is an invalid dCBOR map:

~~~ cbor-diag
{
   10: "ten",
   10.0: "floating ten"
}
~~~

2. MUST reduce all encoded NaN values to the quiet NaN value having the half-width CBOR representation `0xf97e00`.
{:start="2"}

dCBOR decoders that support floating point numbers:

3. MUST reject any encoded floating point values that are not encoded according to the above rules.
{:start="3"}

## Simple Values

Only the three "simple" (major type 7) values `false` (0xf4), `true` (0xf5), and `null` (0xf6) and the floating point values are valid in dCBOR.

dCBOR encoders:

1. MUST NOT encode major type 7 values other than `false`, `true`, `null`, and the floating point values.

dCBOR decoders:

2. MUST reject any encoded major type 7 values other than `false`, `true`, `null`, and the floating point values.
{:start="2"}

# CDDL support

Similar to the CDDL {{-CDDL}} support in CDE {{CDE}}, this specification adds two CDDL control operators that can be used to specify that the data items should be encoded in CBOR Common Deterministic Encoding (CDE), with the dCBOR application profile applied as well.

The control operators `.dcbor` and `.dcborseq` are exactly like `.cde` and `.cdeseq` except that they also require the encoded data item(s) to conform to the dCBOR application profile.

For example, the normative comment in Section 3 of {{GordianEnvelope}}:

~~~ cddl
leaf = #6.24(bytes)  ; MUST be dCBOR
~~~

...can now be formalized as:

~~~ cddl
leaf = #6.24(bytes .dcbor any)
~~~

# Reference Implementations
{:removeinrfc}
{::boilerplate rfc7942info}

## Gordian dCBOR Application Profile

### Swift

- Description: Single-purpose dCBOR reference implementation for Swift.
- Organization: Blockchain Commons
- Implementation Location: {{BCSwiftDCBOR}}
- Primary Maintainer: Wolf McNally
- Languages: Swift
- Coverage: Complete
- Testing: Unit tests
- Licensing: BSD-2-Clause-Patent

### Rust

- Description: Single-purpose dCBOR reference implementation for Rust.
- Organization: Blockchain Commons
- Implementation Location: {{BCRustDCBOR}}
- Primary Maintainer: Wolf McNally
- Languages: Rust
- Coverage: Complete
- Testing: Unit tests
- Licensing: BSD-2-Clause-Patent

### TypeScript

- Description: Single-purpose dCBOR reference implementation for TypeScript.
- Organization: Blockchain Commons
- Implementation Location: {{BCTypescriptDCBOR}}
- Primary Maintainer: Wolf McNally
- Languages: TypeScript (transpiles to JavaScript)
- Coverage: Complete
- Testing: Unit tests
- Licensing: BSD-2-Clause-Patent

### Ruby

- Implementation Location: [cbor-dcbor]
- Primary Maintainer: Carsten Bormann
- Languages: Ruby
- Coverage: Complete specification; complemented by CBOR encoder/decoder and command line interface from [cbor-diag] and deterministic encoding from [cbor-deterministic]. Checking of dCBOR - exclusions not yet implemented.
- Testing: Also available at https://cbor.me
- Licensing: Apache-2.0

# Security Considerations

This document inherits the security considerations of CBOR {{-CBOR}}.

Vulnerabilities regarding dCBOR will revolve around whether an attacker can find value in producing semantically equivalent documents that are nonetheless serialized into non-identical byte streams. Such documents could be used to contain malicious payloads or exfiltrate sensitive data. The ability to create such documents could indicate the failure of a dCBOR decoder to correctly validate according to this document, or the failure of the developer to properly specify or implement application protocol requirements using dCBOR. Whether these possibilities present an identifiable attack surface is a question that developers should consider.

# IANA Considerations

RFC Editor: please replace RFCXXXX with the RFC number of this RFC and remove this note.

This document requests IANA to register the contents of Table 1 into the registry "CDDL Control Operators" of {{IANACDDL}}:

| Name       | Reference |
|:-----------|:----------|
| .dcbor     | \[RFCXXXX\] |
| .dcborseq  | \[RFCXXXX\] |

--- back

# Acknowledgments
{:numbered="false"}

The authors are grateful for the contributions of Joe Hildebrand, Laurence Lundblade, and Anders Rundgren in the CBOR working group.
