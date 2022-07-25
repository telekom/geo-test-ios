# GeofenceTester iOS &middot; < --- ADDITIONAL INFO ICONS FOR LICENSE, VERSIONS (npm etc), CI STATUS, PRS WELCOME USING https://shields.io  --- >
 
A project to test the accuracy of iOS geofence and visits monitoring
 
## Installation
 
* Clone the project
* Adjust Code Signing Team as appropriate
* IF you want to use [MS AppCenter](https://appcenter.ms) for distribution AND you have an API Key, enter it in `GeofenceTester/Keys.swift`. **REMEMBER** Do not commit your secret keys to a public repository, push request, etc.
* Build and run with Xcode 13.4 or later
 
## Documentation
 
This is a sample app to test the accurarcy of iOS geofencing and vists monitoring. You can create new geofences, and you will receive a push notification when these geofences are entered or exited.

You will also receive a push message whenever iOS detects a 'Visit'.

All of these events are logged, the log can be shared using the usual iOS sharing tools.

## Accessibility

The goal for this tool is to be accessible. It includes a custom Voiceover rotor for the map. 
 
You can improve it by sending pull requests to [this repository](< --- URL --- >).
 
### License
 
This code is under the MIT Licencse
