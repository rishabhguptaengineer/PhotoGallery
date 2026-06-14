import Foundation

protocol CoreDataManaging {
    func fetchPhotos() throws -> [Photo]
    func savePhoto(_ photo: Photo) throws
    func deletePhoto(id: Int64) throws
}
