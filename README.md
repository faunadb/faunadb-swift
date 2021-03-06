# Commmunity-supported Swift Driver for [FaunaDB](https://fauna.com)

FaunaDB's Swift driver is now "community-supported". New features won't be exposed in the driver unless the necessary changes are contributed by a community member. Please email product@fauna.com if you have any questions/concerns, or would like to take a more active role in the development of the driver (eg. partnering with us and operating as a "maintainer" for the driver).

[![CocoaPods](https://img.shields.io/cocoapods/v/FaunaDB.svg)](http://cocoapods.org/pods/FaunaDB)
[![Coverage Status](https://codecov.io/gh/fauna/faunadb-swift/branch/main/graph/badge.svg)](https://codecov.io/gh/fauna/faunadb-swift)
[![License](https://img.shields.io/badge/license-MPL_2.0-blue.svg?maxAge=2592000)](https://raw.githubusercontent.com/fauna/faunadb-swift/main/LICENSE)

A Swift driver for [FaunaDB](https://fauna.com)

## Supported Platforms

* iOS 9.0+ | OSX 10.10+ | tvOS 9.0+ | watchOS 2.0+
* Xcode 8
* Swift 3

## Documentation

Check out the Swift-specific [reference documentation](http://fauna.github.io/faunadb-swift/).

You can find more information in the FaunaDB [documentation](https://docs.fauna.com/)
and in our [example project](https://github.com/fauna/faunadb-swift/tree/main/Example).

## Using the Driver

### Installing

CocoaPods:

```
pod 'FaunaDB', '~> 2.0.0'
```

Carthage:

```
github 'fauna/faunadb-swift'
```

SwiftPM:

```swift
.Package(url: "https://github.com/fauna/faunadb-swift.git", Version(2, 0, 0))
```

### Basic Usage

```swift
import FaunaDB

struct Post {
    let title: String
    let body: String?
}

extension Post: FaunaDB.Encodable {
    func encode() -> Expr {
        return Obj(
            "title" => title,
            "body" => body
        )
    }
}

extension Post: FaunaDB.Decodable {
    init?(value: Value) throws {
        try self.init(
            title: value.get("title") ?? "Untitled",
            body: value.get("body")
        )
    }
}

let client = FaunaDB.Client(secret: "your-key-secret-here")

// Creating a new post
try! client.query(
    Create(
        at: Class("posts")
        Obj("data" => Post("My swift app", nil))
    )
).await(timeout: .now() + 5)

// Retrieve a saved post
let getPost = client.query(Get(Ref(class: Class("posts"), id: "42")))
let post: Post = try! getPost.map { dbEntry in dbEntry.get("data") }
    .await(timeout: .now() + 5)
```

For more examples, check our online [documentation](https://docs.fauna.com/)
and our [example project](https://github.com/fauna/faunadb-swift/tree/main/Example).

## Contributing

GitHub pull requests are very welcome.

### Driver Development

You can compile and run the test with the following command:

```
FAUNA_ROOT_KEY=your-keys-secret-here swift test
```

## LICENSE

Copyright 2018 [Fauna, Inc.](https://fauna.com/)

Licensed under the Mozilla Public License, Version 2.0 (the
"License"); you may not use this software except in compliance with
the License. You may obtain a copy of the License at

[http://mozilla.org/MPL/2.0/](http://mozilla.org/MPL/2.0/)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.
