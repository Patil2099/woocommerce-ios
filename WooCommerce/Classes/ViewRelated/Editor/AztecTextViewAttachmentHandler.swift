import Aztec

/// Implements Aztec's `TextViewAttachmentDelegate` without media support.
final class AztecTextViewAttachmentHandler: TextViewAttachmentDelegate {
    func textView(_ textView: TextView,
                  attachment: NSTextAttachment,
                  imageAt url: URL,
                  onSuccess success: @escaping (UIImage) -> Void,
                  onFailure failure: @escaping () -> Void) {
        switch attachment {
        case is ImageAttachment:
            let imageService = ServiceLocator.imageService

            imageService.retrieveImageFromCache(with: url) { image in
                if let image = image {
                    success(image)
                }
            }

            imageService.downloadImage(with: url, shouldCacheImage: true) { image, error in
                guard let image = image else {
                    failure()
                    return
                }
                success(image)
            }
        default:
            return
        }
    }

    func textView(_ textView: TextView, urlFor imageAttachment: ImageAttachment) -> URL? {
        return nil
    }

    func textView(_ textView: TextView, placeholderFor attachment: NSTextAttachment) -> UIImage {
        return UIImage.cameraImage
    }

    func textView(_ textView: TextView, deletedAttachment attachment: MediaAttachment) {
    }

    func textView(_ textView: TextView, selected attachment: NSTextAttachment, atPosition position: CGPoint) {
    }

    func textView(_ textView: TextView, deselected attachment: NSTextAttachment, atPosition position: CGPoint) {
    }
}
