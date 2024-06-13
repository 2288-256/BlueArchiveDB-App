import UIKit

class CustomTextView: UITextView
{
	@IBInspectable var borderColor: UIColor = .clear // 枠線の色
	@IBInspectable var borderWidth: CGFloat = 0.0 // 枠線の太さ
	@IBInspectable var cornerRadius: CGFloat = 0.0 // 枠線の角丸
	@IBInspectable var leftPadding: CGFloat = 0.0 // 左の余白

	override func draw(_ rect: CGRect)
	{
		layer.borderColor = borderColor.cgColor
		layer.borderWidth = borderWidth
		layer.cornerRadius = cornerRadius
		super.draw(rect)
	}
}
