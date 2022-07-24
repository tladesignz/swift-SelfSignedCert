# SelfSignedCert

This is a fork of [svdo's SelfSignedCert](https://github.com/svdo/swift-SelfSignedCert). However I do not plan to upstream any changes, since I basically rewritten everything.

This library has the following notable features:

- It can self-sign an X.509 certificate with a P-256 key, using the ECDSA with SHA256 signature algorithm.
- It has no dependencies other than Apple's [swift-crypto](https://github.com/apple/swift-crypto), which it this cross-platform. It can run both on newer Apple platforms (iOS 14 or later), and on Linux.
- It follows modern Swift practices. You do not need to mess up your keychain just to generate private keys or certificates.
- Of course, that means you need to manually store those things in the keychain. But this means composability. You can use any libraries of your choice to do just that.

The code however, is still very experimental. It has a very basic set of attributes supported: you can set a common name and an e-mail address. No more. Also no X.509 extensions. Hopefully I will improve this in the future.

## Why do I start this project?

I need to implement offline data synchronization. I want to use [Multipeer Connectivity](https://developer.apple.com/documentation/multipeerconnectivity). I need the data synchronization channel to be secure, which means I need to enable both encryption and authentication — the latter is required to avoid man-in-the-middle attack. Authentication requires a `SecIdentity`, which requires me to provide a private key and a certificate signed by that key, which leads me here.

The rough idea:

- The app would assign a UUID to each device.
- The app would generate a private key for each device and store the public key on the user’s iCloud keychain, identified by the generated device UUID.
- On accepting peers to a `MCSession`, the app would check the certificate and its common name (which would be the device UUID) against the iCloud keychain.

I would write a blog post once I get a working app.

## Original README.

3, 2, 1. Go!

===

![Swift Version 5](https://img.shields.io/badge/Swift-v5-yellow.svg)
[![CocoaPods Version Badge](https://img.shields.io/cocoapods/v/SelfSignedCert.svg)](https://cocoapods.org/pods/SelfSignedCert)
[![License Badge](https://img.shields.io/cocoapods/l/SelfSignedCert.svg)](LICENSE.txt)
![Supported Platforms Badge](https://img.shields.io/cocoapods/p/SelfSignedCert.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

This project provides a Swift framework that allows you to create self-signed
certificates on iOS, using Swift. Unfortunately, Apple does not provide this
functionality in their security frameworks. Another way of doing it is using
OpenSSL, but (especially when using Swift) that is downright horrible.

The code in this library is a (partial) port of
[MYCrypto](https://github.com/snej/MYCrypto). That project contains unmaintained
Objective-C code, which was difficult to use as a CocoaPod and especially also
when using Swift. So I took that part that I needed and implemented that in
Swift.

Please note that I'm not a security expert. This framework has not been reviewed
by a security expert. Until it has, please use with caution! And in any case
(reviewed or not), using it is always at your own risk of course.

If you are a security expert and you want to review this framework, please
contact me.
