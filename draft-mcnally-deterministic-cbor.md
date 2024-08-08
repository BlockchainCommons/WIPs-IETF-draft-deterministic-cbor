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

venue:
#  group: "CBOR Maintenance and Extensions"
#  mail: "cbor@ietf.org"
  github: BlockchainCommons/WIPs-IETF-draft-deterministic-cbor

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
 -
    name: Laurence Lundblade
    organization: Security Theory LLC
    email: lgl@securitytheory.com

normative:
    RFC8949: CBOR
    RFC8610: CDDL
    CDE: I-D.draft-ietf-cbor-cde
    IANACDDL: IANA.cddl
    IANACBORTAGS: IANA.cbor-tags
    UNICODE-NORM:
        title: "Unicode Normalization Forms"
        target: https://unicode.org/reports/tr15/

informative:
    BCSwiftDCBOR:
        author:
            name: Wolf McNally
        title: "Deterministic CBOR (dCBOR) for Swift."
        target: https://github.com/BlockchainCommons/BCSwiftDCBOR
    BCRustDCBOR:
        author:
            name: Wolf McNally
        title: "Deterministic CBOR (dCBOR) for Rust."
        target: https://github.com/BlockchainCommons/bc-dcbor-rust
    BCTypescriptDCBOR:
        author:
            name: Wolf McNally
        title: "Deterministic CBOR (dCBOR) for Typescript."
        target: https://github.com/BlockchainCommons/bc-dcbor-ts
    GordianEnvelope: I-D.mcnally-envelope
    cbor-deterministic:
        author:
            name: Carsten Bormann
        title: "cbor-deterministic gem"
        target: https://github.com/cabo/cbor-deterministic
    cbor-diag:
        author:
            name: Carsten Bormann
        title: "CBOR diagnostic utilities"
        target: https://github.com/cabo/cbor-diag
    cbor-dcbor:
        author:
            name: Carsten Bormann
        title: "PoC of the McNally/Allen dCBOR application-level CBOR representation rules"
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

## Numeric Reduction

The purpose of determinism is to ensure that semantically equivalent data items are encoded into identical byte streams. Numeric reduction ensures that semantically equal numeric values (e.g. `2` and `2.0`) are encoded into identical byte streams (e.g. `0x02`) by encoding "Integral floating point values" (floating point values with a zero fractional part) as integers when possible.

dCBOR implementations that support floating point numbers:

1. MUST check whether floating point values to be encoded have the numerically equal value in `DCBOR_INT` = \[-2<sup>63</sup>, 2<sup>64</sup>-1\]. If that is the case, it MUST be converted to that numerically equal integer value before encoding it. (Preferred encoding will then ensure the shortest length encoding is used.) If a floating point value has a non-zero fractional part, or an exponent that takes it out of `DCBOR_INT`, the original floating point value is used for encoding. (Specifically, conversion to a CBOR bignum is never considered.)

   This also means that the three representations of a zero number in CBOR (`0`, `0.0`, `-0.0` in diagnostic notation) are all reduced to the basic integer `0` (with preferred encoding `0x00`).

{:aside}
> Note that numeric reduction means that some maps that are valid CDE/CBOR cannot be reduced to valid dCBOR maps, as numeric reduction can result in multiple entries with the same keys ("duplicate keys"). For example, the following is a valid CBOR/CDE map:
>
> ~~~ cbor-diag
> {
>    10: "ten",
>    10.0: "floating ten"
> }
> ~~~
> {: title="Valid CBOR data item with numeric map keys (also valid CDE)"}
>
> Applying numeric reduction to this map would yield the invalid map:
>
> ~~~ cbor-diag
> {  / invalid: multiple entries with the same key /
>    10: "ten",
>    10: "floating ten"
> }
> ~~~
> {: title="Numeric reduction turns valid CBOR invalid"}
>
> In general, dCBOR applications need to avoid maps that have entries with keys that are semantically equivalent in dCBOR's numeric model.


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

## Strings

dCBOR encoders:

1. MUST only emit text strings that are in Unicode Normalization Form C (NFC) {{UNICODE-NORM}}.

dCBOR decoders:

2. MUST reject any encoded text strings that are not in NFC.

# CDDL support, Declarative Tag

Similar to the CDDL {{-CDDL}} support in CDE {{CDE}}, this specification adds two CDDL control operators that can be used to specify that the data items should be encoded in CBOR Common Deterministic Encoding (CDE), with the dCBOR application profile applied as well.

The control operators `.dcbor` and `.dcborseq` are exactly like `.cde` and `.cdeseq` except that they also require the encoded data item(s) to conform to the dCBOR application profile.

Tag 201 ({{tag201}}) is defined in this specification as a way to declare its tag
content to conform to the dCBOR application profile at the data model level.
As a result, when this data item is encoded using CDE rules, the encoded
result will conform to dCBOR also at the encoded data item level.
(In conjunction with this semantics, tag 201 may also be employed as a
boundary marker leading from an overall structure to specific
application data items; see {{Section 3 of GordianEnvelope}} for an
example for this usage.)

# Implementation Status
{:removeinrfc}
{::boilerplate rfc7942info}

## Swift

- Description: Single-purpose dCBOR reference implementation for Swift.
- Organization: Blockchain Commons
- Implementation Location: {{BCSwiftDCBOR}}
- Primary Maintainer: Wolf McNally
- Languages: Swift
- Coverage: Complete
- Testing: Unit tests
- Licensing: BSD-2-Clause-Patent

## Rust

- Description: Single-purpose dCBOR reference implementation for Rust.
- Organization: Blockchain Commons
- Implementation Location: {{BCRustDCBOR}}
- Primary Maintainer: Wolf McNally
- Languages: Rust
- Coverage: Complete
- Testing: Unit tests
- Licensing: BSD-2-Clause-Patent

## TypeScript

- Description: Single-purpose dCBOR reference implementation for TypeScript.
- Organization: Blockchain Commons
- Implementation Location: {{BCTypescriptDCBOR}}
- Primary Maintainer: Wolf McNally
- Languages: TypeScript (transpiles to JavaScript)
- Coverage: Complete
- Testing: Unit tests
- Licensing: BSD-2-Clause-Patent

## Ruby

- Implementation Location: [cbor-dcbor]
- Primary Maintainer: Carsten Bormann
- Languages: Ruby
- Coverage: Complete specification; complemented by CBOR encoder/decoder and command line interface from [cbor-diag] and deterministic encoding from [cbor-deterministic]. Checking of dCBOR - exclusions not yet implemented.
- Testing: Also available at https://cbor.me
- Licensing: Apache-2.0

# Security Considerations

This document inherits the security considerations of CBOR {{-CBOR}}.

Vulnerabilities regarding dCBOR will revolve around whether an attacker can find value in producing semantically equivalent documents that are nonetheless serialized into non-identical byte streams. Such documents could be used to contain malicious payloads or exfiltrate sensitive data. The ability to create such documents could indicate the failure of a dCBOR decoder to correctly validate according to this document, or the failure of the developer to properly specify or implement application protocol requirements using dCBOR. Whether these possibilities present an identifiable attack surface is a question that developers should consider.

# IANA Considerations {#tag201}

RFC Editor: please replace RFCXXXX with the RFC number of this RFC and remove this note.

IANA has registered the following CBOR tag in the "CBOR Tags" registry of {{IANACBORTAGS}}:

| Tag | Data Item | Semantics | Reference |
|:----|:----------|:----------|:----------|
| #201 | (any) | enclosed dCBOR | \[RFCXXXX\] |
{: title="CBOR Tag for dCBOR"}

This document requests IANA to register the contents of Table 1 into the registry "CDDL Control Operators" of {{IANACDDL}}:

| Name       | Reference |
|:-----------|:----------|
| .dcbor     | \[RFCXXXX\] |
| .dcborseq  | \[RFCXXXX\] |
{: title="CDDL Control Operators for dCBOR"}

# Appendix A: dCBOR Numeric Test Vectors

The following tables provide common and edge-case numeric test vectors for dCBOR encoders and decoders, and are intended to exercise the requirements of this specification.

## dCBOR Numeric Encodings

| Value | dCBOR Encoding | Note |
|:------|:---------------|:-----|
| 0 | `00` | |
| 1 | `01` | |
| 23 | `17` | |
| 24 | `1818` | |
| 255 (2<sup>8</sup> – 1) | `18ff` | |
| 65535 (2<sup>16</sup> – 1) | `19ffff` | |
| 65536 (2<sup>16</sup>) | `1a00010000` | |
| 4294967295 (2<sup>32</sup> – 1) | `1affffffff` | |
| 4294967296 (2<sup>32</sup>) | `1b0000000100000000` | |
| 18446744073709551615 (2<sup>64</sup> – 1) | `1bffffffffffffffff` | |
| -1 | `20` | |
| -2 | `21` | |
| -127 (–2<sup>8</sup> – 1) | `387e` | |
| -128 (–2<sup>7</sup>) | `387f` | |
| -32768 (–2<sup>16</sup>) | `397fff` | |
| -2147483648 (–2<sup>31</sup>) | `3a7fffffff` | |
| -9223372036854775808  (–2<sup>63</sup>) | `3b7fffffffffffffff` | |
| 1.5 | `f93e00` | |
| 2345678.25 | `fa4a0f2b39` | |
| 1.2 | `fb3ff3333333333333` | |
| 42.0 | `182a` | Reduced. |
| 2345678.0 | `1a0023cace` | Reduced. |
| -2345678.0 | `3a0023cacd` | Reduced. |
| -0.0 | `00` | Reduced. |
| 5.960464477539063e-08 | `f90001` | Smallest half-precision subnormal. |
| 1.401298464324817e-45 | `fa00000001` | Smallest single subnormal. |
| 5e-324 | `fb0000000000000001` | Smallest double subnormal. |
| 2.2250738585072014e-308 | `fb0010000000000000` | Smallest double normal. |
| 6.103515625e-05 | `f90400` | Smallest half-precision normal. |
| 65504.0 | `19ffe0` | Reduced. Largest possible half-precision. |
| 33554430.0 | `1a01fffffe` | Reduced. Exponent 24 to test single exponent boundary. |
| -9223372036854774784.0 | `3b7ffffffffffffbff` | Reduced. Most negative double that converts to int64. |
| 18446744073709550000.0 | `1bfffffffffffff800` | Reduced. Largest double that can convert to uint64, almost UINT64_MAX. |
| 18446744073709552000.0 | `fa5f800000` | Just too large to convert to uint64, but converts to a single, just over UINT64_MAX. |
| -18446742974197924000.0 | `fadf7fffff` | Large negative that converts to float, but too large for int64. |
| 3.4028234663852886e+38 | `fa7f7fffff` | Largest possible single. |
| 3.402823466385289e+38 | `fb47efffffe0000001` | Slightly larger than largest possible single. |
| 1.7976931348623157e+308 | `fb7fefffffffffffff` | Largest double. |
| Infinity (any size) | `f97c00` | Canonicalized. |
| -Infinity (any size) | `f9fc00` | Canonicalized. |
| NaN (any size, any payload) | `f97e00` | Canonicalized. |

## Invalid dCBOR Encodings

These are valid CBOR encodings that MUST be rejected as invalid by a dCBOR-compliant decoder.

| Value | CBOR Encoding | Reason for Rejection |
|:------|:-----|:-------|
| 12.0 | `f94a00` | Can be reduced to 12. |
| 1.5 | `fb3ff8000000000000` | Not preferred encoding. |
| -9223372036854775809 (-2<sup>63</sup> – 1) | `3b8000000000000000` | 65-bit negative integer value. |
| -18446744073709551616 (-2<sup>64</sup>) | `3bffffffffffffffff` | 65-bit negative integer value. |
| Infinity | `fb7ff0000000000000` | Not preferred encoding. |
| Infinity | `fa7f800000` | Not preferred encoding. |
| -Infinity | `fbfff0000000000000` | Not preferred encoding. |
| -Infinity | `faff800000` | Not preferred encoding. |
| NaN | `fb7ff9100000000001` | Not canonical NaN. |
| NaN | `faffc00001` | Not canonical NaN. |
| NaN | `f97e01` | Not canonical NaN. |

--- back

# Acknowledgments
{:numbered="false"}

The authors are grateful for the contributions of Joe Hildebrand and Anders Rundgren in the CBOR working group.
