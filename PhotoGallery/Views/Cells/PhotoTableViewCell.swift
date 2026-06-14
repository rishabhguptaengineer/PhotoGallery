import UIKit

final class PhotoTableViewCell: UITableViewCell {

    // MARK: - Constants

    static let reuseIdentifier = "PhotoTableViewCell"

    // MARK: - IBOutlets

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: - Properties

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

        // Add activity indicator centered over the thumbnail image view
        addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor)
        ])
    }

    // MARK: - Configuration

    /// Configures the cell contents. Uses cached thumbnail data from Core Data if present.
    /// Otherwise, fetches the thumbnail asynchronously using async/await while showing the loader.
    func configure(with photo: Photo) {
        titleLabel.text = photo.title
        thumbnailImageView.tintColor = .systemGray3

        if let data = photo.thumbnailData {
            activityIndicator.stopAnimating()
            thumbnailImageView.image = UIImage(data: data)
        } else {
            thumbnailImageView.image = nil
            activityIndicator.startAnimating()

            // Asynchronously load the thumbnail image if missing from local cache
            downloadTask = Task { [weak self] in
                guard let self = self else { return }
                var correctedUrlString = photo.thumbnailUrl.replacingOccurrences(of: "via.placeholder.com", with: "placehold.co")
                if !correctedUrlString.hasSuffix(".png") {
                    correctedUrlString += "/ffffff.png"
                }

                guard let url = URL(string: correctedUrlString) else {
                    await MainActor.run {
                        self.activityIndicator.stopAnimating()
                        self.thumbnailImageView.image = UIImage(systemName: "photo")
                    }
                    return
                }

                do {
                    let (data, response) = try await URLSession.shared.data(from: url)
                    guard !Task.isCancelled else { return }

                    guard
                        let http = response as? HTTPURLResponse,
                        (200...299).contains(http.statusCode)
                    else {
                        await MainActor.run {
                            self.activityIndicator.stopAnimating()
                            self.thumbnailImageView.image = UIImage(systemName: "photo")
                        }
                        return
                    }

                    await MainActor.run {
                        self.activityIndicator.stopAnimating()
                        self.thumbnailImageView.image = UIImage(data: data)
                    }
                } catch {
                    guard !Task.isCancelled else { return }
                    await MainActor.run {
                        self.activityIndicator.stopAnimating()
                        self.thumbnailImageView.image = UIImage(systemName: "photo")
                    }
                }
            }
        }
    }
}
