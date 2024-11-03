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

The application follow MVVM-C. Most of the UX flow is in the **UX** folder, separated out between Coordinators, View Models and Views. Models are in **Models**, **Configuration** holds not only the user configurations we support (preferred temperature units, language and whether we want to always use the user's location when starting the app), it also has some dev environment variables (namely the base url and a link to our API key). The **Network** folder stores our HTTP client, a wrapper around CLLocationManager that makes it conform better with Async/Await, and our APIManager, which controls how we interface with OpenWeather's API, which is added via dependency injection to our coordinators and view models. 

**ForecastView** has some initial support for portrait/landscape orientation (turning the device changes the view shows, showing only the future forecast when in landscape), as well as size classes (the Future Forecast view is made larger if the horizontal size class is **.regular** rather than **.compact**)

All text search entries are passed through OpenWeather's Geocoder API first before we retrieve a forecast. 

No third party libraries were used. As a reult, decided against implementing an image cache, as Kingfisher and other libraries exist to handle that and the work itself is rote. 

## Notes

Localization is incomplete. We have a Strings dictionary for most of the hardcoded string values, but we need to verify that this is the case, and then proceed to get translations for each of the supported languages. However, we are able to retrieve OpenWeather data with a specified language. 

Also, I decided to use Swift Testing instead of XCTest, as I took the opportunity to familiarize myself more with it. There's also some rudimentary XCUITests for UI testing. Naturally, we should expand more and test deviations from the happy path. 

Alas, accessibility support is minimal (some accessibilityLabels and an accessibilityHint in the **ForecastView**). One clear improvement would be to add buttons to the each side of the multi-day forecast to make it easier for VoiceOver users to scroll through the available hourly forecast options.
