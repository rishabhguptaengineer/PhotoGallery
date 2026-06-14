import UIKit

final class PhotoListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var viewModel: PhotoListViewModel!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupTableView()
    }

    // MARK: - Setup

    private func setupViewModel() {
        let container = AppDependencyContainer.shared
        viewModel = PhotoListViewModel(
            apiService: container.apiService,
            persistenceManager: container.coreDataManager
        )
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 88
        tableView.register(
            UINib(nibName: PhotoTableViewCell.reuseIdentifier, bundle: nil),
            forCellReuseIdentifier: PhotoTableViewCell.reuseIdentifier
        )
    }
}

// MARK: - UITableViewDataSource

extension PhotoListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PhotoTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? PhotoTableViewCell else {
            return UITableViewCell()
        }
        let photo = viewModel.photos[indexPath.row]
        cell.configure(with: photo)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PhotoListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowPhotoDetail", sender: viewModel.photos[indexPath.row])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoDetail",
           let detailVC = segue.destination as? PhotoDetailViewController,
           let photo = sender as? Photo {
            detailVC.configure(with: photo)
        }
    }
}
