#if canImport(UIKit)
import CoreImage
import UIKit

public enum QRServiceError: Error {
    case generationFailed
}

public final class QRService {
    private let context = CIContext()

    public init() {}

    public func generateImage(from payload: String) throws -> UIImage {
        guard let data = payload.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else {
            throw QRServiceError.generationFailed
        }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")

        guard let ciImage = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 8, y: 8)),
              let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            throw QRServiceError.generationFailed
        }

        return UIImage(cgImage: cgImage)
    }
}
#endif
