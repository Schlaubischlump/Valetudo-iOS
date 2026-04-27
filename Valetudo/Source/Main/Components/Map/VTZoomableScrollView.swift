import UIKit

/// A scroll view that keeps a single child view zoomable and centered.
///
/// The scroll view computes a fit-to-bounds minimum zoom scale for the current
/// `zoomableView`, recenters the content when its own bounds change, and keeps
/// the content centered while the user zooms.
class VTZoomableScrollView: UIScrollView, UIScrollViewDelegate {
    private var preferredMinimumZoomScale: CGFloat?
    private var preferredMaximumZoomScale: CGFloat?
    private var lastBoundsSize: CGSize = .zero

    /// The single view managed by the scroll view for zooming and panning.
    ///
    /// Assigning a new view removes the old one, installs the new one as a
    /// subview, recomputes the fitting zoom scales, and recenters it.
    var zoomableView: UIView? {
        willSet {
            zoomableView?.removeFromSuperview()
        }
        didSet {
            guard let zoomableView else { return }

            addSubview(zoomableView)
            lastBoundsSize = .zero
            updateZoomScalesIfNeeded()
            centerZoomableView()
        }
    }

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
        bouncesZoom = true
    }

    /// Recomputes the fitting zoom range for the current bounds and content.
    ///
    /// If the current zoom level is still effectively the previous fitted scale,
    /// the content is refit to the new bounds. Otherwise the current relative
    /// zoom level is preserved across resizes.
    private func updateZoomScalesIfNeeded() {
        guard let zoomableView,
              bounds.width > 0,
              bounds.height > 0,
              zoomableView.bounds.width > 0,
              zoomableView.bounds.height > 0 else { return }

        if preferredMinimumZoomScale == nil {
            preferredMinimumZoomScale = minimumZoomScale
        }

        if preferredMaximumZoomScale == nil {
            preferredMaximumZoomScale = maximumZoomScale
        }

        let fitScale = min(
            bounds.width / zoomableView.bounds.width,
            bounds.height / zoomableView.bounds.height
        )
        let minimumScale = min(preferredMinimumZoomScale ?? 1.0, fitScale)
        let maximumScale = max(preferredMaximumZoomScale ?? minimumScale, minimumScale)

        let previousMinimumScale = minimumZoomScale
        let previousZoomScale = zoomScale
        let shouldRefit = lastBoundsSize == .zero || abs(previousZoomScale - previousMinimumScale) < 0.01

        minimumZoomScale = minimumScale
        maximumZoomScale = maximumScale

        if shouldRefit {
            zoomScale = minimumScale
        } else if previousMinimumScale > 0 {
            let relativeZoom = previousZoomScale / previousMinimumScale
            zoomScale = min(max(minimumScale * relativeZoom, minimumScale), maximumScale)
        }

        lastBoundsSize = bounds.size
    }

    /// Centers the zoomed content when it is smaller than the available bounds.
    private func centerZoomableView() {
        guard let zoomableView else { return }

        let contentSize = zoomableView.frame.size
        var frame = zoomableView.frame

        frame.origin.x = contentSize.width < bounds.width ? (bounds.width - contentSize.width) / 2 : 0
        frame.origin.y = contentSize.height < bounds.height ? (bounds.height - contentSize.height) / 2 : 0

        zoomableView.frame = frame
    }

    /// Updates fitting and centering when the scroll view's bounds change.
    override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.size != lastBoundsSize {
            updateZoomScalesIfNeeded()
        }

        centerZoomableView()
    }

    /// Returns the managed content view for pinch zooming.
    func viewForZooming(in _: UIScrollView) -> UIView? {
        zoomableView
    }

    /// Recenters the content after UIKit updates the zoomed frame.
    func scrollViewDidZoom(_: UIScrollView) {
        centerZoomableView()
    }
}
