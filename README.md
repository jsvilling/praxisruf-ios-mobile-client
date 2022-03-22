# Praxisruf Mobile Client for iOS

## Description

This application is part of the Praxisruf system.

The Mobile Client can be used to send/receive Notifications and to open voice connections to other Mobile Clients. 

All notifications are sent to the [Praxisruf Cloud Service](https://github.com/jsvilling/praxisruf-cloud-service) .
The Mobile Client sends notifications to the Cloud Service and receives them via Firebase Messaging.

Voice connections are implemented using WebRTC. 
Signaling Exchange is solved via Websocket Connections to the Cloudservice. 

All notifications and voice connections are initiated via buttons in the user interface. 
These buttons can be confiugred in the Admin UI. 
​

More detailed information on the system can be found in the project reports [Cloudbasiertes Praxisrufsystem](https://github.com/IP5-Cloudbasiertes-Praxisrufsystem/IP5-documentation/blob/main/out/cloudbasiertes_praxisrufsystem.pdf) and [Peer-to-Peer Kommunikation für Sprachübertragung in einem Praxisrufsystem](https://github.com/jsvilling/IP6_Bachelorarbeit_Bericht_Cloudbasiertes_Praxisrufsystem/blob/master/out/p2p_sprachubertragung_in_praxisrufsystem.pdf). 


## Development Setup

* Open the project in XCode
* Set the values for BASE_URL_HTTPs and BASE_URL_WSS in the User Defined section of build settings
* Copy the GoogleService-Info.plist file for your Firebase Cloud Messaging Project into the Resources directory. 
* Consult the [Installation Manual](https://github.com/jsvilling/IP6_Bachelorarbeit_Bericht_Cloudbasiertes_Praxisrufsystem/blob/master/out/p2p_sprachubertragung_in_praxisrufsystem.pdf) (Appendix D) for more information on initial setup.