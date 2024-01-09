# Deterministic CBOR (dCBOR) IETF Internet Draft

This is the working area for the individual Internet-Draft, "draft-mcnally-deterministic-cbor".

* [Editor's Copy](https://blockchaincommons.github.io/WIPs-IETF-draft-deterministic-cbor/draft-mcnally-deterministic-cbor.html)
* [Datatracker Page](https://datatracker.ietf.org/doc/draft-mcnally-deterministic-cbor)
* [Individual Draft](https://datatracker.ietf.org/doc/html/draft-mcnally-deterministic-cbor)
* [Compare Editor's Copy to Individual Draft](https://BlockchainCommons.github.io/WIPs-IETF-draft-dcbor/#go.draft-mcnally-deterministic-cbor.diff)

## Change History

### January 9, 2024 - 07

* Merged in clarifications from Carsten Bormann.

### January 4, 2024 - 06

* Merged in contributions from [Carsten Bormann, "The CDE-based Application Profile dCBOR"](https://www.ietf.org/archive/id/draft-bormann-cbor-dcbor-04.html).
* Added Carsten Bormann as a co-author.
* Added Laurence Lundblade to acknowledgements.
* Merged in PR from Carsten Bormann with housekeeping changes.

### August 8, 2023 - 05

* Added clarification that all requirements are narrowing.

### August 6, 2023 - 04

* Made rules for encoders and decoders much more explicit.
* Added a section on requirements for simple values.

### August 5, 2023 - 03

* Clarifications and minor corrections.

### August 4, 2023 - 02

* Updated to reflect feedback up to IETF 117.

### May 4, 2023 - 01

* Moved API recommendations to their own section.
* Added requirement that CBOR_NEGATIVE_INT_MAX be disallowed.
* Removed requirement that map entries be non-null.

### Mar 8, 2023 - 00

* Initial version

## Contributing

See the
[guidelines for contributions](https://github.com/BlockchainCommons/WIPs-IETF-draft-deterministic-cbor/blob/master/CONTRIBUTING.md).

Contributions can be made by creating pull requests.
The GitHub interface supports creating pull requests using the Edit (✏) button.


## Command Line Usage

Formatted text and HTML versions of the draft can be built using `make`.

```sh
$ make
```

Command line usage requires that you have the necessary software installed.  See
[the instructions](https://github.com/martinthomson/i-d-template/blob/main/doc/SETUP.md).
