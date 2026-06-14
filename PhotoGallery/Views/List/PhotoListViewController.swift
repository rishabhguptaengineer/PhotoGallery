import UIKit

// MARK: - PhotoListViewController

final class PhotoListViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var tableView: UITableView!

    // MARK: - UI Elements (Programmatic)

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No Photos Found"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let refreshControl = UIRefreshControl()

    // MARK: - Properties

    private var viewModel: PhotoListViewModel!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupSubviews()
        setupTableView()
        bindViewModel()

        // Initial load
        viewModel.loadPhotos()
    }

    // MARK: - Setup

    private func setupViewModel() {
        let container = AppDependencyContainer.shared
        viewModel = PhotoListViewModel(
            apiService: container.apiService,
            persistenceManager: container.coreDataManager
        )
    }

    private func setupSubviews() {
        // Add activity indicator
        view.addSubview(activityIndicator)
        // Add empty state label
        view.addSubview(emptyStateLabel)

        // Set up AutoLayout constraints
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 88
        tableView.register(
            UINib(nibName: PhotoTableViewCell.reuseIdentifier, bundle: nil),
            forCellReuseIdentifier: PhotoTableViewCell.reuseIdentifier
        )

        // Setup Refresh Control
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleViewState(state)
            }
        }
    }

    private func handleViewState(_ state: ViewState) {
        switch state {
        case .idle:
            activityIndicator.stopAnimating()
            emptyStateLabel.isHidden = true
            tableView.isHidden = false

        case .loading:
            if !refreshControl.isRefreshing {
                activityIndicator.startAnimating()
                tableView.isHidden = true
            }
            emptyStateLabel.isHidden = true

        case .loaded:
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            emptyStateLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()

        case .empty:
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            emptyStateLabel.isHidden = false
            tableView.isHidden = true

        case .error(let message):
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            emptyStateLabel.isHidden = true
            tableView.isHidden = false
            showErrorAlert(message: message)
        }
    }

    // MARK: - Actions

    @objc private func handleRefresh() {
        viewModel.refresh()
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
}

// MARK: - UITableViewDataSource

extension PhotoListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.photos.count
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

        // Pagination check: Load next page when reaching the end of the list
        if indexPath.row == viewModel.photos.count - 1 {
            viewModel.loadNextPage()
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension PhotoListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPhoto = viewModel.photos[indexPath.row]
        performSegue(withIdentifier: "ShowPhotoDetail", sender: selectedPhoto)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoDetail",
           let detailVC = segue.destination as? PhotoDetailViewController,
           let photo = sender as? Photo {
            detailVC.configure(with: photo)
        }
    }
}
