# Project 3 - *Trail Blaze*

**Trail Blaze** is a running app using Parse as its backend.
TrailBlaze is essentially a running fitness app that tracks your improvement over time and allows you to make your run more exciting by allowing friends to join you during the course of your runs. This idea arose from a conversation I had with my intern mates in which the majority of them expressed some interest in running/hiking. I initially began as a general purpose running and hiking app but was later geared towards running alone. Setting up the social aspects such as sending and receiving friend requests as well as keeping track of intercepting friend’s and their live data was pretty challenging. For this I had to learn about threads and asynchronous functions, as well as building a view programmatically (without the use of the storyboard). This was all encompassed in the Intercept feature, one of two technically ambiguous challenges in the app’s development. The second being the Pace Improvement Tracking feature (or PIT) which involves showing the user their improvement live on running a specific route as they traverse it over multiple runs. 

Time spent: **27** days spent in total

## Video Walkthroughs
- [Intercept Feature]


![ezgif com-gif-maker (5)](https://user-images.githubusercontent.com/74246331/183230386-82448b54-816c-4a9a-ace7-894e58ec773a.gif)



- [Friends (Social) Feature]


![ezgif com-gif-maker (3)](https://user-images.githubusercontent.com/74246331/183229876-84fabb0c-5601-40ef-8f2c-c01e2cffda35.gif)


- [Pace Improvement Tracking Feature]

## Weekly Milestones
**Week 1 - July 4**
- [x] Setting up basic view controllers
- [x] Setting up MapKit
- [x] [TrailRun] Track users location
- [x] [TrailRun] Drawing route

**Week 2 - July 11**
- [x] [TrailRun] Set up data structure for Route
	- [x] Start point
	- [x] End point
	- [x] Duration
	- [x] StartTime
	- [x] EndTime
	- [x] MKRoute Object
- [x] [TrailRun] Save routes + Networking
- [x] [Social] Introduce multiple users
	- [x] Set up profile tab to show list of Friends 
	- [x] Implement user search
	- [x] Add running status and last known location fields to User model
	- [x] Add friends, outgoing friend requests and incoming friend requests fields to User model.
	- [x] Implement adding friends 
	- [x] Implement accepting requests


**Week 3 - July 18**
- [x] [TrailRun] Create Run Model
	- [x] Create model locally
	- [x] Create jsonify function in Run class to dissolve MKRoute into json
- [x] [TrailRun] Save routes + Networking
    - [x] Make networking class
	- [x] Create functions for querying current user data + other user data
	- [x] Function to query friends for friends list
	- [x] Function to periodically query running status
	- [x] Function to periodically query running friend’s location
	- [x] Function to periodically post user currentLocation
	- [x] Set Up User profile
	- [x] Show list of User’s Past Runs
	- [x] Add ability to change profile image
	- [x] Add profile image field to User class
	- [x] Implement function to upload user profile photo to parse server

- [x] [Social] Intercept friends
	- [x] Allow user to access friend’s live/most recent location
	- [x] Prompt friend of Intercept request
	- [x] Calculate intercept route if possible and start TrailRun
	- [x] Write function to collect and thin out coordinates on a route
	- [x] Truncate the coordinates already passed by active runner
	- [x] Calculate and compare ETAs to the remaining points for both users
	- [x] Use multiple threads to send all eta requests to maps api simultaneously
	- [x] Render intercept path using a new MKPolylineRenderer in a different color

**Week 4 - July 25**
- [x] Intercept feature
	- [x] Prompt for initial runner to approve intercept request
	- [x] Visual of intercepting path for initial runner
	- [x] Live location pin for initial runner to see interceptor live location
	- [x] Pace Improvement Tracking feature
	- [x] Write implementation proposal for PIT feature
	- [x] Research Core Motion and/or HealthKit
	- [x] Look more into using CMPedometer
	- [x] Setup Parse LIve Query
	- [x] Remodel Networking class

**Week 5 - August 1**

- [x] Pace Improvement Tracking feature
	- [x] Add field "pacesArray" Run object in parse.
	- [x] Create PaceImprovementTracking class
	- [x] write function to determine if user is a the start of the run route
	- [x] write function to determine if user has moved past a polyline point
	- [x] write function to compare current average pace of the passed region to best average pace in the past reruns of this route
	- [x] write function to rank current rerun against past reruns to determine whether to save this run as best to improve upon in a later rerun.
	- [x] Add code to save a dictionary of {point:pace} pairs for every Run
	- [x] Add "else if" blocks to polyline renderer in HomeViewController to render red or blue polylines depending on better or worse performance over a given stretch of the route.
	- [x] Other
	- [ ] Research Geofencing for placing region triggers on route
	- [x] Add three finger touch gesture to toggle satellite and standard view on map
	- [x] Add animation for run timer as start and end of run
	- [x] Add external visual library polish (custom activity indicator)
- [x] Refactor
    - [x] Expand Utils class
    - [x] Reorganize file system
- [ ] (Stretch)MKMapSnapshot of the whole run route, save as part of Run Object


## Credits

- [AFNetworking](https://github.com/AFNetworking/AFNetworking) - Networking task library
- [Parse](https://github.com/parse-community) - Database library
- [DGActivityIndicator](https://github.com/ninjaprox/DGActivityIndicatorView) - External visual polish library
- [MapKIT](https://developer.apple.com/documentation/mapkit?language=objc) - Maps framework


## License

    Copyright [2022] [???]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
