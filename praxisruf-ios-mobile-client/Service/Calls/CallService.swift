//
//  CallService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 08.12.21.
//

import Foundation
import WebRTC
import SwiftUI

/// This service integrates intercom and call functionality in the SwiftUI Application.
///
/// CallService implements the protocol CallClientDelegate to integrate the CallClient which contains the actual speech connections.
/// CallService also implements the protocol SignalingDelegate to integrate communication with the signaling instance and coordination
/// the necessary method calls to keep and restore signaling connections.
/// Implementing both protocols allows the CallService to mediate between CallClient, PraxisurfApi+Signaling and UI.
/// On instantiation the CallService creates an instance of CallService and CallClient and registers itself as delegate on these services.
///
/// CallService publishes properties for call realted errors, active call state, active callTypeId, the state of participants of open connections and the name of a open connection.
/// These properties are used in  ActiveCallView and IntercomView
class CallService : ObservableObject {

    @Published var error: Error? = nil
    @Published var active: Bool = false
    @Published var callTypeId: String = ""
    @Published var states: [String:(String, ConnectionStatus)] = [:]
    @Published var callPartnerName: String = ""
    
    var settings: Settings
    
    private var errorCount = 0
    private var pending: Signal? = nil
    private let callClient: CallClient
    private let praxisrufApi: PraxisrufApi
    
    init(settings: Settings = Settings()) {
        self.settings = settings
        praxisrufApi = PraxisrufApi()
        callClient = CallClient()
        callClient.delegate = self
        PraxisrufApi.signalingDelegate = self
    }
    
    /// Establishes a connection to the signaling instance iva PraxisrufAPI and starts listening for signals.
    /// This has to be called after a user logs in and after the app returns from being inactive to being active.
    func listen() {
        praxisrufApi.connectSignalingServer(clientId: settings.clientId)
        praxisrufApi.listenForSignal()
    }
    
    /// Disconnects the connection to the signaling instance.
    /// This has to be called, when the user logs out, when the app returns to bein inactive from being active
    /// and when repairing a connection has failed to many times.
    func disconnect() {
        praxisrufApi.disconnectSignalingService()
    }
    
    /// Sends a ping signal over the connection of the signaling instance.
    /// This ensures that the connection stayes open.
    /// This has to be called in regular intervals. This interval is triggered by a timer
    /// on the IntercomView.
    func ping() {
        praxisrufApi.pingSignalingConnection() 
    }
    
    /// Toggles the mute state of the microphone for all connections.
    /// This method can be called from a component in the view and delegates
    /// un/-muting the microphone to the CallClient.
    func toggleMute(_ state: Bool) {
        self.callClient.toggleMute(state: state)
    }
    
    /// Toggles the mute state of the speaker for all connections.
    /// This method can be called from a component in the view and delegates
    /// un/-muting the microphone to the CallClient.
    func toggleSpeaker(_ state: Bool) {
        self.callClient.toggleSpeaker(state: state)
    }
    
    /// Initiates a call with one or multiple partners.
    /// This is used by the IntercomView after a call button is tapped.
    ///
    /// Initiating a call is done by setting the call active state to true and storing the id and name of the activated callType in an instance property.
    /// Setting the active state to true will trigger navigation to the ActiveCallView which will the initiate connection establishment.
    func initCall(calltype: DisplayCallType) {
        DispatchQueue.main.async {
            self.active = true
            self.callTypeId = calltype.id.uuidString
            self.callPartnerName = calltype.displayText
        }
    }
    
    /// Opens connections to all participants of the given callGroup.
    ///
    /// The relevant participants are requested from the cloudservice configuration api, based on the given calLTypeId.
    /// Afterwards the callClient states in this service are initialized for each participants so they can be displayed in the UI.
    /// Additionally creation the connections to other clients is delegated to the CallClient.
    ///
    /// This method is called by the ActiveCallView upon initiation for an outgoing call.
    func startCall() {
        PraxisrufApi().getCallTypeParticipants(callTypeId: self.callTypeId) { result in
            switch result {
                case .success(let participants):
                    participants
                        .filter({ p in p.id.uuidString != self.settings.clientId.uppercased() })
                        .forEach() { p in
                            self.initCallPartnerState(p: p)
                            self.callClient.offer(targetId: p.id.uuidString)
                        }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.error = error
                    }
            }
        }
    }
    
    /// Adds the given participant (Client) to the list of call partner states.
    /// Initially all participants are added with their Client.name and the state .PROCESSING
    /// These states will be displayed in the ActiveCallView.
    private func initCallPartnerState(p: Client) {
        DispatchQueue.main.async {
            self.states[p.id.uuidString] = (p.name, .PROCESSING)
        }
    }
    
    /// Opens a connection for the participant of a pending signal.
    /// Opening the connection is delegated to the CallClient.
    ///
    /// This is called by the ActiveCalLView after initiation for an incoming call.
    func acceptPending() {
        callClient.accept(signal: pending!)
    }
    
    /// Notifies the callClient that all open connections should be closed.
    /// This can be called from the ActiveCallView.
    func endCall() {
        callClient.endCall()
    }

}

/// This extension call adds implementation of CallClientDelagte to the CallService.
/// This allows integrating the signaling instance into the SwiftUI App.
/// It is extracted to its own extension class for better readability.
extension CallService : CallClientDelegate {
    
    /// Receives a signal and stores it in an instance property as pending signal.
    /// This can later be used by CallService.acceptPending to initiate a pending call.
    ///
    /// After receiving a pending signal participant states and callParnterName are updated and the ActiveCallView is initiated.
    /// Addtionally the received signal is added to the Inbox to display a received call.
    ///
    /// If a call is already active, the connection will be denied by calling CallClient.decline.
    ///
    /// This is called by the CallClient after receiving an OFFER Signal.
    func onIncommingCallPending(signal: Signal) {
        if (self.active){
            self.callClient.decline(signal: signal)
        } else {
            DispatchQueue.main.async {
                self.pending = signal
                self.active = true
                self.states[signal.sender] = (signal.description, .PROCESSING)
                self.callPartnerName = signal.description
                Inbox.shared.receiveCall(signal)
            }
        }

    }
    
    /// Receives a signal for a declined call.
    /// The information of the received signal is used to create a notification for declined calls.
    /// This notification is displayed as a push notification and added to the inbox.
    ///
    /// This is called by the CallClient after handling a DECLINE signal.
    func onIncomingCallDeclined(signal: Signal) {
        let content = UNMutableNotificationContent()
        content.title = signal.description
        content.body = "Abgelehnter Anruf"
        content.categoryIdentifier = "local"
        content.sound = UNNotificationSound.default

        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: nil)
        let notificationCenter = UNUserNotificationCenter.current()
    
        notificationCenter.add(request) { (error) in }
        
        DispatchQueue.main.async {
            Inbox.shared.receiveDeclinedCall(signal)
        }
    }
    
    /// Resets the callPartnerStates as well as id and name of the active Calltype.
    /// It then decativates the ActiveCallView, which triggers navigation to the previousely displayed view.
    ///
    /// This is called by the CallClient after handling an END signal.
    func onCallEnded() {
        DispatchQueue.main.async {
            self.callTypeId = ""
            self.callPartnerName = ""
            self.states.removeAll()
            self.active = false
        }
    }
    
    /// Displays an error dialog, explaining that a call has ended because of a technical error.
    ///
    /// This is called by the CallClient if an error occured which the CallClient cannot handle or repair.
    func onCallError() {
        DispatchQueue.main.async {
            self.error = PraxisrufApiError.callError
        }
    }
    
    /// Updates the state of a given participants in the call partner states.
    ///
    /// This is called by the CallClient when the state of a connection has changed.
    func updateState(clientId: String, state: ConnectionStatus) {
        DispatchQueue.main.async {
            self.states[clientId]?.1 = state
        }
    }
    
    /// Sends the given signal via PraxisrufAPI.signaling
    ///
    /// Before sending the recipient field of a signal is evaluated.
    /// If the recipient id is the same as the configured client id, the signal is filtered out and not sent.
    func send(_ signal: Signal) {
        if (signal.recipient.uppercased() != self.settings.clientId.uppercased()) {
            praxisrufApi.sendSignal(signal: signal)
        }
    }
    
}

/// This extension call adds implementation of SignalingDelegate to the CallService.
/// This allows integrating the signaling instance into the SwiftUI App.
///
/// It is extracted to its own extension class for better readability.
extension CallService : PraxisrufApiSignalingDelegate {
    
    /// Evaluates whether a closed connection should be restored.
    ///
    /// If the last ten attempts of restoring a connection or sending/receiving a singal have failed, no more attempts are made.
    /// The connection remains closed. Displaying an error message is in the responsibility of any
    /// instance that increases the errorCount to the threshold.
    ///
    /// If the errorCount is smaller than the threshold of ten, the connection is restored.
    /// This is done by explicitly disconnectiong the signaling instance and then creating starting to listen for signals again.
    /// All handling of the actual connection is delegated to PraxisrufApi+Signaling.
    ///
    /// This is called by PraxisrufApi+Signaling when:
    /// * Trying to send a signal, but the connection is closed
    /// * Trying to send a ping signal, but the connection is closed
    /// * An error message was received, indicating the connection is closed
    /// * Starting to receive signals is not possible because the connection is closed. 
    func onConnectionLost() {
        if (self.errorCount <= 10) {
            praxisrufApi.disconnectSignalingService()
            listen()
        }
    }
    
    /// Receives a signal from PraxisrufApi+Signaling.
    /// Processing is delegated to the CallClient.
    /// If calls are disabled in the local settings, CallClient.declint is called.
    /// Otherwise CallClient.receive will be called.
    ///
    /// This is called by PraxisrufApi+Signaling when a signal message was received.
    func onSignalReceived(_ signal: Signal) {
        if (settings.isIncomingCallsDisabled) {
            self.callClient.decline(signal: signal)
        } else {
            self.callClient.receive(signal: signal)
        }
    }
    
    /// Receives an error from PraxisrufApi+Signaling.
    /// This will increment the error counter by one.
    /// If the error count is below or equal to the threshold of ten the error is logged and nothing more is done.
    /// If the errorCount is above the threshold  of then the connection is closed and an error is published.,
    /// This error will be displayed in a dialog in the UI.
    /// At this point no more attempts to restore the connection are made untill a ping signal is sent
    /// or the user tries to start a call.
    func onErrorReceived(error: Error) {
        self.errorCount += 1
        print(error.localizedDescription)
        if (self.errorCount > 10) {
            disconnect()
            DispatchQueue.main.async {
                self.error = PraxisrufApiError.connectionClosedPerm
                self.errorCount = 0
            }
        }
    }
    
    /// Resets the errorCount to zero.
    ///
    /// This is called by PraxisrufAPI+Signaling when:
    /// * Connection to the singaling instance has been established.
    /// * A signaling message was received successfully
    /// * A ping message was sent successfully
    /// * Before a ping or signalingMessage is sent. 
    func onConnectionRestored() {
        self.errorCount = 0
    }
    
}
