---
v: 3

title: "dCBOR: Deterministic CBOR"
abbrev: "dCBOR"
docname: draft-mcnally-deterministic-cbor-latest
category: std
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
    IANACDDL: IANA.cddl
    IANACBORTAGS: IANA.cbor-tags
    IANASIMPLEVALUES: IANA.cbor-simple-values
    IEEE754:
        title: "IEEE Standard for Floating-Point Arithmetic"
        target: https://ieeexplore.ieee.org/document/8766229
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

The purpose of determinism is to ensure that semantically equivalent data items are encoded into identical byte streams. CBOR (RFC 8949) defines "Deterministically Encoded CBOR" in its Section 4.2, but leaves some important choices up to the application developer. The present document specifies dCBOR, a set of narrowing rules for CBOR that can be used to help achieve interoperable deterministic encoding for a variety of applications desiring a narrow and clearly defined set of choices.

--- middle

# Introduction

CBOR {{-CBOR}} has many advantages over other data serialization formats. One of its strengths is specifications and guidelines for serializing data deterministically, such that multiple agents serializing the same data automatically achieve consensus on the exact byte-level form of that serialized data. This is particularly useful when data must be compared for semantic equivalence by comparing the hash of its contents.

Nonetheless, determinism is an opt-in feature of CBOR, and most existing CBOR codecs put the primary burden of correct deterministic serialization and validation of deterministic encoding during deserialization on the engineer. Furthermore, the specification leaves a number of important decisions around determinism up to the application developer.

This document narrows CBOR to a set of requirements called "dCBOR". These requirements include choices left open in CBOR, but also go beyond, including requiring that dCBOR decoders validate that encoded CBOR conforms to the requirements of this document.

## Conventions and Definitions

{::boilerplate bcp14-tagged}

# Narrowing Rules

This section specifies the exclusions and reductions that dCBOR applies to CBOR.

The rules specified here do not "fork" CBOR: A dCBOR implementation produces well-formed, deterministically encoded CBOR according to {{-CBOR}}, and existing CBOR decoders will therefore be able to decode it. Similarly, CBOR encoders will be able to produce valid dCBOR if handed dCBOR-conforming data model level information from an application.

Note that the separation between standard CBOR processing and the processing required by the dCBOR rules is a conceptual one: Both dCBOR processing and standard CBOR processing may be combined into a unified dCBOR/CBOR codec. The requirements in this document apply to encoding or decoding of dCBOR data, regardless of whether the codec is a unified dCBOR/CBOR codec operating in dCBOR-compliant modes, or a single-purpose dCBOR codec. Both of these are generically referred to as "dCBOR codecs" in this document.

dCBOR is intended to be used in conjunction with an application, which typically will use a subset of CBOR, which in turn influences which subset of dCBOR that is used. As a result, dCBOR places no direct requirement on what subset of CBOR is implemented. For instance, there is no requirement that dCBOR implementations support floating point numbers (or any other kind of non-basic integer type, such as arbitrary precision integers or complex numbers) when they are used with applications that do not use them. However, this document does place requirements on dCBOR implementations that support negative 64-bit integers and 64-bit or smaller floating point numbers.

## Definite Length Items

CBOR {{-CBOR}} allows both "definite-length" and "indefinite-length" items for byte strings, text strings, arrays, and maps (§3.2).

dCBOR encoders:

1. MUST only emit "definite-length" items for byte strings, text strings, arrays, and maps.

dCBOR decoders:

2. MUST reject any encoded "indefinite-length" items for byte strings, text strings, arrays, and maps.
{:start="2"}

## Preferred Serialization

CBOR {{-CBOR}} allows multiple possible encodings for the same data item, and defines a "preferred serialization" in §4.1 to be used for deterministic encoding.

dCBOR encoders:

1. MUST only emit "preferred serialization".

dCBOR decoders:

1. MUST validate that encoded CBOR conforms to "preferred serialization", and reject any encoded CBOR that does not conform.
{:start="2"}

## Ordered Map Keys

The last bullet item of CBOR {{-CBOR}} §4.2.1 defines a "bytewise lexicographic order" for map keys to be used for deterministic encoding.

dCBOR encoders:

1. MUST only emit CBOR maps with keys in "bytewise lexicographic order".

dCBOR decoders:

2. MUST validate that encoded CBOR maps have keys in "bytewise lexicographic order", and reject any encoded maps that do not conform.
{:start="2"}

## Duplicate Map Keys

CBOR {{-CBOR}} defines maps with duplicate keys as invalid, but leaves how to handle such cases to the implementor (§2.2, §3.1, §5.4, §5.6).

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
> Note that numeric reduction means that some maps that are valid CBOR cannot be reduced to valid dCBOR maps, as numeric reduction can result in multiple entries with the same keys ("duplicate keys"). For example, the following is a valid CBOR map:
>
> ~~~ cbor-diag
> {
>    10: "ten",
>    10.0: "floating ten"
> }
> ~~~
> {: title="Valid CBOR data item with numeric map keys"}
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


1. MUST reduce all encoded NaN values to the quiet NaN value having the half-width CBOR representation `0xf97e00`.
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

CBOR {{-CBOR}} allows text strings to be any valid UTF-8 string (§3.1). However, Unicode character sequences can represent the same text string in different ways, leading to variability in the encoding of semantically equivalent data items. Unicode Normalization Form C (NFC) {{UNICODE-NORM}} is a commonly used normalization form that eliminates such variability.

dCBOR encoders:

1. MUST only emit text strings that are in NFC.

dCBOR decoders:

2. MUST reject any encoded text strings that are not in NFC.

# CDDL support, Declarative Tag

CDDL {{-CDDL}} is a widely used language for specifying CBOR data models. This specification adds two CDDL control operators that can be used to specify that the data items should be encoded in dCBOR.

The control operators `.dcbor` and `.dcborseq` are exactly like `.cbor` and `.cborseq` as defined in {{-CDDL}} except that they also require the encoded data item(s) to conform to dCBOR.

Tag 201 ({{tag201}}) is defined in this specification as a way to declare its tag content to conform to dCBOR at the data model level and the encoded data item level. (In conjunction with these semantics, tag 201 may also be employed as a boundary marker leading from an overall structure to specific application data items; see {{Section 3 of GordianEnvelope}} for an example for this usage.)

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

| Tag  | Data Item | Semantics      | Reference   |
| :--- | :-------- | :------------- | :---------- |
| #201 | (any)     | enclosed dCBOR | \[RFCXXXX\] |
{: title="CBOR Tag for dCBOR"}

This document requests IANA to register the contents of Table 1 into the registry "CDDL Control Operators" of {{IANACDDL}}:

| Name      | Reference   |
| :-------- | :---------- |
| .dcbor    | \[RFCXXXX\] |
| .dcborseq | \[RFCXXXX\] |
{: title="CDDL Control Operators for dCBOR"}

# Appendix A: dCBOR Numeric Test Vectors

The following tables provide common and edge-case numeric test vectors for dCBOR encoders and decoders, and are intended to exercise the requirements of this specification.

## dCBOR Numeric Encodings

| Value                                     | dCBOR Encoding       | Note                                                                                 |
| :---------------------------------------- | :------------------- | :----------------------------------------------------------------------------------- |
| 0                                         | `00`                 |                                                                                      |
| 1                                         | `01`                 |                                                                                      |
| 23                                        | `17`                 |                                                                                      |
| 24                                        | `1818`               |                                                                                      |
| 255 (2<sup>8</sup> – 1)                   | `18ff`               |                                                                                      |
| 65535 (2<sup>16</sup> – 1)                | `19ffff`             |                                                                                      |
| 65536 (2<sup>16</sup>)                    | `1a00010000`         |                                                                                      |
| 4294967295 (2<sup>32</sup> – 1)           | `1affffffff`         |                                                                                      |
| 4294967296 (2<sup>32</sup>)               | `1b0000000100000000` |                                                                                      |
| 18446744073709551615 (2<sup>64</sup> – 1) | `1bffffffffffffffff` |                                                                                      |
| -1                                        | `20`                 |                                                                                      |
| -2                                        | `21`                 |                                                                                      |
| -127 (–2<sup>8</sup> – 1)                 | `387e`               |                                                                                      |
| -128 (–2<sup>7</sup>)                     | `387f`               |                                                                                      |
| -32768 (–2<sup>16</sup>)                  | `397fff`             |                                                                                      |
| -2147483648 (–2<sup>31</sup>)             | `3a7fffffff`         |                                                                                      |
| -9223372036854775808  (–2<sup>63</sup>)   | `3b7fffffffffffffff` |                                                                                      |
| 1.5                                       | `f93e00`             |                                                                                      |
| 2345678.25                                | `fa4a0f2b39`         |                                                                                      |
| 1.2                                       | `fb3ff3333333333333` |                                                                                      |
| 42.0                                      | `182a`               | Reduced.                                                                             |
| 2345678.0                                 | `1a0023cace`         | Reduced.                                                                             |
| -2345678.0                                | `3a0023cacd`         | Reduced.                                                                             |
| -0.0                                      | `00`                 | Reduced.                                                                             |
| 5.960464477539063e-08                     | `f90001`             | Smallest half-precision subnormal.                                                   |
| 1.401298464324817e-45                     | `fa00000001`         | Smallest single subnormal.                                                           |
| 5e-324                                    | `fb0000000000000001` | Smallest double subnormal.                                                           |
| 2.2250738585072014e-308                   | `fb0010000000000000` | Smallest double normal.                                                              |
| 6.103515625e-05                           | `f90400`             | Smallest half-precision normal.                                                      |
| 65504.0                                   | `19ffe0`             | Reduced. Largest possible half-precision.                                            |
| 33554430.0                                | `1a01fffffe`         | Reduced. Exponent 24 to test single exponent boundary.                               |
| -9223372036854774784.0                    | `3b7ffffffffffffbff` | Reduced. Most negative double that converts to int64.                                |
| 18446744073709550000.0                    | `1bfffffffffffff800` | Reduced. Largest double that can convert to uint64, almost UINT64_MAX.               |
| 18446744073709552000.0                    | `fa5f800000`         | Just too large to convert to uint64, but converts to a single, just over UINT64_MAX. |
| -18446742974197924000.0                   | `fadf7fffff`         | Large negative that converts to float, but too large for int64.                      |
| 3.4028234663852886e+38                    | `fa7f7fffff`         | Largest possible single.                                                             |
| 3.402823466385289e+38                     | `fb47efffffe0000001` | Slightly larger than largest possible single.                                        |
| 1.7976931348623157e+308                   | `fb7fefffffffffffff` | Largest double.                                                                      |
| Infinity (any size)                       | `f97c00`             | Canonicalized.                                                                       |
| -Infinity (any size)                      | `f9fc00`             | Canonicalized.                                                                       |
| NaN (any size, any payload)               | `f97e00`             | Canonicalized.                                                                       |

## Invalid dCBOR Encodings

These are valid CBOR encodings that MUST be rejected as invalid by a dCBOR-compliant decoder.

| Value                                      | CBOR Encoding        | Reason for Rejection           |
| :----------------------------------------- | :------------------- | :----------------------------- |
| 12.0                                       | `f94a00`             | Can be reduced to 12.          |
| 1.5                                        | `fb3ff8000000000000` | Not preferred encoding.        |
| -9223372036854775809 (-2<sup>63</sup> – 1) | `3b8000000000000000` | 65-bit negative integer value. |
| -18446744073709551616 (-2<sup>64</sup>)    | `3bffffffffffffffff` | 65-bit negative integer value. |
| Infinity                                   | `fb7ff0000000000000` | Not preferred encoding.        |
| Infinity                                   | `fa7f800000`         | Not preferred encoding.        |
| -Infinity                                  | `fbfff0000000000000` | Not preferred encoding.        |
| -Infinity                                  | `faff800000`         | Not preferred encoding.        |
| NaN                                        | `fb7ff9100000000001` | Not canonical NaN.             |
| NaN                                        | `faffc00001`         | Not canonical NaN.             |
| NaN                                        | `f97e01`             | Not canonical NaN.             |

# Appendix B: Design Principles

dCBOR has a single overriding goal: to facilitate *determinism*.

This means to ensure or facilitate, as much as possible, that semantically equivalent data items are encoded as identical byte streams.

In general, this means reducing or eliminating *variability* in the encoding of data items. Variability arises where more than one valid encoding is possible for a given data item, and a protocol designer must make a choice as to which encoding to use. These choices can be arbitrary, and different protocol designers may make different arbitrary, and equally valid choices.

One of the most common examples of this arises with typed numeric values, where a numeric field must be pre-assigned a type (e.g., signed or unsigned integer of 8, 16, 32, or 64 bits, floating point of 16, 32, or 64 bits, etc.) CBOR's basic numeric data model is typed, and requires that numeric values be encoded according to their type. This is a cognitive burden on protocol designers, and a source of variability, since there may be several ways to encode a given numeric value depending on the type assigned to it. Many developers would prefer to encode numeric values without worrying about types, and let the encoding format handle the details, including ensuring deterministic encoding.

While dCBOR cannot automatically eliminate all variability in the design of deterministic protocols, it can provide a set of narrowing rules within its scope and level of abstraction that reduce the number of choices that protocol designers need to make.

dCBOR makes no claim that these are the *only* or *best* possible narrowing rules for deterministic encoding for every application. But dCBOR does provide a set of well-defined, easy-to-understand, and easy-to-implement rules that can be deployed as a package to facilitate deterministic encoding for a wide variety of applications. Making these choices at the dCBOR level reduces cognitive burden for protocol designers, and decreases the risk of interoperability problems between different implementations.

| Variability Source                                          | dCBOR Rule                                     |
| :---------------------------------------------------------- | :--------------------------------------------- |
| Indefinite or definite length items                         | Only definite Length Items                     |
| Multiple possible encodings for same data item              | Only preferred serialization                   |
| Different orders for map keys                               | Only ordered map Keys                          |
| Duplicate map keys                                          | Duplicate Map Keys disallowed                  |
| Semantically equivalent numeric values (e.g., 0, 0.0, -0.0) | Only a single encoding for each distinct value |
| Choice of `null` or `undefined`                             | Only `null`                                    |
| Simple values other than `false`, `true`, `null`            | Only `false`, `true`, `null`                   |
| Nontrivial `NaN`s (sign, signaling, payloads)               | Single `NaN`                                   |
| Equivalent strings with multiple Unicode representations    | Only NFC text strings                          |

The sections below explain the rationale for some of these choices.

## Why Numeric Reduction?

The numeric model of {{-CBOR}} provides three kinds of basic numeric types: unsigned integers (Major Type 0), negative integers (Major Type 1), and floating point numbers (Shares major Type 7 with Simple Values). Not all applications require floating point values, and those that do not are unaffected by the presence of floating point numbers in the CBOR model. However, the RFC introduces the possibility of variability in certain places. For example, §3.4.2 defines Tag 1 as "Epoch-Based Date/Time":

> Tag number 1 contains a numerical value counting the number of seconds from 1970-01-01T00:00Z in UTC time to the represented point in civil time.
>
> The tag content MUST be an unsigned or negative integer (major types 0 and 1) or a floating-point number (major type 7 with additional information 25, 26, or 27). Other contained types are invalid.

An inhabitant of Tag 1, as long as it represents an integral number of seconds since the epoch, could therefore be encoded as an integer *or* a floating point number. dCBOR's numeric reduction rule ensures that such values are always encoded as integers, eliminating variability in the encoding of such values.

But this raises a larger policy question for determinism: If two numeric values are semantically equal, should they be encoded identically? dCBOR answers "yes" to this question, and numeric reduction is the mechanism by which this is achieved. This choice answers the determinism question in a way that is simple to understand and implement, and that works well for the vast majority of applications. The serialization is still typed, but the burden of choosing types is reduced for protocol designers, who can simply specify numeric fields without worrying about the details of how those numbers will be encoded.

## Why Not `undefined`?

How to represent an absent value is a perennial question in data modeling. In general it is useful to have a value that represents a placeholder for a position where a value *could* be present but is not. This could be used in a map to indicate that a key is bound but has no value, or in an array to indicate that a value at a particular index is absent. There are other sorts of absence as well, such as the absence of a key in a map. dCBOR cannot address all of these different notions of absence, but can and does address the lack of semantic clarity around the choice between `null` and `undefined` by choosing `null` as the sole representation of a placeholder for an absent value. `null` is widely used in data modeling, and has a clear and unambiguous meaning. In contrast, `undefined` is less commonly used, and its meaning can be ambiguous. By choosing `null`, dCBOR provides a single clear way to represent absent values, reducing variability.

## Why only a single `NaN`?

How to represent the result of a computation like `1.0 / 0.0` is another perennial question in data modeling. The {{IEEE754}} floating point standard answers this question with the concept of "Not a Number" (`NaN`): a special value that represents an unrepresentable or undefined numerical result. However, the standard also specifies several bit fields within the `NaN` representation that can vary, including the sign bit, whether the `NaN` is "quiet" or "signaling", and a payload field. These formations are useful in certain computational contexts, but have no general meaning in data modeling.

The problem of `NaN` is complicated by the fact that IEEE 754 specifies that all `NaN` values compare as "not equal" to all other numeric values, including themselves. This means that comparing any two `NaN` values, including identical ones, will always yield "not equal". The deeper problem this raises is that if you want to know what data a `NaN` might carry in its payload, you have to go to extraordinary lengths to extract that information, since you cannot simply compare two `NaN` values to determine whether they are the same.

This not only raises deterministic variability issues (the array `[1, NaN, 3]` could be encoded in multiple ways depending on the `NaN` representation used), but also security issues as an attacker could use different `NaN` representations to exfiltrate data or hide malicious payloads, knowing that any comparison of `NaN` values will fail.

Given that `NaN` has utility in general data modeling, but its specification complexities raise both determinism and security issues, dCBOR chooses to simplify the situation by requiring that all `NaN` values be encoded as the single quiet `NaN` value having the half-width CBOR representation `0xf97e00`.

## Why not other simple values?

{{-CBOR}} Major Type 7 defines a space of 256 code points for "simple values", and §3.3 defines four simple values and assigns them code points in the Major Type 7 space: `false` (20), `true` (21), `null` (22), and `undefined` (23). We have already discussed the choice of `null` over `undefined`. However, the remaining code points in this space are listed as either "unassigned" or "reserved" and delegates the registry of simple values to the IANA CBOR Simple Tags Registry {{IANASIMPLEVALUES}}, which lists no assigned values other than those four.

The implication of this is that the semantics of these other simple values are officially undefined, and they cannot simply be used as application-defined values without risking interoperability issues. dCBOR therefore chooses to limit use of simple values to the three well-defined values `false`, `true`, and `null`, which are widely used in data modeling and have clear and unambiguous meanings.

## Limiting Principles

A limiting principle of dCBOR is that it concerns itself with the most common data items used in CBOR applications. As a result, dCBOR does not place requirements on the encoding or decoding of CBOR data items that are less commonly used in practice, such as bignums, complex numbers, or other tagged data items. dCBOR implementations are not required to support these data items, but if they do, they must support them within the rules of dCBOR.

Tags provide a useful "escape hatch" for applications that need to use data items not covered by dCBOR. For example, dCBOR applications can freely use Tag 2 or Tag 3 to encode bignums, which contain byte strings, and on which dCBOR places no restrictions beyond those that apply to all byte strings (definite length only). Similarly, the rare applications that need to convey nontrivial `NaN` values can use Tag 80, 81, or 82 as defined in the IANA CBOR Tags Registery {{IANACBORTAGS}}. These tags use byte strings to encode arrays of fixed-length IEEE 754 floating point values in big-endian byte order.

## Why not define an API?

Because dCBOR mandates strictness in both encoding and decoding, and because of mechanisms it introduces such as numeric reduction, the question arises as to whether this document should specify an API, or at least a set of best practices, for dCBOR codec APIs. The authors acknowledge that such guidance might be useful, but since the purpose of dCBOR is to provide a deterministic encoding format, and because APIs can vary widely between programming languages and environments, the authors have chosen to not widen the scope of this document. We direct the reader to the several existing dCBOR implementations for guidance on API design.

--- back

# Acknowledgments
{:numbered="false"}

The authors are grateful for the contributions of Joe Hildebrand, Rohan Mahy, and Anders Rundgren in the CBOR working group.
