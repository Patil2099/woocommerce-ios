import Yosemite

/// Edit actions in the product form. Each action allows the user to edit a subset of product properties.
enum ProductFormEditAction: Equatable {
    case images(editable: Bool)
    case name(editable: Bool)
    case description(editable: Bool)
    case priceSettings(editable: Bool)
    case reviews
    case productType(editable: Bool)
    case inventorySettings(editable: Bool)
    case shippingSettings(editable: Bool)
    case addOns(editable: Bool)
    case categories(editable: Bool)
    case tags(editable: Bool)
    case shortDescription(editable: Bool)
    case linkedProducts(editable: Bool)
    // Affiliate products only
    case sku(editable: Bool)
    case externalURL(editable: Bool)
    // Grouped products only
    case groupedProducts(editable: Bool)
    // Variable products only
    case variations
    // Variation only
    case variationName
    case noPriceWarning
    case status(editable: Bool)
    case attributes(editable: Bool)
    // Downloadable products only
    case downloadableFiles(editable: Bool)
}

/// Creates actions for different sections/UI on the product form.
struct ProductFormActionsFactory: ProductFormActionsFactoryProtocol {

    /// Represents the variation price state.
    ///
    enum VariationsPrice {
        case unknown // Un-fetched variations
        case notSet
        case set
    }

    private let product: EditableProductModel
    private let formType: ProductFormType
    private let editable: Bool
    private let addOnsFeatureEnabled: Bool
    private let variationsPrice: VariationsPrice

    // TODO: Remove default parameter
    init(product: EditableProductModel, formType: ProductFormType, addOnsFeatureEnabled: Bool = true, variationsPrice: VariationsPrice = .unknown) {
        self.product = product
        self.formType = formType
        self.editable = formType != .readonly
        self.addOnsFeatureEnabled = addOnsFeatureEnabled
        self.variationsPrice = variationsPrice
    }

    /// Returns an array of actions that are visible in the product form primary section.
    func primarySectionActions() -> [ProductFormEditAction] {
        let shouldShowImagesRow = editable || product.images.isNotEmpty
        let shouldShowDescriptionRow = editable || product.description?.isNotEmpty == true
        let actions: [ProductFormEditAction?] = [
            shouldShowImagesRow ? .images(editable: editable): nil,
            .name(editable: editable),
            shouldShowDescriptionRow ? .description(editable: editable): nil
        ]
        return actions.compactMap { $0 }
    }

    /// Returns an array of actions that are visible in the product form settings section.
    func settingsSectionActions() -> [ProductFormEditAction] {
        return visibleSettingsSectionActions()
    }

    /// Returns an array of actions that are visible in the product form bottom sheet.
    func bottomSheetActions() -> [ProductFormBottomSheetAction] {
        guard editable else {
            return []
        }
        return allSettingsSectionActions().filter { settingsSectionActions().contains($0) == false }
            .compactMap { ProductFormBottomSheetAction(productFormAction: $0) }
    }
}

private extension ProductFormActionsFactory {
    /// All the editable actions in the settings section given the product and feature switches.
    func allSettingsSectionActions() -> [ProductFormEditAction] {
        switch product.product.productType {
        case .simple:
            return allSettingsSectionActionsForSimpleProduct()
        case .affiliate:
            return allSettingsSectionActionsForAffiliateProduct()
        case .grouped:
            return allSettingsSectionActionsForGroupedProduct()
        case .variable:
            return allSettingsSectionActionsForVariableProduct()
        default:
            return allSettingsSectionActionsForNonCoreProduct()
        }
    }

    func allSettingsSectionActionsForSimpleProduct() -> [ProductFormEditAction] {
        let shouldShowReviewsRow = product.reviewsAllowed
        let canEditProductType = formType != .add && editable
        let shouldShowShippingSettingsRow = product.isShippingEnabled()
        let shouldShowDownloadableProduct = product.downloadable
        let canEditInventorySettingsRow = editable && product.hasIntegerStockQuantity

        let actions: [ProductFormEditAction?] = [
            .priceSettings(editable: editable),
            shouldShowReviewsRow ? .reviews: nil,
            shouldShowShippingSettingsRow ? .shippingSettings(editable: editable): nil,
            .inventorySettings(editable: canEditInventorySettingsRow),
            .addOns(editable: editable),
            .categories(editable: editable),
            .tags(editable: editable),
            shouldShowDownloadableProduct ? .downloadableFiles(editable: editable): nil,
            .shortDescription(editable: editable),
            .linkedProducts(editable: editable),
            .productType(editable: canEditProductType)
        ]
        return actions.compactMap { $0 }
    }

    func allSettingsSectionActionsForAffiliateProduct() -> [ProductFormEditAction] {
        let shouldShowReviewsRow = product.reviewsAllowed
        let shouldShowExternalURLRow = editable || product.product.externalURL?.isNotEmpty == true
        let shouldShowSKURow = editable || product.sku?.isNotEmpty == true
        let canEditProductType = formType != .add && editable

        let actions: [ProductFormEditAction?] = [
            .priceSettings(editable: editable),
            shouldShowReviewsRow ? .reviews: nil,
            shouldShowExternalURLRow ? .externalURL(editable: editable): nil,
            shouldShowSKURow ? .sku(editable: editable): nil,
            .addOns(editable: editable),
            .categories(editable: editable),
            .tags(editable: editable),
            .shortDescription(editable: editable),
            .linkedProducts(editable: editable),
            .productType(editable: canEditProductType)
        ]
        return actions.compactMap { $0 }
    }

    func allSettingsSectionActionsForGroupedProduct() -> [ProductFormEditAction] {
        let shouldShowReviewsRow = product.reviewsAllowed
        let shouldShowSKURow = editable || product.sku?.isNotEmpty == true
        let canEditProductType = formType != .add && editable

        let actions: [ProductFormEditAction?] = [
            .groupedProducts(editable: editable),
            shouldShowReviewsRow ? .reviews: nil,
            shouldShowSKURow ? .sku(editable: editable): nil,
            .addOns(editable: editable),
            .categories(editable: editable),
            .tags(editable: editable),
            .shortDescription(editable: editable),
            .linkedProducts(editable: editable),
            .productType(editable: canEditProductType)
        ]
        return actions.compactMap { $0 }
    }

    func allSettingsSectionActionsForVariableProduct() -> [ProductFormEditAction] {
        let shouldShowReviewsRow = product.reviewsAllowed
        let canEditProductType = formType != .add && editable
        let canEditInventorySettingsRow = editable && product.hasIntegerStockQuantity
        let shouldShowNoPriceWarningRow: Bool = {
            let variationsHaveNoPriceSet = variationsPrice == .notSet
            let productHasNoPriceSet = variationsPrice == .unknown && product.product.variations.isNotEmpty && product.product.price.isEmpty
            return canEditProductType && (variationsHaveNoPriceSet || productHasNoPriceSet)
        }()

        let actions: [ProductFormEditAction?] = [
            .variations,
            shouldShowNoPriceWarningRow ? .noPriceWarning : nil,
            shouldShowReviewsRow ? .reviews: nil,
            .shippingSettings(editable: editable),
            .inventorySettings(editable: canEditInventorySettingsRow),
            .addOns(editable: editable),
            .categories(editable: editable),
            .tags(editable: editable),
            .shortDescription(editable: editable),
            .linkedProducts(editable: editable),
            .productType(editable: canEditProductType)
        ]
        return actions.compactMap { $0 }
    }

    func allSettingsSectionActionsForNonCoreProduct() -> [ProductFormEditAction] {
        let shouldShowPriceSettingsRow = product.regularPrice.isNilOrEmpty == false
        let shouldShowReviewsRow = product.reviewsAllowed

        let actions: [ProductFormEditAction?] = [
            shouldShowPriceSettingsRow ? .priceSettings(editable: false): nil,
            shouldShowReviewsRow ? .reviews: nil,
            .inventorySettings(editable: false),
            .categories(editable: editable),
            .addOns(editable: editable),
            .tags(editable: editable),
            .shortDescription(editable: editable),
            .linkedProducts(editable: editable),
            .productType(editable: false)
        ]
        return actions.compactMap { $0 }
    }
}

private extension ProductFormActionsFactory {
    func visibleSettingsSectionActions() -> [ProductFormEditAction] {
        return allSettingsSectionActions().compactMap({ $0 }).filter({ isVisibleInSettingsSection(action: $0) })
    }

    func isVisibleInSettingsSection(action: ProductFormEditAction) -> Bool {
        switch action {
        case .priceSettings:
            // The price settings action is always visible in the settings section.
            return true
        case .reviews:
            // The reviews action is always visible in the settings section.
            return true
        case .productType:
            // The product type action is always visible in the settings section.
            return true
        case .inventorySettings(let editable):
            guard editable else {
                // The inventory row is always visible when readonly.
                return true
            }
            let hasStockData = product.manageStock ? product.stockQuantity != nil: true
            return product.sku != nil || hasStockData
        case .shippingSettings:
            return product.weight.isNilOrEmpty == false ||
                product.dimensions.height.isNotEmpty || product.dimensions.width.isNotEmpty || product.dimensions.length.isNotEmpty
        case .addOns:
            return addOnsFeatureEnabled && product.hasAddOns
        case .categories:
            return product.product.categories.isNotEmpty
        case .tags:
            return product.product.tags.isNotEmpty
        case .linkedProducts:
            return (product.upsellIDs.count > 0 || product.crossSellIDs.count > 0)
        // Downloadable files. Only core product types for downloadable files are able to handle downloadable files.
        case .downloadableFiles:
            return product.downloadable
        case .shortDescription:
            return product.shortDescription.isNilOrEmpty == false
        // Affiliate products only.
        case .externalURL:
            // The external URL action is always visible in the settings section for an affiliate product.
            return true
        case .sku:
            return product.sku?.isNotEmpty == true
        // Grouped products only.
        case .groupedProducts:
            // The grouped products action is always visible in the settings section for a grouped product.
            return true
        // Variable products only.
        case .variations:
            // The variations row is always visible in the settings section for a variable product.
            return true
        case .noPriceWarning:
            // Always visible when available
            return true
        default:
            return false
        }
    }
}
