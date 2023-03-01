public struct TransformOptions {
    public var width: Int?
    public var height: Int?
    public var resize: String?
    public var quality: Int?
    public var format: String?
    
    public init(
        width: Int? = nil,
        height: Int? = nil,
        resize: String? = "cover",
        quality: Int? = 80,
        format: String? = "origin"
    ) {
        self.width = width
        self.height = height
        self.resize = resize
        self.quality = quality
        self.format = format
    }
    
    func asQueryString() -> String {
        var parameters = [String]()
        
        if let width = width {
            parameters.append("width=\(width)")
        }
        
        if let height = height {
            parameters.append("height=\(height)")
        }
        
        if let resize = resize {
            parameters.append("resize=\(resize)")
        }
        
        if let format = format {
            parameters.append("format=\(format)")
        }
        
        if let quality = quality {
            parameters.append("quality=\(quality)")
        }
        
        return parameters.joined(separator: "&")
    }
}
