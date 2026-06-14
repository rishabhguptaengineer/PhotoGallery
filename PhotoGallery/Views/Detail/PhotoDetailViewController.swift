import UIKit

final class PhotoDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    private var viewModel: PhotoDetailViewModel!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupView()
    }

    // MARK: - Setup

    private func setupViewModel() {
        let container = AppDependencyContainer.shared
        viewModel = PhotoDetailViewModel(persistenceManager: container.coreDataManager)
    }

    private func setupView() {
        title = "Photo Detail"
        view.backgroundColor = .systemBackground
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        titleTextField.borderStyle = .roundedRect
    }

    func configure(with photo: Photo) {
        viewModel.photo = photo
        titleTextField?.text = photo.title
    }

    // MARK: - Actions

    @IBAction private func saveButtonTapped(_ sender: UIButton) {
        // TODO: Implement save
    }

    @IBAction private func deleteButtonTapped(_ sender: UIButton) {
        // TODO: Implement delete
    }
}
