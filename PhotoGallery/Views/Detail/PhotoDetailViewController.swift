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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupView()
        updateUI()
    }

    // MARK: - Setup

    private func setupViewModel() {
        let container = AppDependencyContainer.shared
        viewModel = PhotoDetailViewModel(persistenceManager: container.coreDataManager)
        if let photo = initialPhoto {
            viewModel.photo = photo
        }
    }

    private func setupView() {
        title = "Photo Detail"
        view.backgroundColor = .systemBackground
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        titleTextField.borderStyle = .roundedRect
    }

    // MARK: - Public API

    /// Configures the controller with a Photo.
    /// Safe to call before or after the view has loaded.
    func configure(with photo: Photo) {
        initialPhoto = photo
        if isViewLoaded {
            viewModel.photo = photo
            updateUI()
        }
    }

    // MARK: - Private Helpers

    private func updateUI() {
        guard let photo = viewModel?.photo else { return }
        titleTextField.text = photo.title
        if let data = photo.thumbnailData {
            imageView.image = UIImage(data: data)
        } else {
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = .systemGray3
        }
    }

    // MARK: - Actions

    @IBAction private func saveButtonTapped(_ sender: UIButton) {
        // TODO: Implement save
    }

    @IBAction private func deleteButtonTapped(_ sender: UIButton) {
        // TODO: Implement delete
    }
}
