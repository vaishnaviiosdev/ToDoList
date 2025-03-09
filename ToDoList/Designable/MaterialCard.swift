
import UIKit

@IBDesignable
public class MaterialCard: UIView {

    @IBInspectable open var shadowOffsetWidth: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var shadowOffsetHeight: CGFloat = 0.5 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var customShadowColor: UIColor = .black {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var customShadowOpacity: Float = 0.5 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var customCornerRadius: CGFloat = 10 {
        didSet { setNeedsLayout() }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = customCornerRadius
        layer.masksToBounds = false

        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: customCornerRadius)
        layer.shadowPath = shadowPath.cgPath
        
        layer.shadowColor = customShadowColor.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
        layer.shadowOpacity = customShadowOpacity
        layer.masksToBounds = false
    }
}



