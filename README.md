<h1 align="center">
    GeofenceTester iOS
</h1>

<p align="center">
    <a href="/../../commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/telekom/geo-test-ios?style=flat"></a>
    <a href="/../../issues" title="Open Issues"><img src="https://img.shields.io/github/issues/telekom/geo-test-ios?style=flat"></a>
    <a href="./LICENSE" title="License"><img src="https://img.shields.io/badge/License-MIT-green.svg?style=flat"></a>
</p>

<p align="center">
  <a href="#about-this-component">About This Component</a> •
  <a href="#build">Build</a> •
  <a href="#support-and-feedback">Support</a> •
  <a href="#how-to-contribute">Contribute</a> •
  <a href="#licensing">Licensing</a>
</p>

A project to test the accuracy of iOS geofence and visits monitoring

## About this component

This is a sample app to test the accurarcy of iOS geofencing and vists monitoring. You can create new geofences, and you will receive a push notification when these geofences are entered or exited.

You will also receive a push message whenever iOS detects a 'Visit'.

All of these events are logged, the log can be shared using the usual iOS sharing tools.

Please use the App for your own testing, and feel free to contribute!

### Accessibility

The goal for this tool is to be accessible. It includes a custom Voiceover rotor for the map. 

## Build

* Clone the project
* Adjust Code Signing Team as appropriate
* IF you want to use [MS AppCenter](https://appcenter.ms) for distribution AND you have an API Key, enter it in `GeofenceTester/Keys.swift`. **REMEMBER** Do not commit your secret keys to a public repository, push request, etc.
* Build and run with Xcode 13.4 or later
 
## Code of Conduct

This project has adopted the [Contributor Covenant](https://www.contributor-covenant.org/) in version 2.0 as our code of conduct. Please see the details in our [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). All contributors must abide by the code of conduct.

## Working Language

We decided to apply _English_ as the primary project language.  

Consequently, all content will be made available primarily in English. We also ask all interested people to use English as language to create issues, in their code (comments, documentation etc.) and when you send requests to us. The application itself and all end-user facing content will be made available in other languages as needed.

## Support and Feedback

The following channels are available for discussions, feedback, and support requests:

| Type                     | Channel                                                |
| ------------------------ | ------------------------------------------------------ |
| **Issues**   | <a href="/../../issues/new/choose" title="General Discussion"><img src="https://img.shields.io/github/issues/telekom/geo-test-ios?style=flat-square"></a> </a>   |
| **Other Requests**    | <a href="mailto:opensource@telekom.de" title="Email Open Source Team"><img src="https://img.shields.io/badge/email-Open%20Source%20Team-green?logo=mail.ru&style=flat-square&logoColor=white"></a>   |

## How to Contribute

Contribution and feedback is encouraged and always welcome. For more information about how to contribute, the project structure, as well as additional contribution information, see our [Contribution Guidelines](./CONTRIBUTING.md). By participating in this project, you agree to abide by its [Code of Conduct](./CODE_OF_CONDUCT.md) at all times.

## Licensing

Copyright (c) 2022 Deutsche Telekom AG.

Licensed under the **MIT License** (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License by reviewing the file [LICENSE](./LICENSE) in the repository.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the [LICENSE](./LICENSE) for the specific language governing permissions and limitations under the License.
