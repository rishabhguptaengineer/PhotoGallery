import UIKit

final class PhotoDetailViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    // MARK: - Properties

    private var viewModel: PhotoDetailViewModel!
    private var initialPhoto: Photo?

    private let imageActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Callback Hooks

    var onPhotoUpdated: ((Photo) -> Void)?
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
            fatalError("Photo must be configured before viewDidLoad")
        }
        let container = AppDependencyContainer.shared
        viewModel = PhotoDetailViewModel(
            photo: photo,
            persistenceManager: container.coreDataManager
        )

        // Bind callbacks to pass updates to parent screen
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

        // Add activity indicator over image view
        view.addSubview(imageActivityIndicator)
        NSLayoutConstraint.activate([
            imageActivityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            imageActivityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }

    // MARK: - Public API

    /// Configures the controller with a Photo.
    /// Safe to call before or after the view has loaded.
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

        // Show offline thumbnail first as immediate placeholder
        if let data = photo.thumbnailData {
            imageView.image = UIImage(data: data)
        } else {
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = .systemGray3
        }

        imageActivityIndicator.startAnimating()

        // Asynchronously load the full-size image
        Task { [weak self] in
            guard let self = self else { return }
            let fullImageData = await self.viewModel.downloadFullImage()
            
            await MainActor.run {
                self.imageActivityIndicator.stopAnimating()
                if let data = fullImageData, let fullImage = UIImage(data: data) {
                    self.imageView.image = fullImage
                }
            }
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func performDelete() {
        do {
            try viewModel.deletePhoto()
            navigationController?.popViewController(animated: true)
        } catch {
            showErrorAlert(message: error.localizedDescription)
        }
    }

    // MARK: - Actions

    @IBAction private func saveButtonTapped(_ sender: UIButton) {
        guard let newTitle = titleTextField.text else { return }
        do {
            try viewModel.saveTitle(newTitle)
            
            let alert = UIAlertController(
                title: "Success",
                message: "Title updated successfully.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } catch {
            showErrorAlert(message: error.localizedDescription)
        }
    }

    @IBAction private func deleteButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Delete Photo",
            message: "Are you sure you want to delete this photo?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.performDelete()
        }))
        present(alert, animated: true)
    }
}
