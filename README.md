NewsApp
==============
This is application which display and filter news for last 7 days

***Content:***
- [Introduction](#Introduction)
- [Description of work and capabilities of the application](#Description)
- [Preparation and launch](#Preparing)



# Introduction <a name="Introduction"></a>

**NewsApp** —  it is a application than can show news for the last 7 days and news on request. Free API is used to receive news (https://newsapi.org). The KingFisher library is also used for asynchronous downloading and caching of images (https://github.com/onevcat/Kingfisher). 

# Description of work and capabilities of the application <a name="Description"></a>

1. When launched, application show news from three domains (wsj, techcrunch, thenextweb) for the last day, when the news list ends, the news from the previous day is automatically loaded and so on until the end of the week.
When reopening, the same news will be displayed, in order to get the actual news, you must press refresh button.

2. Also in the application there is a possibility of displaying news from request, for this you need to enter a query in the search bar.
To return to the news by day, you can use refresh button or send a empty request.

# Preparation and launch<a name="Preparing"></a>

1. Download this repository to your computer.

2. Open project with Xcode.

3. Install CocoaPods and KingFisher library.

4. Initialize pods data in the project folder.

5. Replace the text of the PodFile with the following, run the project.

```
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'NewsApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
pod 'Kingfisher'
  # Pods for NewsApp

end
```
 




  



