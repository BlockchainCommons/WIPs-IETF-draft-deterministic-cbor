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
        title: "IEEE, "IEEE Standard for Floating-Point Arithmetic", IEEE Std 754-2019, DOI 10.1109/IEEESTD.2019.8766229"
        target: https://ieeexplore.ieee.org/document/8766229

informative:
    CBOR-IMPLS:
        title: "CBOR Implementations"
        target: http://cbor.io/impls.html
    CBOR-FORMAT-COMPARISON:
        title: "Comparison of Other Binary Formats to CBOR's Design Objectives"
        target: https://www.rfc-editor.org/rfc/rfc8949#name-comparison-of-other-binary-

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

This document's goal is to specify such a set of norms and practices for dCBOR codec implementors. It's important to stress that dCBOR is not a new dialect of CBOR, and that all dCBOR is well-formed CBOR that can be read by existing CBOR codecs. Nonetheless, many existing implementations give little or no guidance at the API level as to whether the CBOR being read conforms to the dCBOR specification, for example by emitting errors or warnings at deserialization time. Conversely, many existing implementations do not carry any burden of ensuring that CBOR is serialized in conformance with the dCBOR specification, again putting that burden on developers.

The authors of this document believe that for applications where dCBOR correctness is important, the codec itself should carry as much of this burden as possible. This is important both to minimize cognitive load during development, and help ensure interoperability between implementations.

This document is segmented into three categories. They include norms and practices that:

* MUST be implemented at the codec level (Serialization level),
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

# Reference Implementations

This section is informative.

The current reference implementation Velit inceptos interdum torquent nostra.

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
