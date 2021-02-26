import Foundation
import Yosemite
import AutomatticTracks
import WordPressShared


public class TracksProvider: NSObject, AnalyticsProvider {

    lazy private var contextManager: TracksContextManager = {
        return TracksContextManager()
    }()
    lazy private var tracksService: TracksService = {
        let tracksService = TracksService(contextManager: contextManager)!
        tracksService.eventNamePrefix = Constants.eventNamePrefix
        return tracksService
    }()
}


// MARK: - AnalyticsProvider Conformance
//
public extension TracksProvider {
    func refreshUserData() {
        switchTracksUsersIfNeeded()
        refreshTracksMetadata()
    }

    func track(_ eventName: String) {
        track(eventName, withProperties: nil)
    }

    func track(_ eventName: String, withProperties properties: [AnyHashable: Any]?) {
        if let properties = properties {
            tracksService.trackEventName(eventName, withCustomProperties: properties)
            DDLogInfo("🔵 Tracked \(eventName), properties: \(properties)")
        } else {
            tracksService.trackEventName(eventName)
            DDLogInfo("🔵 Tracked \(eventName)")
        }
    }

    func clearEvents() {
        tracksService.clearQueuedEvents()
    }

    /// When a user opts-out, wipe data
    ///
    func clearUsers() {
        guard ServiceLocator.analytics.userHasOptedIn else {
            // To be safe, nil out the anonymousUserID guid so a fresh one is regenerated
            UserDefaults.standard[.defaultAnonymousID] = nil
            UserDefaults.standard[.analyticsUsername] = nil
            tracksService.switchToAnonymousUser(withAnonymousID: ServiceLocator.stores.sessionManager.anonymousUserID)
            return
        }

        switchTracksUsersIfNeeded()
    }
}


// MARK: - Private Helpers
//
private extension TracksProvider {
    func switchTracksUsersIfNeeded() {
        let currentAnalyticsUsername = UserDefaults.standard[.analyticsUsername] as? String ?? ""
        if ServiceLocator.stores.isAuthenticated, let account = ServiceLocator.stores.sessionManager.defaultAccount {
            if currentAnalyticsUsername.isEmpty {
                // No previous username logged
                UserDefaults.standard[.analyticsUsername] = account.username
                tracksService.switchToAuthenticatedUser(withUsername: account.username, userID: String(account.userID), skipAliasEventCreation: false)
            } else if currentAnalyticsUsername == account.username {
                // Username did not change - just make sure Tracks client has it
                tracksService.switchToAuthenticatedUser(withUsername: account.username, userID: String(account.userID), skipAliasEventCreation: true)
            } else {
                // Username changed for some reason - switch back to anonymous first
                tracksService.switchToAnonymousUser(withAnonymousID: ServiceLocator.stores.sessionManager.anonymousUserID)
                tracksService.switchToAuthenticatedUser(withUsername: account.username, userID: String(account.userID), skipAliasEventCreation: false)
            }
        } else {
            UserDefaults.standard[.analyticsUsername] = nil
            tracksService.switchToAnonymousUser(withAnonymousID: ServiceLocator.stores.sessionManager.anonymousUserID)
        }
    }

    func refreshTracksMetadata() {
        DDLogInfo("♻️ Refreshing tracks metadata...")
        var userProperties = [String: Any]()
        userProperties[UserProperties.platformKey] = "iOS"
        userProperties[UserProperties.voiceOverKey] = UIAccessibility.isVoiceOverRunning
        userProperties[UserProperties.rtlKey] = (UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft)
        tracksService.userProperties.removeAllObjects()
        tracksService.userProperties.addEntries(from: userProperties)
    }
}


// MARK: - Constants!
//
private extension TracksProvider {

    enum Constants {
        static let eventNamePrefix = "woocommerceios"
    }

    enum UserProperties {
        static let platformKey          = "platform"
        static let voiceOverKey         = "accessibility_voice_over_enabled"
        static let rtlKey               = "is_rtl_language"
    }
}


extension TracksProvider: WPAnalyticsTracker {
    public func trackString(_ event: String!) {
        trackString(event, withProperties: nil)
    }

    public func trackString(_ event: String!, withProperties properties: [AnyHashable : Any]!) {
//        if (properties == nil) {
//            DDLogInfo(@"🔵 Tracked: %@", event);
//        } else {
//            NSArray<NSString *> *propertyKeys = [[properties allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//            NSString *propertiesDescription = [[propertyKeys wp_map:^NSString *(NSString *key) {
//                return [NSString stringWithFormat:@"%@: %@", key, properties[key]];
//            }] componentsJoinedByString:@", "];
//            DDLogInfo(@"🔵 Tracked: %@ <%@>", event, propertiesDescription);
//        }
//
//        [self.tracksService trackEventName:event withCustomProperties:properties];
    }

    public func track(_ stat: WPAnalyticsStat) {
        track(stat, withProperties: nil)
    }

    public func track(_ stat: WPAnalyticsStat, withProperties properties: [AnyHashable : Any]!) {
//        TracksEventPair *eventPair = [[self class] eventPairForStat:stat];
//        if (!eventPair) {
//            DDLogInfo(@"WPAnalyticsStat not supported by WPAnalyticsTrackerAutomatticTracks: %@", @(stat));
//            return;
//        }
//
//        NSMutableDictionary *mergedProperties = [NSMutableDictionary new];
//
//        [mergedProperties addEntriesFromDictionary:eventPair.properties];
//        [mergedProperties addEntriesFromDictionary:properties];
//
//        [self trackString:eventPair.eventName withProperties:mergedProperties];
    }
}
