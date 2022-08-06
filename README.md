# Project 3 - *Trail Blaze*

**Trail Blaze** is a running/biking app using Parse as its backend.

Time spent: **27** days spent in total

## Weekly Milestones
Week 1 - July 4
Setting up basic view controllers
Setting up MapKit
[TrailRun] Track users location
[TrailRun] Drawing route

Week 2 - July 11
[TrailRun] Set up data structure for Route
Start point
End point
Duration
StartTime
EndTime
MKRoute Object
[TrailRun] Save routes + Networking
 [Social] Introduce multiple users
Set up profile tab to show list of Friends 
Implement user search
Add running status and last known location fields to User model
Add friends, outgoing friend requests and incoming friend requests fields to User model.
Implement adding friends 
Implement accepting requests


Week 3 - July 18
[x][TrailRun] Create Run Model
[x]Create model locally
[x]Create jsonify function in Run class to dissolve MKRoute into json
[x][TrailRun] Save routes + Networking
[x]Make networking class
Create functions for querying current user data + other user data
Function to query friends for friends list
Function to periodically query running status
Function to periodically query running friend’s location
Function to periodically post user currentLocation
Set Up User profile
Show list of User’s Past Runs
Add ability to change profile image
Add profile image field to User class
Implement function to upload user profile photo to parse server

[Social] Intercept friends
Allow user to access friend’s live/most recent location
Prompt friend of Intercept request
Calculate intercept route if possible and start TrailRun
Write function to collect and thin out coordinates on a route
Truncate the coordinates already passed by active runner
Calculate and compare ETAs to the remaining points for both users
Use multiple threads to send all eta requests to maps api simultaneously
Render intercept path using a new MKPolylineRenderer in a different color

Week 4 - July 25
Intercept feature
Prompt for initial runner to approve intercept request
Visual of intercepting path for initial runner
Live location pin for initial runner to see interceptor live location
Pace Improvement Tracking feature
Write implementation proposal for PIT feature
Research Core Motion and/or HealthKit
Look more into using CMPedometer
Setup Parse LIve Query
Remodel Networking class

Week 5 - August 1 
Project should be 90% complete (all core features built, progress on stretch goals)
Pace Improvement Tracking feature
Add field "pacesArray" Run object in parse.
Create PaceImprovementTracking class
write function to determine if user is a the start of the run route
write function to determine if user has moved past a polyline point
write function to compare current average pace of the passed region to best average pace in the past reruns of this route
write function to rank current rerun against past reruns to determine whether to save this run as best to improve upon in a later rerun.
Add code to save a dictionary of {point:pace} pairs for every Run
Add "else if" blocks to polyline renderer in HomeViewController to render red or blue polylines depending on better or worse performance over a given stretch of the route.
Other
Research Geofencing for placing region triggers on route
Add three finger touch gesture to toggle satellite and standard view on map
Add animation for run timer as start and end of run
Add external visual library polish (custom activity indicator)
Refactor
Expand Utils class
Reorganize file system


The following **required** functionality is completed:

## Video Walkthroughs
- [Intercept Feature](https://pxl.cl/29mkX)
- [Friends (Social) Feature]
    

![ezgif com-gif-maker (3)](https://user-images.githubusercontent.com/74246331/183229876-84fabb0c-5601-40ef-8f2c-c01e2cffda35.gif)

Here's a walkthrough of implemented user stories:

## Credits

- [AFNetworking](https://github.com/AFNetworking/AFNetworking) - Networking task library
- [Parse](https://github.com/parse-community) - Database library
- [DGActivityIndicator](https://github.com/ninjaprox/DGActivityIndicatorView) - External visual polish library


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
