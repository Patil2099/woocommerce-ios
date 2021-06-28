import UIKit

/// Generates top banner view that is shown at the top of variation list screen when at least one variation is missing a price.
///
final class ProductVariationsTopBannerFactory {
    static func missingPricesTopBannerView() -> TopBannerView {
        let viewModel = TopBannerViewModel(title: Localization.title,
                                           infoText: Localization.info,
                                           icon: Constants.icon,
                                           isExpanded: true,
                                           topButton: .none,
                                           type: .warning)
        return TopBannerView(viewModel: viewModel)
    }
}

private extension ProductVariationsTopBannerFactory {
    enum Constants {
        static let icon = UIImage.infoOutlineImage
    }

    enum Localization {
        static let title = NSLocalizedString("Some variations do not have prices",
                                             comment: "Banner title in product variation list top banner when some variations do not have a price")
        static let info = NSLocalizedString("Add price to your variations to make them visible on your store",
                                            comment: "Banner caption in my store when the stats will be deprecated")
    }
}
