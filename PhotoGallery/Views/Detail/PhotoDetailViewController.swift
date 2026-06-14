import UIKit

// MARK: - PhotoDetailViewController

final class PhotoDetailViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    // MARK: - Private Properties

    private var viewModel: PhotoDetailViewModel!
    private var initialPhoto: Photo?

    private let imageActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Callbacks

    /// Called when the user successfully edits the photo title.
    var onPhotoUpdated: ((Photo) -> Void)?

    /// Called when the user deletes the photo (passes the deleted photo's id).
    var onPhotoDeleted: ((Int) -> Void)?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupView()
        updateUI()
    }

    // MARK: - Setup

    private func setupViewModel() {
        guard let photo = initialPhoto else {
            fatalError("PhotoDetailViewController: configure(with:) must be called before the view loads.")
        }
        let container = AppDependencyContainer.shared
        viewModel = PhotoDetailViewModel(
            photo: photo,
            persistenceManager: container.coreDataManager
        )

        // Forward ViewModel callbacks to the parent screen.
        viewModel.onPhotoUpdated = { [weak self] updatedPhoto in
            self?.onPhotoUpdated?(updatedPhoto)
        }
        viewModel.onPhotoDeleted = { [weak self] deletedId in
            self?.onPhotoDeleted?(deletedId)
        }
    }

    private func setupView() {
        title = "Photo Detail"
        view.backgroundColor = .systemBackground
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        titleTextField.borderStyle = .roundedRect

        view.addSubview(imageActivityIndicator)
        NSLayoutConstraint.activate([
            imageActivityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            imageActivityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }

    // MARK: - Public API

    /// Passes the selected photo to this controller.
    /// Safe to call before or after the view loads.
    func configure(with photo: Photo) {
        initialPhoto = photo
        if isViewLoaded {
            setupViewModel()
            updateUI()
        }
    }

    // MARK: - Private Helpers

    private func updateUI() {
        guard let photo = viewModel?.photo else { return }
        titleTextField.text = photo.title

        // Immediately display the cached thumbnail while the full image loads.
        if let data = photo.thumbnailData {
            imageView.image = UIImage(data: data)
        } else {
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = .systemGray3
        }

        imageActivityIndicator.startAnimating()
        Task { [weak self] in
            guard let self else { return }
            let data = await self.viewModel.downloadFullImage()
            await MainActor.run {
                self.imageActivityIndicator.stopAnimating()
                if let data, let image = UIImage(data: data) {
                    self.imageView.image = image
                }
            }
        }
    }

    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func performDelete() {
        do {
            try viewModel.deletePhoto()
            navigationController?.popViewController(animated: true)
        } catch {
            presentAlert(title: "Error", message: "Failed to delete the photo. Please try again.")
        }
    }

    // MARK: - Actions

    @IBAction private func saveButtonTapped(_ sender: UIButton) {
        guard let newTitle = titleTextField.text else { return }
        do {
            try viewModel.saveTitle(newTitle)
            presentAlert(title: "Success", message: "Title updated successfully.")
        } catch let appError as AppError {
            presentAlert(title: "Unable to Save", message: appError.localizedDescription)
        } catch {
            presentAlert(title: "Unable to Save", message: "Failed to save changes. Please try again.")
        }
    }

    @IBAction private func deleteButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Delete Photo",
            message: "Are you sure you want to delete this photo?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDelete()
        })
        present(alert, animated: true)
    }
}
