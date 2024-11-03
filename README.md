//
//  README.md
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//
# MP-Weather
 A weather app that integrates with OpenWeather.
 
# Instructions to run
Clone the repo into your local directory.

Also, if you plan to run this on your device, make sure there's an appropriate code signing team selected, etc. etc. 

## Attention
Since the app requires an OpenWeather API KEY, you **NEED** to add your own OpenWeather API key to your`secrets.xcconfig` file. The contents of the file are straightforward. 

```
OPENWEATHER_API_KEY = <ENTER YOUR KEY HERE>
```
## Notes
Localization is incomplete. We have a Strings dictionary for most of the hardcoded string values, but we need to verify that this is the case, and then proceed to get translations for each of the supported languages. However, we are able to retrieve OpenWeather data with a specified language. 

Also, I decided to use Swift Testing instead of XCTest, as I took the opportunity to familiarize myself more with it. There's also some rudimentary XCUITests for UI testing. Naturally, we should expand more and test deviations from the happy path. 

