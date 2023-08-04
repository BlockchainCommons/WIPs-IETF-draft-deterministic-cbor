---
title: "Gordian dCBOR: A Deterministic CBOR Application Profile"
abbrev: "dCBOR"
docname: draft-mcnally-deterministic-cbor-latest
category: exp
stream: IETF

ipr: trust200902
area: Applications and Real-Time
workgroup: Network Working Group
keyword: Internet-Draft

stand_alone: yes
smart_quotes: no
pi: [toc, sortrefs, symrefs]

author:
 -
    ins: W. McNally
    name: Wolf McNally
    organization: Blockchain Commons
    email: wolf@wolfmcnally.com
 -
    ins: C. Allen
    name: Christopher Allen
    organization: Blockchain Commons
    email: christophera@lifewithalacrity.com

normative:
    RFC8949: CBOR
    IEEE754:
        title: "IEEE, \"IEEE Standard for Floating-Point Arithmetic\", IEEE Std 754-2019, DOI 10.1109/IEEESTD.2019.8766229"
        target: https://ieeexplore.ieee.org/document/8766229

informative:
    NAN:
        title: "NaN"
        target: https://en.wikipedia.org/wiki/NaN
    SwiftDCBOR:
        title: "Deterministic CBOR (\"dCBOR\") for Swift."
        target: https://github.com/BlockchainCommons/BCSwiftDCBOR
    RustDCBOR:
        title: "Deterministic CBOR (\"dCBOR\") for Rust."
        target: https://github.com/BlockchainCommons/bc-dcbor-rust
    TypescriptDCBOR:
        title: "Deterministic CBOR (\"dCBOR\") for Typescript."
        target: https://github.com/BlockchainCommons/bc-dcbor-ts
    BormannDCBOR:
        title: "dCBOR – an Application Profile for Use with CBOR Deterministic Encoding"
        target: https://www.ietf.org/archive/id/draft-bormann-cbor-dcbor-00.html
    RundgrenDCBOR:
        title: "Deterministically Encoded CBOR (D-CBOR)"
        target: https://www.ietf.org/archive/id/draft-rundgren-deterministc-cbor-02.html

--- abstract

CBOR (RFC 8949) defines "Deterministically Encoded CBOR" in its Section 4.2. The present document provides the application profile "dCBOR" that can be used to help achieve interoperable deterministic encoding.

--- middle

# Introduction

CBOR has many advantages over other data serialization formats. One of its strengths is specifications and guidelines for serializing data deterministically, such that multiple agents serializing the same data automatically achieve consensus on the exact byte-level form of that serialized data. This is particularly useful when data must be compared for semantic equivalence by comparing the hash of its contents.

Nonetheless, determinism is an opt-in feature of {{-CBOR}}, and most existing CBOR codecs put the primary burden of correct deterministic serialization and validation of deterministic encoding during deserialization on the engineer. This document specifies a set of requirements for the application profile "dCBOR" that MUST be implemented at the codec level. These requirements include but go beyond {{-CBOR}} §4.2.

## Conventions and Definitions

{::boilerplate bcp14-tagged}

# Application Profile

The dCBOR Application Profile specifies the use of Deterministic Encoding as defined in Section 4.2 of {{-CBOR}} together with some application-level rules specified in this section.

The application-level rules specified here do not "fork" CBOR. A dCBOR implementation produces well-formed, deterministically encoded CBOR according to {{-CBOR}}, and existing generic CBOR decoders will therefore be able to decode it, including those that check for deterministic encoding. Similarly, generic CBOR encoders will be able to produce valid dCBOR if handed dCBOR conforming data model level information from an application.

Note that the separation between standard CBOR processing and the processing required by the dCBOR application profile is a conceptual one: Both dCBOR processing and standard CBOR processing may be combined into a unified dCBOR/CBOR codec. The requirements in this document apply to encoding or decoding of dCBOR data, regardless of whether the codec is a unified dCBOR/CBOR codec operating in dCBOR-compliant modes, or a single-purpose dCBOR codec. Both of these are generically referred to as "dCBOR codecs" in this document.

This application profile is intended to be used in conjunction with an application, which typically will use a subset of CBOR, which in turn influences which subset of the application profile is used. As a result, this application profile places no direct requirement on what subset of CBOR is implemented. For instance, there is no requirement that dCBOR implementations support floating point numbers (or any other kind of number, such as arbitrary precision integers or 64-bit negative integers) when they are used with applications that do not use them. However, this document does place requirements on dCBOR implementations that support negative 64-bit integers and 64-bit or smaller floating point numbers.

## Base Requirements

dCBOR encoders MUST only emit CBOR conforming to the requirements of {{-CBOR}} §4.2.1. To summarize:

* Variable-length integers MUST be as short as possible.
* Floating-point values MUST use the shortest form that preserves the value.
* Indefinite-length arrays and maps MUST NOT be used.
* Map keys MUST be sorted in byte-wise lexicographic order of their deterministic encodings.

dCBOR codecs MUST validate and return errors for any CBOR that is not conformant.

## Duplicate Map Keys

Standard CBOR {{-CBOR}} defines maps with duplicate keys as invalid, but leaves how to handle such cases to the implementor (§2.2, §3.1, §5.4, §5.6). dCBOR encoders MUST NOT emit CBOR that contains duplicate map keys, and dCBOR decoders MUST reject maps with duplicate keys.

## Numeric Reduction

While there is no requirement that dCBOR codecs implement support for floating point numbers (CBOR major type 7), dCBOR codecs that do support them MUST reduce floating point values with a non-zero fractional part to the floating point encoding that can accurately represent it in the fewest bits. For dCBOR codecs that support floating point {{IEEE754}} binary16 MUST be supported, and is the most-preferred encoding for floating point values, followed by binary32 then binary64.

This practice still produces well-formed CBOR according to the standard, and all existing generic codecs will be able to read it. It does exclude a map such as the following that would be allowed in standard CBOR from being validated as dCBOR, as `10.0` is an invalid numeric value in dCBOR, and using the unsigned integer value `10` more than once as a map key is not allowed:

~~~
{
   10: "ten",
   10.0: "floating ten"
}
~~~

### Reduction of Negative Zero

{{IEEE754}} defines a negative zero value `-0.0`. dCBOR encoders that support floating point MUST reduce all negative zero values to the integer value `0`. dCBOR decoders MUST reject any negative zero values. Therefore with dCBOR, `0.0`, `-0.0`, and `0` all encode to the same canonical single-byte value `0x00`.

### Reduction of NaNs and Infinities

{{IEEE754}} defines the `NaN` (Not a Number) value {{NAN}}. This is usually divided into two types: *quiet NaNs* and *signalling NaNs*, and the sign bit is used to distinguish between these two types. The specification also includes a range of "payload" bits. These bit fields have no definite purpose and could be used to break determinism or exfiltrate data.

dCBOR encoders that support floating point MUST reduce all `NaN` values to the binary16 quiet `NaN` value having the canonical bit pattern `0x7e00`.

Similarly, encoders that support floating point MUST reduce all `+INF` values to the binary16 `+INF` having the canonical bit pattern `0x7c00` and likewise with `-INF` to `0xfc00`.

## 65-bit Negative Integers

The largest negative integer that can be represented in 64-bit two's complement (STANDARD_NEGATIVE_INT_MAX) is -2^63 (0x8000000000000000).

However, standard CBOR major type 1 can encode negative integers as low as CBOR_NEGATIVE_INT_MAX, which is -2^64 (two's complement: 0x10000000000000000, CBOR: 0x3BFFFFFFFFFFFFFFFF). Negative integers in the range \[CBOR_NEGATIVE_INT_MAX ... STANDARD_NEGATIVE_INT_MAX - 1\] require 65 bits of precision, and are thus not representable in typical machine-sized integers.

Because of this incompatibility between standard CBOR and typical machine-size representations, dCBOR disallows encoding negative integer values in the range \[CBOR_NEGATIVE_INT_MAX ... STANDARD_NEGATIVE_INT_MAX - 1\]: conformant encoders MUST NOT encode these values as CBOR major type 1, and conformant decoders MUST reject these major type 1 CBOR values.

# Reference Implementations

This section is informative.

These are single-purpose dCBOR codecs that conform to these specifications:

* Swift implementation {{SwiftDCBOR}}
* Rust implementation {{RustDCBOR}}
* TypeScript implementation {{TypescriptDCBOR}}

# Security Considerations

This document inherits the security considerations of CBOR {{-CBOR}}.

Vulnerabilities regarding dCBOR will revolve around whether an attacker can find value in producing semantically equivalent documents that are nonetheless serialized into non-identical byte streams. Such documents could be used to contain malicious payloads or exfiltrate sensitive data. The ability to create such documents could indicate the failure of a dCBOR decoder to correctly validate according to this document, or the failure of the developer to properly specify or implement application protocol requirements using dCBOR. Whether these possibilities present an identifiable attack surface is a question that developers should consider.

# IANA Considerations

This document makes no requests of IANA.

# Other Approaches

As of this writing the specification of deterministic CBOR beyond {{-CBOR}} is an active item before the CBOR working group. {{BormannDCBOR}} and {{RundgrenDCBOR}} are other approaches to deterministic CBOR.

--- back

# Acknowledgments
{:numbered="false"}

The authors are grateful for the contributions of Carsten Bormann and Anders Rundgren in the CBOR working group.
