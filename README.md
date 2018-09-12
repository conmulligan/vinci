# Vinci

[![CI Status](https://img.shields.io/travis/conmulligan/Vinci.svg?style=flat)](https://travis-ci.org/conmulligan/Vinci)
[![Version](https://img.shields.io/cocoapods/v/Vinci.svg?style=flat)](https://cocoapods.org/pods/Vinci)
[![License](https://img.shields.io/cocoapods/l/Vinci.svg?style=flat)](https://cocoapods.org/pods/Vinci)
[![Platform](https://img.shields.io/cocoapods/p/Vinci.svg?style=flat)](https://cocoapods.org/pods/Vinci)

Vinci is an asynchronous image downloader and cache for iOS.

Note: Vinci is early in development and, although stable, is missing some important features.

## Roadmap

### Done
- Asychronous image downloading (0.1.0).
- Download queue (0.1.0).
- Combined memory and disk cache (0.1.0).
- Image transformers (0.2.0).
- Support for caching images post-transformation (0.2.0).

### Outstanding
- Automatic cache expiration.
- `UIImageView` binding.

## Usage

You can use the shared `Vinci` singleton and the `request` factory method to fetch an image like so:

```swift
Vinci.shared.request(with: url) { (image, isCached) in
    imageView.image = image
}
```

A `Vinci` instance can also initialized with custom `URLSession` and `VinciCache` instances:

```swift
let session = URLSession.shared
let cache = VinciCache()
let vinci = Vinci(session: session, cache: cache)
```

### Transformers

You can pass an optional array of `Transformers` to modify the image before it's passed to the completion hander:

```swift
let transformers: [Transformer] = [
    MonoTransformer(color: UIColor.gray, intensity: 1.0),
    ScaleTransformer(size: imageView.frame.size)
]
Vinci.shared.request(with: url, transformers: transformers) { (image, isCached) in
    imageView.image = image
}
```
Vinci includes a number of transformers by default:

* `ScaleTransformer` scales an image to a specific size.
* `MonoTransformer` uses `CIColorMonochrome` to color tint an image.
* `ClosureTransformer` accepts a closure which applies a custom transformation.

Additional transformers can be created by implementing the `Transformer` protocol.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Vinci is available through [CocoaPods](https://cocoapods.org). To install it, add the following line to your Podfile:

```ruby
pod 'Vinci'
```

## Author

Conor Mulligan, conmulligan@gmail.com

## License

Vinci is available under the MIT license. See the LICENSE file for more info.
