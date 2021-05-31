import Foundation
import Networking
import Storage

// Handles `SitePluginAction` actions
//
public final class SitePluginStore: Store {
    private let remote: SitePluginsRemote

    public override init(dispatcher: Dispatcher, storageManager: StorageManagerType, network: Network) {
        self.remote = SitePluginsRemote(network: network)
        super.init(dispatcher: dispatcher, storageManager: storageManager, network: network)
    }

    /// Registers to support `SitePluginAction`
    ///
    public override func registerSupportedActions(in dispatcher: Dispatcher) {
        dispatcher.register(processor: self, for: SitePluginAction.self)
    }

    /// Receives and executes actions
    ///
    public override func onAction(_ action: Action) {
        guard let action = action as? SitePluginAction else {
            assertionFailure("SitePluginStore receives an unsupported action!")
            return
        }

        switch action {
        case .synchronizeSitePlugins(let siteID, let onCompletion):
            synchronizeSitePlugins(siteID: siteID, completionHandler: onCompletion)
        }
    }
}

// MARK: - Network request
//
private extension SitePluginStore {
    func synchronizeSitePlugins(siteID: Int64, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        remote.loadPlugins(for: siteID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let plugins):
                self.upsertSitePluginsInBackground(siteID: siteID, readonlyPlugins: plugins, completionHandler: completionHandler)
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}

// MARK: - Storage
//
private extension SitePluginStore {

    /// Updates or inserts Readonly `SitePlugin` entities in background.
    /// Triggers `completionHandler` on main thread.
    ///
    func upsertSitePluginsInBackground(siteID: Int64, readonlyPlugins: [SitePlugin], completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let writerStorage = storageManager.writerDerivedStorage
        writerStorage.perform {
            self.upsertSitePlugins(siteID: siteID, readonlyPlugins: readonlyPlugins, in: writerStorage)
        }

        storageManager.saveDerivedType(derivedStorage: writerStorage) {
            DispatchQueue.main.async {
                completionHandler(.success(()))
            }
        }
    }

    /// Updates or inserts Readonly `SitePlugin` entities in specified storage.
    /// Also removes stale plugins that no longer exist in remote plugin list.
    ///
    func upsertSitePlugins(siteID: Int64, readonlyPlugins: [SitePlugin], in storage: StorageType) {
        readonlyPlugins.forEach { readonlyPlugin in
            // load or create new StorageSitePlugin matching the readonly one
            let storagePlugin: StorageSitePlugin = {
                if let plugin = storage.loadPlugin(siteID: readonlyPlugin.siteID, name: readonlyPlugin.name) {
                    return plugin
                }
                return storage.insertNewObject(ofType: StorageSitePlugin.self)
            }()

            storagePlugin.update(with: readonlyPlugin)
        }

        // remove stale plugins
        let installedPluginNames = readonlyPlugins.map(\.name)
        storage.deleteStalePlugins(siteID: siteID, installedPluginNames: installedPluginNames)
    }
}
