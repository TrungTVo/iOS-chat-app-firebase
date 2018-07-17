<img width="825" alt="screen shot 2018-07-17 at 12 10 35 pm" src="https://user-images.githubusercontent.com/20756728/42797700-8ddcbc50-89ba-11e8-8ad5-13153fddda88.png">

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
