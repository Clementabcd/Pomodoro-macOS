import Foundation

func loc(_ key: String) -> String {
    #if SWIFT_PACKAGE
    NSLocalizedString(key, bundle: .module, comment: "")
    #else
    NSLocalizedString(key, bundle: .main, comment: "")
    #endif
}
