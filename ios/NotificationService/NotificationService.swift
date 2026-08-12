import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent else { return }
        
        // Tenta obter a URL da imagem (do FCM fcm_options ou payload customizado)
        var imageUrlString: String? = nil
        
        if let fcmOptions = request.content.userInfo["fcm_options"] as? [String: Any] {
            imageUrlString = fcmOptions["image"] as? String
        }
        
        if imageUrlString == nil {
            imageUrlString = request.content.userInfo["image-url"] as? String
        }

        guard let urlString = imageUrlString, let fileUrl = URL(string: urlString) else {
            contentHandler(bestAttemptContent)
            return
        }

        // Faz o download da imagem
        let session = URLSession(configuration: .default)
        let downloadTask = session.downloadTask(with: fileUrl) { (location, response, error) in
            guard let location = location, error == nil else {
                contentHandler(bestAttemptContent)
                return
            }

            // Define a extensão do arquivo temporário (.jpg/.png)
            let fileManager = FileManager.default
            let tmpSubFolder = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
            
            try? fileManager.createDirectory(at: tmpSubFolder, withIntermediateDirectories: true, attributes: nil)
            let fileExtension = fileUrl.pathExtension.isEmpty ? "jpg" : fileUrl.pathExtension
            let destinationUrl = tmpSubFolder.appendingPathComponent("image.\(fileExtension)")

            try? fileManager.moveItem(at: location, to: destinationUrl)

            // Cria o anexo do iOS
            if let attachment = try? UNNotificationAttachment(identifier: "image_attachment", url: destinationUrl, options: nil) {
                bestAttemptContent.attachments = [attachment]
            }

            contentHandler(bestAttemptContent)
        }
        downloadTask.resume()
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}