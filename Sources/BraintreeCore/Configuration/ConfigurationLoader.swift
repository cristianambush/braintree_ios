import Foundation

class ConfigurationLoader {

    // MARK: - Private Properties

    private let configPath = "v1/configuration"
    private let configurationCache = ConfigurationCache.shared
    private let http: BTHTTP
    private let pendingCompletions = ConfigurationCallbackStorage()
    private var existingTask: Task<BTConfiguration, Error>?

    // MARK: - Intitializer

    init(http: BTHTTP) {
        self.http = http
    }

    deinit {
        http.session.finishTasksAndInvalidate()
        existingTask?.cancel()
    }

    // MARK: - Internal Methods

    /// Fetches or returns the configuration and caches the response in the GET BTHTTP call if successful.
    ///
    /// This method attempts to retrieve the configuration in the following order:
    /// 1. If a cached configuration is available, it returns the cached configuration without making a network request.
    /// 2. If no cached configuration is found, it fetches the configuration from the server and caches the successful response.
    /// 3. If fetching the configuration fails, it returns an error.
    ///
    /// - Parameters:
    ///   - completion: A completion handler that is called with the fetched or cached `BTConfiguration` object or an `Error`.
    ///
    /// - Completion:
    ///   - `BTConfiguration?`: The configuration object if it is successfully fetched or retrieved from the cache.
    ///   - `Error?`: An error object if fetching the configuration fails or if the instance is deallocated.
    @_documentation(visibility: private)
    func getConfig() async throws -> BTConfiguration {
        if let cachedConfig = try? configurationCache.getFromCache(authorization: http.authorization.bearer) {
            return cachedConfig
        }

        if let existingTask = existingTask {
            return try await existingTask.value
        }

        let task = Task { () throws -> BTConfiguration in
            return try await withCheckedThrowingContinuation { continuation in
                http.get(configPath, parameters: BTConfigurationRequest()) { [weak self] body, response, error in
                    guard let self else {
                        continuation.resume(throwing: BTAPIClientError.deallocated)
                        return
                    }

                    if let error {
                        continuation.resume(throwing: error)
                    } else if response?.statusCode != 200 || body == nil {
                        continuation.resume(throwing: BTAPIClientError.configurationUnavailable)
                    } else {
                        let configuration = BTConfiguration(json: body)
                        try? self.configurationCache.putInCache(authorization: self.http.authorization.bearer, configuration: configuration)
                        continuation.resume(returning: configuration)
                    }

                    self.existingTask = nil
                }
            }
        }

        existingTask = task

        return try await task.value
    }

    func getConfig(completion: @escaping (BTConfiguration?, Error?) -> Void) {
        Task {
            do {
                let config = try await getConfig()
                completion(config, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}
