import UIKit


// TODO: Recenter map when increasing window size

class VTZoomableScrollView: UIScrollView, UIScrollViewDelegate {
    var zoomableView: UIView? {
        willSet {
            // remove the old zoomableView
            zoomableView?.removeFromSuperview()
        }
        didSet {
            guard let view = zoomableView else { return }
            addSubview(view)
            zoomScale = 1.0
            contentSize = view.frame.size
            centerZoomableView()
        }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        delegate = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }

    private func centerZoomableView() {
        guard let zoomableView else { return }
        let scrollSize = bounds.size
        let size = zoomableView.frame.size
        let offsetX = max((scrollSize.width - size.width * zoomScale) / 2, 0)
        let offsetY = max((scrollSize.height - size.height * zoomScale) / 2, 0)
        contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }

    // MARK: - UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomableView
    }
}
