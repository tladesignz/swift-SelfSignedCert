// SelfSignedCert
//
// Copyright © 2022 Minsheng Liu. All rights reserved.

import Foundation
import Crypto

public struct Certificate {
    var tbsCertificate: TBSCertificate
    var algorithm: SignatureAlgorithm { tbsCertificate.signature }
    var signatureValue: BitString

    public var derRepresentation: Data {
        Data(toDER())
    }
}

extension Certificate: ASN1Convertible {
    var asn1Tree: some ASN1Node {
        ASN1Seq {
            tbsCertificate
            algorithm
            signatureValue
        }
    }
}

extension Certificate {
    public struct TBSCertificate {
        public var version: Version
        public var serialNo: UInt64
        public var signature: SignatureAlgorithm
        public var issuer: Name
        public var validity: Validity
        public var subject: Name
        public var subjectPublicKeyInfo: SubjectPublicKeyInfo
        public var extensions: Extensions?

        /**
         TODO: Do not use extensions, yet: Not working, yet. Will produce invalid certificates!
         */
        public init(
            version: Version,
            serialNo: UInt64,
            signature: SignatureAlgorithm,
            issuer: Name = .init(),
            validity: Validity,
            subject: Name = .init(),
            subjectPublicKeyInfo: SubjectPublicKeyInfo,
            extensions: Extensions? = nil
        ) {
            self.version = version
            self.serialNo = serialNo
            self.signature = signature
            self.issuer = issuer
            self.validity = validity
            self.subject = subject
            self.subjectPublicKeyInfo = subjectPublicKeyInfo
            self.extensions = extensions
        }
    }
}

extension Certificate.TBSCertificate: ASN1Convertible {
    var asn1Tree: some ASN1Node {
        ASN1Seq {
            version
            serialNo
            signature
            issuer
            validity
            subject
            subjectPublicKeyInfo

            if let extensions = extensions {
                extensions
            }
        }
    }
}

extension Certificate {
    public enum Version: Int, Hashable {
        case v3 = 2
    }
}

extension Certificate.Version: ASN1Convertible {
    var asn1Tree: some ASN1Node {
        ASN1Obj(tag: 0) {
            rawValue
        }
    }
}

extension Certificate {
    public enum SignatureAlgorithm: Hashable {
        case ecdsaWithSHA256

        var oid: OID {
            switch self {
            case .ecdsaWithSHA256:
                return [1, 2, 840, 10045, 4, 3, 2]
            }
        }
    }

    public enum PublicKeyAlgorithm: Hashable {
        case p256
    }
}

extension Certificate.SignatureAlgorithm: ASN1Convertible {
    var asn1Tree: some ASN1Node {
        ASN1Seq {
            oid
        }
    }
}

extension Certificate.PublicKeyAlgorithm: ASN1Convertible {
    var asn1Tree: some ASN1Node {
        let x962: OID = [1, 2, 840, 10045]
        let ecPublicKey = x962.adding(2, 1)

        return ASN1Seq {
            ecPublicKey

            switch self {
            case .p256:
                let p256v1 = x962.adding(3, 1, 7)
                p256v1
            }
        }
    }
}

extension Certificate {
    public struct Name: Equatable {
        public var commonName: String?
        public var emailAddress: String?

        public init(commonName: String? = nil, emailAddress: String? = nil) {
            self.commonName = commonName
            self.emailAddress = emailAddress
        }
    }
}

extension Certificate.Name: ASN1Convertible {
    var asn1Tree: some ASN1Node {
        ASN1Seq {
            if let commonName = commonName {
                ASN1Set {
                    ASN1Seq {
                        OID.commonName
                        commonName
                    }
                }
            }

            if let emailAddress = emailAddress {
                ASN1Set {
                    ASN1Seq {
                        OID.emailAddress
                        ASN1.IA5String(emailAddress)
                    }
                }
            }
        }
    }
}

extension Certificate {
    public struct Validity: Equatable {
        public var notBefore: Date
        public var notAfter: Date?

        public init(from notBefore: Date, to notAfter: Date? = nil) {
            self.notBefore = notBefore
            self.notAfter = notAfter
        }
    }
}

extension Certificate.Validity: ASN1Convertible {
    var asn1Tree: some ASN1Node {
        ASN1Seq {
            notBefore
            notAfter ?? Date.distantFuture
        }
    }
}

extension Certificate {
    public enum SubjectPublicKeyInfo {
        case p256(P256.Signing.PublicKey)
        case p384(P384.Signing.PublicKey)
        case p521(P521.Signing.PublicKey)
    }
}

extension Certificate.SubjectPublicKeyInfo: ASN1Convertible {
    var asn1Tree: some ASN1Node {
        switch self {
        case .p256(let publicKey):
            return RawDER(data: publicKey.derRepresentation)

        case .p384(let publicKey):
            return RawDER(data: publicKey.derRepresentation)

        case .p521(let publicKey):
            return RawDER(data: publicKey.derRepresentation)
        }
    }
}

extension Certificate {
    public enum PrivateKey {
        case p256(P256.Signing.PrivateKey)
        case p384(P384.Signing.PrivateKey)
        case p521(P521.Signing.PrivateKey)

        func signature(for digest: any Digest) throws -> Data {
            switch self {
            case .p256(let key):
                return try key.signature(for: digest).derRepresentation

            case .p384(let key):
                return try key.signature(for: digest).derRepresentation

            case .p521(let key):
                return try key.signature(for: digest).derRepresentation
            }
        }
    }
}

extension Certificate {
    public struct Extensions: ASN1Convertible {

        public var extendedKeyUsage: ExtendedKeyUsage?
        public var subjectAltName: SubjectAltName?

        public init(extendedKeyUsage: ExtendedKeyUsage? = nil, subjectAltName: SubjectAltName? = nil) {
            self.extendedKeyUsage = extendedKeyUsage
            self.subjectAltName = subjectAltName
        }

        var asn1Tree: some ASN1Node {
            ASN1Seq {
                if let extendedKeyUsage = extendedKeyUsage {
                    extendedKeyUsage
                }

                if let subjectAltName = subjectAltName {
                    subjectAltName
                }
            }
        }
    }

    public enum ExtendedKeyUsage: ASN1Convertible {
        case serverAuth
        case clientAuth
        case codeSigning
        case emailProtection
        case any

        var use: OID {
            switch self {
            case .serverAuth:
                return [1, 3, 6, 1, 5, 5, 7, 3, 1]

            case .clientAuth:
                return [1, 3, 6, 1, 5, 5, 7, 3, 2]

            case .codeSigning:
                return [1, 3, 6, 1, 5, 5, 7, 3, 3]

            case .emailProtection:
                return [1, 3, 6, 1, 5, 5, 7, 3, 4]

            case .any:
                return [2, 5, 29, 37, 0]
            }
        }

        public var critical: Bool {
            false
        }

        var asn1Tree: some ASN1Node {
            ASN1Seq {
                OID.extendedKeyUsageOID
                critical
                use
            }
        }
    }

    public struct SubjectAltName: ASN1Convertible {

        public var critical = false

        public let altName: String

        public init(altName: String) {
            self.altName = altName
        }

        var asn1Tree: some ASN1Node {
            ASN1Seq {
                OID.subjectAltNameOID
                critical
                altName
            }
        }
    }
}

extension Certificate.TBSCertificate {
    /// Generates a certificate signed using ECDSA with SHA256.
    public func sign(with privateKey: Certificate.PrivateKey) throws -> Certificate {
        precondition(self.signature == .ecdsaWithSHA256)

        let toSign = Data(toDER())
        var sha256 = SHA256()
        sha256.update(data: toSign)
        let digest = sha256.finalize()
        let signature = try privateKey.signature(for: digest)

        return Certificate(
            tbsCertificate: self,
            signatureValue: .init(data: signature))
    }
}
