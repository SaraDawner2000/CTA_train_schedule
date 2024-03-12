# CTA-train-schedule

This app allows the user to look up the arrival times of CTA trains on a selected station. 

## Mechanics
### Landing page
The landing page has 
1. A drop-down menu with a list of "parent" stations (from the CTA documentation, the "entry that covers the entire station facility", both directions and any separate lines), pulled from the stops.csv file taken from [here](https://www.transitchicago.com/downloads/sch_data/)
2. A form button that submits the station you chose from the drop-down menu
3. A form button that submits the last station you selected before from the cookie hash (if there isn't a cookie yet, it submits the first station on the list, "18th")
### Results page
The results page shows all the arriving trains for this parent station, sorted first by line and then by direction. The line is indicated by text and by an icon matching the color of the line with the official CTA "L" train logo (the hex color codes are taken from the CTA's official style guide).

The arrival times are formatted to "%I:%M:%S %p". Information about whether the train is likely arriving or likely delayed is available in the server response, so if either (or both) are true, or marked as "1" in the response, text comes up after the time of arrival indicating it.

There is a "Refresh" button, which resubmits the station selected, and a "Back" button, which takes the user back to the landing page.
## Possible upgrades
A way for the user to filter the results by available line and direction, and a way of saving that information to a cookie, may be implemented, and would be helpful for the larger stations.

Currently the web service cannot differenciate between regular stations and final stops. For instance, for Kimball station, which is the final stop of the Brown line, the results page shows the arriving trains as "Kimball-bound", which can be confusing. A mechanic for generating the final stops results pages differently than the rest can be implemented.

Currently the "arriving" and "delayed" indicators are just plain text after the time of arrival. They can be made stronger with brighter colors and perhaps even an animated feature to improve visibility.
## Forking the app
After forking the app, run "bin/setup" in the terminal to install the required dependencies, and run "bin/dev" to start the app in puma.
