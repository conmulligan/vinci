# Vinci

[![CI Status](https://img.shields.io/travis/conmulligan/Vinci.svg?style=flat)](https://travis-ci.org/conmulligan/Vinci)
[![Version](https://img.shields.io/cocoapods/v/Vinci.svg?style=flat)](https://cocoapods.org/pods/Vinci)
[![License](https://img.shields.io/cocoapods/l/Vinci.svg?style=flat)](https://cocoapods.org/pods/Vinci)
[![Platform](https://img.shields.io/cocoapods/p/Vinci.svg?style=flat)](https://cocoapods.org/pods/Vinci)

Vinci is an asynchronous image downloader and cache for iOS.

Note: Vinci is early in development and, although stable, is missing some important features.

## Roadmap

### Done
- Asychronous image downloading.
- Download queue.
- Transformation closures.
- Combined memory and disk cache.

### Outstanding
- Automatic cache expiration.
- Support for caching images post-transformation.

## Usage

You can use the shared `Vinci` singleton and the `request` factory method to fetch an image like so:

```swift
Vinci.shared.request(with: url) { (image, isCached) in
    imageView.image = image
}
```

You can pass an optional transformation closure to modify the image before it's passed to the completion handerl:

```swift
Vinci.shared.request(with: url, transformHandler: { (image) -> UIImage in
    return transform(image)
}) { (image, isCached) in
    cell.photoView.image = image
}
```

A `Vinci` instance can also initialized with custom `URLSession` and `VinciCache` instances:

```swift
let session = URLSession.shared
let cache = VinciCache()
let vinci = Vinci(session: session, cache: cache)
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Vinci is available through [CocoaPods](https://cocoapods.org). To install it, add the following line to your Podfile:

```ruby
pod 'Vinci'
```

## Author

conmulligan, conmulligan@gmail.com

## License

Vinci is available under the MIT license. See the LICENSE file for more info.
