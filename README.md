# Tangynt

[![CI Status](https://img.shields.io/travis/Jfmetcalf5/Tangynt.svg?style=flat)](https://travis-ci.org/Jfmetcalf5/Tangynt)
[![Version](https://img.shields.io/cocoapods/v/Tangynt.svg?style=flat)](https://cocoapods.org/pods/Tangynt)
[![License](https://img.shields.io/cocoapods/l/Tangynt.svg?style=flat)](https://cocoapods.org/pods/Tangynt)
[![Platform](https://img.shields.io/cocoapods/p/Tangynt.svg?style=flat)](https://cocoapods.org/pods/Tangynt)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

Tangynt is available through [CocoaPods](https://cocoapods.org/pods/tangynt). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Tangynt'
```

## Setup
 
* Once you have created a project at the [Tangynt website](Tangynt.com), copy the api-key associated with your project and put this line of code **`Tangynt("{Your API Key Here}")`** in your AppDelegate's didFinishLaunchingWithOptions method
> Don't forget to import Tangynt at the top!

# Need-To-Know
## Users
* If your app uses users make sure you have your user object conform to the `TangyntUser` object which will set up the base user
>You don't need to do anything else, this just gives you the *id, emailVerified, email, password* and *displayName* properties

#### Log In
* The `login` method in the background will save a **TangyntLoginResponse** which holds the users `AuthToken` and `refreshToken` which you can access by either calling `Tangynt.api.getAuthToken()` or `Tangynt.api.getRefreshToken()`

**TangyntAuthToken properties**<br />
id: String<br />
issuedAt: Int64<br />
expires: Int64<br />

**TangyntRefreshToken properties** <br />
id: String<br />
client: String<br />
issuedTo: Int64<br />
issuedAt: Int64<br />
expires: Int64<br />
deactivated: Bool<br />

#### Log Out
* Tangynt has a `logout` method you can call which will clear the currently signed in users data as well as the LoginResponse object.
* If you would like to do anything before the user is logged out, Tangynt has a closure proprety called `onLogout: () -> ()` you can set that will get called **after** `logout` is called but **before** the users data is cleared

#### Authorized Requests
* Any authorized request where the `TangyntAuthToken` is used will retry 3 times **if** the response code is a 401.  After the third failed attempt the `logout` method will be called and the user will be required to log in again

## Objects
* Make sure you have your objects conform to the `TangyntObject` object
   * You can leave `var id: Int64` alone
   * `var objectName: String` needs to be the string representation of your object
   >If my object was `class TheCoolestObject {}`, my objectName would be `var objectName = "TheCoolestObject"`

## Files
* Make sure you have your file objects conform to the `TangyntFile` object
>Similar to the `TangyntUser` object, you don't need to do anything else when creating a file object class

>FYI
The `login(...)`, `getObjects(...)` and `getFiles(...)` methods require you to put the user/object/file **instance type** in as a parameter, so Tangynt will be able to decode them accordingly.  Every other method will simple take the user/object/file **instance**

# HAPPY CODING!

## Author

Tangynt LLC, support@tangynt.com

## License

Tangynt is available under the MIT license. See the LICENSE file for more info.
