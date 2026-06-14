import UIKit

final class PhotoTableViewCell: UITableViewCell {

    // MARK: - Constants

    static let reuseIdentifier = "PhotoTableViewCell"

    // MARK: - IBOutlets

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        titleLabel.text = nil
    }

    // MARK: - Setup

    private func setupViews() {
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 6
        thumbnailImageView.backgroundColor = .systemGray6
    }

    // MARK: - Configuration

    /// Configures the cell contents for a given Photo, loading the thumbnail data if present.
    func configure(with photo: Photo) {
        titleLabel.text = photo.title
        if let data = photo.thumbnailData {
            thumbnailImageView.image = UIImage(data: data)
        } else {
            thumbnailImageView.image = UIImage(systemName: "photo")
            thumbnailImageView.tintColor = .systemGray3
        }
    }
}
