## Firebase setup guide
Go to firebase.google.com and create a new project, choose getting started with iOS app.

Register for the app, add `iOS bundle ID` from XCode. For example:
```
com.example.chat-app
```
Download `GoogleService-Info.plist` file and add it into the project directory.

Install Cocoapods:
```
$ sudo gem install cocoapods
```
Create a Podfile if you don't have one:
```
$ pod init
```
Open your Podfile and add:
```
$ pod 'Firebase/Core'
$ pod 'Firebase/Core'
$ pod 'Firebase/Database'
$ pod 'Firebase/Auth'
$ pod 'Firebase/Storage'
```
Save the file and run:
```
$ pod install
```
