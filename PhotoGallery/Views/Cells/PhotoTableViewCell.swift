import UIKit

// MARK: - PhotoTableViewCell

final class PhotoTableViewCell: UITableViewCell {

    // MARK: - Constants

    static let reuseIdentifier = "PhotoTableViewCell"

    // MARK: - IBOutlets

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: - Private Properties

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private var downloadTask: Task<Void, Never>?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
        activityIndicator.stopAnimating()
        thumbnailImageView.image = nil
        titleLabel.text = nil
    }

    // MARK: - Setup

    private func setupViews() {
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 6
        thumbnailImageView.backgroundColor = .systemGray6

        addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor)
        ])
    }

    // MARK: - Configuration

    /// Configures the cell. Displays cached thumbnail data immediately if available,
    /// otherwise falls back to an async download while showing an activity indicator.
    func configure(with photo: Photo) {
        titleLabel.text = photo.title
        thumbnailImageView.tintColor = .systemGray3

        if let data = photo.thumbnailData {
            thumbnailImageView.image = UIImage(data: data)
        } else {
            thumbnailImageView.image = nil
            activityIndicator.startAnimating()
            downloadTask = Task { [weak self] in
                await self?.loadThumbnail(from: photo.thumbnailUrl)
            }
        }
    }

    // MARK: - Private Helpers

    private func loadThumbnail(from urlString: String) async {
        guard let url = PlaceholderURLHelper.correctedURL(from: urlString) else {
            showPlaceholder()
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard !Task.isCancelled else { return }

            guard
                let http = response as? HTTPURLResponse,
                (200...299).contains(http.statusCode)
            else {
                showPlaceholder()
                return
            }

            await MainActor.run { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.thumbnailImageView.image = UIImage(data: data)
            }
        } catch {
            guard !Task.isCancelled else { return }
            showPlaceholder()
        }
    }

    @MainActor
    private func showPlaceholder() {
        activityIndicator.stopAnimating()
        thumbnailImageView.image = UIImage(systemName: "photo")
    }
}
