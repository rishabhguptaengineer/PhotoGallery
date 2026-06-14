import Foundation

final class AppDependencyContainer {

    static let shared = AppDependencyContainer()
    private init() {}

    lazy var apiService: APIServiceProtocol = APIService()
    lazy var coreDataManager: CoreDataManaging = CoreDataManager.shared
}
