import UIKit

@IBDesignable class CustomLabel: UILabel
{
	@IBInspectable var borderColor: UIColor = .clear // 枠線の色
	@IBInspectable var borderWidth: CGFloat = 0.0 // 枠線の太さ
	@IBInspectable var cornerRadius: CGFloat = 0.0 // 枠線の角丸
	@IBInspectable var leftPadding: CGFloat = 0.0 // 左の余白
	@IBInspectable var rightPadding: CGFloat = 0.0 // 右の余白

	override func drawText(in rect: CGRect)
	{
		let padding = UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: rightPadding)
		super.drawText(in: rect.inset(by: padding))
	}

	override func draw(_ rect: CGRect)
	{
		layer.borderColor = borderColor.cgColor
		layer.borderWidth = borderWidth
		layer.cornerRadius = cornerRadius
		super.draw(rect)
	}
}
