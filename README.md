Photo Gallery App

Overview

Photo Gallery App is a UIKit-based iOS application that displays photos fetched from a remote API and persists data locally using Core Data. The application follows the MVVM architecture pattern and supports offline access to photo metadata and thumbnails.

The app demonstrates:

* UIKit with Storyboards and XIBs
* MVVM Architecture
* Core Data Persistence
* Dependency Injection
* Protocol-Oriented Programming
* Async/Await Networking
* Offline-First Data Access
* Pagination
* Pull-to-Refresh
* Image Caching
* CRUD Operations

⸻

Features

Photo List Screen

* Displays photos in a UITableView
* Loads persisted data from Core Data
* Displays thumbnail images
* Supports pull-to-refresh
* Supports infinite scrolling pagination
* Works offline using locally stored data

Photo Detail Screen

* Displays full-size image
* Allows editing the photo title
* Allows deleting a photo
* Updates the list screen immediately after modifications

Offline Support

* Photo metadata is stored locally
* Thumbnail images are persisted in Core Data
* Previously loaded data remains available without internet connectivity
* Edit and delete operations continue to work with locally stored data

⸻

Architecture

The application follows the MVVM (Model-View-ViewModel) architecture pattern.

ViewController
      ↓
ViewModel
      ↓
Services
      ↓
Core Data / Network

View

Responsible for:

* Rendering UI
* Handling user interactions
* Binding to ViewModels
* Navigation

Examples:

* PhotoListViewController
* PhotoDetailViewController
* PhotoTableViewCell

ViewModel

Responsible for:

* Business logic
* State management
* Data transformation
* Communication with Services

Examples:

* PhotoListViewModel
* PhotoDetailViewModel

Services

Responsible for:

* Networking
* Persistence
* Image Caching

Examples:

* APIService
* CoreDataManager
* ImageCacheManager

⸻

Project Structure

PhotoGallery
│
├── Models
│   ├── Photo.swift
│   └── PhotoDTO.swift
│
├── Services
│   ├── API
│   │   ├── APIService.swift
│   │   ├── APIServiceProtocol.swift
│   │   └── Endpoint.swift
│   │
│   ├── Persistence
│   │   ├── CoreDataManager.swift
│   │   └── CoreDataManaging.swift
│   │
│   └── Cache
│       ├── ImageCacheManager.swift
│       └── ImageCacheManaging.swift
│
├── ViewModels
│   ├── PhotoListViewModel.swift
│   └── PhotoDetailViewModel.swift
│
├── Views
│   ├── List
│   ├── Detail
│   └── Cells
│
├── CoreData
│
├── Resources
│
└── SupportingFiles

⸻

Dependency Injection

The application uses protocol-based dependency injection to reduce coupling and improve testability.

Examples:

init(
    apiService: APIServiceProtocol,
    coreDataManager: CoreDataManaging
)

Benefits:

* Improved testability
* Better separation of concerns
* Easier service replacement
* Cleaner architecture

⸻

Core Data Strategy

Core Data is used as the application’s local persistence layer.

PhotoEntity

Attributes:

* id
* albumId
* title
* url
* thumbnailUrl
* thumbnailData

A unique constraint is applied on:

id

to prevent duplicate records.

Why Core Data?

Core Data was selected because it provides:

* Efficient local persistence
* Offline support
* Built-in object graph management
* Scalable data storage
* Native Apple framework integration

⸻

Image Loading Strategy

The application uses two different image persistence strategies depending on the use case.

Thumbnail Images

Thumbnail images are downloaded during synchronization and stored as Binary Data in Core Data.

Advantages:

* Available offline
* Fast table view rendering
* No additional network requests for list items
* Improved offline experience

Full-Size Images

Full-size images are loaded on demand when the user opens the detail screen.

The application uses ImageCacheManager backed by NSCache to:

* Cache images in memory
* Prevent unnecessary downloads
* Improve detail screen performance
* Reduce network usage

To avoid duplicate downloads, the cache manager tracks in-flight requests and ensures multiple consumers requesting the same image share a single network request.

This approach balances storage efficiency and performance.

⸻

Offline Support

The application follows an offline-first approach for photo metadata and thumbnail images.

Persisted Locally

The following data is stored in Core Data:

* Photo metadata
* Image URLs
* Thumbnail images

Because thumbnails are stored locally, the photo list screen remains fully functional without internet connectivity.

Full-Size Images

Full-size images are not persisted in Core Data.

When a user opens the detail screen, the image is loaded from the network and cached in memory for the duration of the app session.

Offline Behavior

Without internet connectivity:

✅ Previously saved photo metadata remains available

✅ Previously saved thumbnails remain visible

✅ Photo list browsing continues to work

✅ Edit and delete operations continue to work on locally stored data

⚠️ Full-size images require a network connection unless they have already been loaded and cached during the current app session

⸻

Networking

The application uses URLSession with Swift Concurrency.

Technologies:

* URLSession
* Async/Await
* Codable
* DTO Mapping

Data Flow:

API
 ↓
PhotoDTO
 ↓
Photo
 ↓
Core Data
 ↓
ViewModel
 ↓
ViewController

API Endpoint:

https://jsonplaceholder.typicode.com/photos

⸻

Pagination

Pagination is implemented using API query parameters.

_page
_limit

Page Size:

50

Flow:

User Scrolls Near Bottom
          ↓
ViewModel Requests Next Page
          ↓
API Fetch
          ↓
Core Data Save
          ↓
UI Update

Duplicate requests are prevented using loading state tracking.

⸻

Pull To Refresh

The list screen supports pull-to-refresh.

Flow:

User Pulls Down
       ↓
API Fetch
       ↓
Core Data Update
       ↓
Reload Local Data
       ↓
Refresh UI

⸻

Edit & Delete Operations

Edit Title

Users can update photo titles from the detail screen.

Flow:

Detail Screen
      ↓
Update Title
      ↓
Core Data
      ↓
List Screen Update

Delete Photo

Users can delete photos from the detail screen or list screen.

Flow:

Delete Action
      ↓
Core Data Delete
      ↓
ViewModel Update
      ↓
UI Refresh

⸻

Error Handling

The application handles:

* Network failures
* Core Data failures
* Empty states
* Invalid image loading
* Offline scenarios

User-facing messages are kept clean and actionable.

Examples:

* Unable to load photos
* No internet connection
* Failed to save changes
* Something went wrong

⸻

Project Flow

Application Launch
        ↓
Core Data Fetch
        ↓
Data Exists?
    ↙       ↘
  Yes        No
   ↓          ↓
Display     API Fetch
 Local        ↓
 Data      Save To Core Data
   ↓          ↓
Display Photos

⸻

Build & Run

Requirements

* Xcode 16+
* iOS 15+
* Swift 5.9+

Steps

1. Clone the repository
2. Open the Xcode project
3. Build the project
4. Run on Simulator or Physical Device

⸻

Assumptions

* The remote API provides stable pagination.
* Photo IDs remain unique.
* Thumbnail URLs remain valid.
* Local Core Data persistence is considered the source of truth for displayed data.
* Full-size images are fetched on demand and are not persisted between app launches.
