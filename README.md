
# react-native-strava

## Getting started

`$ npm install react-native-strava --save`

### Mostly automatic installation

`$ react-native link react-native-strava`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-strava` and add `RNReactNativeStrava.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNReactNativeStrava.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNReactNativeStravaPackage;` to the imports at the top of the file
  - Add `new RNReactNativeStravaPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-strava'
  	project(':react-native-strava').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-strava/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-strava')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNReactNativeStrava.sln` in `node_modules/react-native-strava/windows/RNReactNativeStrava.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using React.Native.Strava.RNReactNativeStrava;` to the usings at the top of the file
  - Add `new RNReactNativeStravaPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNReactNativeStrava from 'react-native-strava';

// TODO: What to do with the module?
RNReactNativeStrava;
```
  