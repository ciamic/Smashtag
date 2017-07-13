# Smashtag
> Twitter made easy!

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
[![Platform][platform-image]][platform-url]
[![PRs Welcome][prswelcome-image]][prswelcome-url]  
  
[![Download on the App Store](https://s18.postimg.org/r6olllkp5/appstore.png)](https://itunes.apple.com/us/app/smashtag/id1257925504)

Smashtag is an app developed as part of the [Stanford University's CS193p 2017 course](https://itunes.apple.com/us/course/developing-ios-10-apps-with-swift/id1198467120), in particular is the result of the [Programming Assignment IV](https://www.scribd.com/document/351739364/Programming-Project-4-Smashtag-Mentions) and [Programming Assignment V](https://www.scribd.com/document/351739353/Programming-Project-5-Smashtag-Mention-Popularity).  

  
Users can search for hashtags or twitter users in order to discover the most recent tweets on the subject.  
They can at this point navigate through found Tweets and start exploring hashtags and mentions of each Tweet continuing the search.  
They can also show all the images linked to the Tweets or, whenever necessary, use the Core Data facilities to query the informations found so far: tweeters, hashtags and user mentions for each searched term.  

  
The purpose of the project is to learn how to persist application data and how to make some analysis on all of the mentions in a search result using Core Data.    
  

[![Simulator Screen Shot 20 Jun 2017, 21.27.32.png](https://s7.postimg.org/go0bmkn1n/Simulator_Screen_Shot_20_Jun_2017_21.27.32.png)]()
[![Simulator_Screen_Shot_20_Jun_2017, 21.30.46.png](https://s3.postimg.org/mwu97htxv/Simulator_Screen_Shot_20_Jun_2017_21.30.46.png)]()
[![Simulator_Screen_Shot_20_Jun_2017, 21.34.31.png](https://s3.postimg.org/u5ahaiw2b/Simulator_Screen_Shot_20_Jun_2017_21.34.31.png)]()
[![Simulator_Screen_Shot_20_Jun_2017, 21.34.47.png](https://s3.postimg.org/cgiqiwkb7/Simulator_Screen_Shot_20_Jun_2017_21.34.47.png)]()
[![Simulator_Screen_Shot_20_Jun_2017, 21.35.18.png](https://s3.postimg.org/p3yhvez83/Simulator_Screen_Shot_20_Jun_2017_21.35.18.png)]()
[![Simulator_Screen_Shot_20_Jun_2017, 21.35.25.png](https://s3.postimg.org/phztv0jbn/Simulator_Screen_Shot_20_Jun_2017_21.35.25.png)]()
[![Simulator_Screen_Shot_20_Jun_2017, 21.35.42.png](https://s3.postimg.org/4vb49ozwz/Simulator_Screen_Shot_20_Jun_2017_21.35.42.png)]()
  
  
## Requirements
- iOS 10.0+
- Xcode 8.0+
- Twitter account
- The [Stanford Twitter Framework][stanford-twitter-framework-v3] to be included in a Workspace with the Smashtag Project (included in the repository).

## Third Party Libraries
- The [Stanford Twitter Framework][stanford-twitter-framework-v3] is required in order to query Twitter informations.

## License
Smashtag is released under the MIT license. See [LICENSE](LICENSE) for details.  

The [Stanford Twitter Framework][stanford-twitter-framework-v3] is licensed under a [Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License](https://creativecommons.org/licenses/by-nc-sa/3.0/us/).

[stanford-twitter-framework-v3]:http://web.stanford.edu/class/cs193p/Twitter3.zip
[swift-image]:https://img.shields.io/badge/swift-3.0-orange.svg
[swift-url]: https://swift.org/
[license-image]:https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[platform-image]:https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat
[platform-url]:https://cocoapods.org/pods/LFAlertController
[prswelcome-image]:https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square
[prswelcome-url]:https://makeapullrequest.com
