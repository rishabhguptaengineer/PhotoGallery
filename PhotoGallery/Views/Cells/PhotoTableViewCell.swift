import UIKit

final class PhotoTableViewCell: UITableViewCell {

    static let reuseIdentifier = "PhotoTableViewCell"

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 6
    }

    func configure(with photo: Photo) {
        titleLabel.text = photo.title
        thumbnailImageView.image = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        titleLabel.text = nil
    }
}
