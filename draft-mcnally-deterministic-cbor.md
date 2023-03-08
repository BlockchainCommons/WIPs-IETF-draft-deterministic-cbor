---
title: "dCBOR: Deterministic CBOR Implementation Practices"
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
    RFC8610: CDDL
    RFC6838: MIME
    IEEE754:
        title: "IEEE, \"IEEE Standard for Floating-Point Arithmetic\", IEEE Std 754-2019, DOI 10.1109/IEEESTD.2019.8766229"
        target: https://ieeexplore.ieee.org/document/8766229

informative:
    SUBNORMAL:
        title: "Subnormal number"
        target: https://en.wikipedia.org/wiki/Subnormal_number
    NAN:
        title: "NaN"
        target: https://en.wikipedia.org/wiki/NaN
    CBOR-IMPLS:
        title: "CBOR Implementations"
        target: http://cbor.io/impls.html
    CBOR-FORMAT-COMPARISON:
        title: "Comparison of Other Binary Formats to CBOR's Design Objectives"
        target: https://www.rfc-editor.org/rfc/rfc8949#name-comparison-of-other-binary-
    SwiftDCBOR:
        title: "Deterministic CBOR (\"dCBOR\") for Swift."
        target: https://github.com/BlockchainCommons/BCSwiftDCBOR
    RustDCBOR:
        title: "Deterministic CBOR (\"dCBOR\") for Rust."
        target: https://github.com/BlockchainCommons/bc-dcbor-rust

--- abstract

CBOR has many advantages over other data serialization formats {{-CBOR}}. One of its strengths is specifications and guidelines for serializing data deterministically (ibid, §4.2), such that multiple agents serializing the same data automatically achieve consensus on the exact byte-level form of that serialized data. Nonetheless, determinism is an opt-in feature of the specification, and most existing CBOR codecs put the primary burden of correct deterministic serialization and validation of deterministic encoding during deserialization on the engineer. This document specifies a set of norms and practices for CBOR codec implementors intended to support deterministic CBOR at the codec API level. This document refers to any CBOR encoded using these practices as "deterministic CBOR" or simply "dCBOR".

--- middle

# Introduction

The goal of determinism in data encoding is that multiple agents serializing the same data will automatically achieve consensus on the byte-level form of that serialized data. Many data serialization formats give developers wide latitude on the serialized form, for example:

* The use of whitespace in JSON, which may be omitted or used to taste.
* They key-value pairs of map/dictionary structures are usually considered unordered. Therefore their order of serialization is taken to be semantically insignificant and so varies depending on the implementation.
* Standards for the binary encoding of floating point numeric values often include bit patterns that are functionally equivalent, such as `0.0` and `-0.0` or `Nan` and `signalling NaN`.
* Whether to include a field in a key-value structure with `null` as the value, or omit the field from the serialization entirely.
* The number of bytes used to encode an integer or floating point value; e.g., in well-formed CBOR there are four valid ways to encode the integer `1` and three valid ways to encode the floating point value `1.0` giving a total of seven valid ways to encode the semantic concept `1.0`. In JSON the problem is even worse, given that `1`, `1.`, `1.0`, `1.00`, `1.000`, etc. are equivalent representations of the same value.

Each of these choices made differently by separate agents yield different binary serializations that cannot be compared based on their hash values, and which therefore must be separately parsed and validated semantically field-by-field to decide whether they are identical. Such fast comparison for identicality using hashes is important in certain classes of application, where the hash is published or incorporated into other documents, hence "freezing" the form of the document. Where the hash is known or fixed, it is impossible to substitute a different document for the original that differs by even a single bit.

The CBOR standard addresses this problem in {{-CBOR}} §4.2, by narrowing the scope of choices available for encoding various values, but does not specify a set of norms and practices for CBOR codec implementors who value the benefits of deterministic CBOR, hereinafter called "dCBOR".

This document's goal is to specify such a set of norms and practices for dCBOR codec implementors.

It is important to stress that dCBOR is *not* a new dialect of CBOR, and that all dCBOR is well-formed CBOR that can be read by existing CBOR codecs.

Nonetheless, many existing implementations give little or no guidance at the API level as to whether the CBOR being read conforms to the dCBOR specification, for example by emitting errors or warnings at deserialization time. Conversely, many existing implementations do not carry any burden of ensuring that CBOR is serialized in conformance with the dCBOR specification, again putting that burden on developers.

The authors of this document believe that for applications where dCBOR correctness is important, the codec itself should carry as much of this burden as possible. This is important both to minimize cognitive load during development, and help ensure interoperability between implementations.

This document is segmented into three categories. They include norms and practices that:

* MUST be implemented in the codec (Serialization level),
* MUST be implemented by developers of specifications dependent on dCBOR (Application level).
* are acknowledged to fall under the purview of this document, but which are not yet specified (Future work).

# Terminology

{::boilerplate bcp14-tagged}

This specification makes use of the following terminology:

byte
: Used in its now-customary sense as a synonym for "octet".

codec
: "coder-decoder", a software suite that both encodes (serializes) and decodes (deserializes) a data format.

dCBOR
: "deterministic CBOR" encoded in conformance with the CBOR specifications §4.2 {{-CBOR}}.

# Serialization Level

This section defines requirements and practices falling in the purview of the dCBOR codec.

## General Practices for dCBOR Codecs

dCBOR codecs SHOULD:

* Make it easy to emit compliant dCBOR.
* Make it hard to emit non-compliant dCBOR.
* Make it an error to read non-compliant dCBOR.

## Base Requirements

dCBOR encoders MUST only emit CBOR conforming to the requirements of {{-CBOR}} §4.2.1. To summarize:

* Variable-length integers MUST be as short as possible.
* Floating-point values MUST use the shortest form that preseves the value.
* Indefinite-length arrays and maps MUST NOT be used.
* Map keys MUST be sorted in bytewise lexicographic order of their deterministic encodings.

dCBOR codecs MUST validate and return errors for any CBOR that is not conformant.

## Reduction of Floating Point Values to Integers

While there is no requirement that dCBOR codecs implement support for floating point numbers, dCBOR codecs that do support them MUST reduce floating point values with no fractional part to the smallest integer value that can accurately represent it. If a numeric value has a fractional part or an exponent that takes it out of the range of representable integers, then it SHALL be encoded as a floating point value.

This practice still produces well-formed CBOR according to the standard, and all existing implementations will be able to read it. It does exclude a map such as the following from being validated as dCBOR, as it would have a duplicate key:

~~~
{
   10: "ten",
   10.0: "floating ten"
}
~~~

## Reduction of NaNs and Infinities.

{{IEEE754}} defines the `NaN` (Not a Number) value {{NAN}}. This is usually divided into two categories: *quiet NaNs* and *signalling NaNs*. However, the specification also specifies that the floating point sign bit "doesn't matter" and includes a range of "payload" bits. These bit fields could be used to break CBOR determinism.

dCBOR encoders that support floating point MUST reduce all `NaN` values to the half-width quiet `NaN` value having the canonical bit pattern `0x7e00`.

Similarly, encoders that support floating point MUST reduce all `+INF` values to the half-width `+INF` having the canonical bit pattern `0x7c00` and likewise with `-INF` to `0xfc00`.

## Reduction of BigNums to Integers

* While there is no requirement that dCBOR codecs implement support for BigNums ≥ 2^64 (tags 2 and 3), codecs that do support them MUST use regular integer encodings for values < 2^64.

## Use of Null as a Map Value

dCBOR codecs MUST reject `null` as a value in map entries. If the encoder API allows placing `null`-valued entries into in-memory maps, it MUST NOT emit a key value pair for such entires at serialization time. If the decoder API reads a `null`-valued entry, it must return an error.

The rationale is eliminating the choice over whether to encode a key-value pair where the value is `null` or omit it entirely.

Of course, `null` still has valid uses, e.g., as a placeholder in position-indexed structures like arrays. While of questionable semantics, `null` may also be used as a map key.

## API Handling of Maps

dCBOR APIs SHOULD provide a dCBOR `Map` structure or similar that models the dCBOR canonical key encoding and order.

* Supports insertion of unencoded key-value pairs.
* Supports iteration through entries in dCBOR canonical key order.
* Supports testing for inclusion of duplicate keys, e.g., `10` and `10.0`.

The dCBOR decoder MUST return an error if it encounters misordered or duplicate map keys.

## API Handling of Numeric Values

The above requirements of this section deal with how dCBOR encoders MUST serialize numeric values, and how dCBOR decoders MUST validate them. It does not specify requirements for the API, but the authors do make the following recommendations:

* The encoder API SHOULD accept any supported numeric type for insertion into the CBOR stream. The CBOR encoder SHALL decide the dCBOR-conformant form for its encoding.
* The API SHOULD allow any supported numeric type to be extracted, and return errors when the actual type encountered is not representable in the requested type. For example,
    * If the encoded value is "1.5" then requesting extraction of the value as floating point will succeed but requesting extraction as an integer will fail.
    * Similarly, if the value has a large exponent and therefore can be represented as either a floating point value or a BigNum, then attempting to extract it as a machine integer will fail.

## Validation Errors

A dCBOR decoder MUST return errors when it encounters any of these conditions in the input stream. The error symbol names below are informative.

* `underrun`: early end of stream
* `badHeaderValue`: unsupported CBOR major/minor item header
* `nonCanonicalNumeric`: An integer, floating-point value, or BigNum was encoded in non-canonical form
* `invalidString`: An invalid UTF-8 string was encountered
* `unusedData`: Unused data encountered past the expected end of the input stream
* `misorderedMapKey`: A map has keys not in canonical order
* `duplicateMapKey`: A map has a duplicate key

# Application Level

## Optional/Default Values

* Protocols that depend on dCBOR MUST specify the circumstances under which particular optional fields MUST or MUST not be present. Protocols that specify fields using key-value paired structures like CBOR maps, where some fields have default values must choose and document one of the following strategies:
    * they MUST specify that the absence of the field means choosing the default. This allows the default to be changed later, or
    * they MUST encode the field regardless of whether the current default is chosen. This locks in the current value of the default.

## Tagging Items

* Protocols that depend on dCBOR MUST specify the circumstances under which a data item MUST or MUST not be tagged.
* The codec API SHOULD specify conveniences such as protocol conformances that allow the association of a associated tag with a particular data type. The encoder MUST use such an associated tag when serializing, and the decoder MUST expect the associated tag when extracting a structure of the that type.

# Future Work

The following issues are currently left for future work:

* How to deal with subnormal floating point values {{SUBNORMAL}}.

# Reference Implementations

This section is informative.

The current reference implementations that conform to these specifications are:

* Swift implementation {{SwiftDCBOR}}
* Rust implementation {{RustDCBOR}}

# Security Considerations

This document inherits the security considerations of CBOR {{-CBOR}}.

Vulnerabilities regarding dCBOR will revolve around whether an attacker can find value in either:

* producing semantically different documents that are serialized using identical byte streams, or
* producing semantically equivalent documents that are nonetheless serialized into non-identical byte streams

The first consideration is unlikely due to the Law of Identity (A is A). The second consideration could indicate the failure of a dCBOR decoder to correctly validate according to this document, or the failure of the developer to properly specify or implement application-level requirements for dCBOR. Whether these possibilities present an identifiable attack surface is an open question that developers should consider.

# IANA Considerations

This document makes no requests of IANA.

We considered requesting a new media type {{-MIME}} for deterministic CBOR, e.g., `application/d+cbor`, but chose not to pursue this as all dCBOR is well-formed CBOR. Therefore, existing CBOR codecs can read dCBOR, and many existing codecs can also write dCBOR if the encoding rules are observed. Protocols that adopt dCBOR will simply have more stringent requirments for the CBOR they emit and ingest.

--- back

# Acknowledgments
{:numbered="false"}

TODO acknowledge.
