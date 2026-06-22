import UIKit

/// Converts a `NarrativeDocument` into shareable files.
///
/// Two formats are supported:
///
/// - **Markdown** (`life-narrative.md`): a plain-text file that preserves the
///   narrative headings and prose exactly as the LLM wrote them.
/// - **PDF** (`life-narrative.pdf`): a typeset A4 document suitable for printing
///   or archiving, rendered via `UIGraphicsPDFRenderer`.
///
/// Both files are written to `tmp/` and the `URL` values can be dropped directly
/// into a `UIActivityViewController` (i.e. `ShareSheet`).
struct NarrativeExportService {

    // MARK: - Markdown

    /// Returns the formatted Markdown string.
    func markdown(document: NarrativeDocument) -> String {
        let dateStr = document.updatedAt.formatted(date: .long, time: .omitted)
        return """
        # My Story

        *Last updated: \(dateStr)*
        *\(document.sessionCount) session\(document.sessionCount == 1 ? "" : "s") woven in*

        ---

        \(document.content)
        """
    }

    /// Writes the Markdown to `tmp/life-narrative.md` and returns the `URL`,
    /// or `nil` on error.
    @discardableResult
    func writeMarkdown(document: NarrativeDocument) -> URL? {
        let text = markdown(document: document)
        let dest = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("life-narrative.md")
        do {
            try text.write(to: dest, atomically: true, encoding: .utf8)
            return dest
        } catch {
            return nil
        }
    }

    // MARK: - PDF

    /// Renders the narrative as a PDF document at `tmp/life-narrative.pdf`
    /// and returns the `URL`, or `nil` on error.
    func writePDF(document: NarrativeDocument) -> URL? {
        let pageSize   = CGSize(width: 595, height: 842)   // A4 in points
        let margin: CGFloat = 56
        let textRect   = CGRect(x: margin, y: margin,
                                width: pageSize.width - margin * 2,
                                height: pageSize.height - margin * 2)

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))

        let dest = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("life-narrative.pdf")

        do {
            try renderer.writePDF(to: dest) { ctx in
                // --- Title page ---
                ctx.beginPage()
                let titleAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont(name: "Georgia-Bold", size: 28) ?? UIFont.boldSystemFont(ofSize: 28),
                    .foregroundColor: UIColor(red: 0.2, green: 0.15, blue: 0.08, alpha: 1),
                ]
                let subtitleAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont(name: "Georgia-Italic", size: 13) ?? UIFont.italicSystemFont(ofSize: 13),
                    .foregroundColor: UIColor.darkGray,
                ]
                let titleStr = NSAttributedString(string: "My Story", attributes: titleAttrs)
                let dateStr  = document.updatedAt.formatted(date: .long, time: .omitted)
                let subStr   = NSAttributedString(string: "Last updated: \(dateStr)", attributes: subtitleAttrs)

                titleStr.draw(at: CGPoint(x: margin, y: 140))
                subStr.draw(at: CGPoint(x: margin, y: 180))

                // Decorative rule
                let ruleRect = CGRect(x: margin, y: 200, width: pageSize.width - margin * 2, height: 0.5)
                UIColor(red: 0.7, green: 0.5, blue: 0.2, alpha: 0.5).setFill()
                UIRectFill(ruleRect)

                // --- Content pages ---
                let bodyAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont(name: "Georgia", size: 12) ?? UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor(white: 0.12, alpha: 1),
                    .paragraphStyle: bodyParagraphStyle(),
                ]
                let headingAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont(name: "Georgia-Bold", size: 15) ?? UIFont.boldSystemFont(ofSize: 15),
                    .foregroundColor: UIColor(white: 0.1, alpha: 1),
                    .paragraphStyle: bodyParagraphStyle(),
                ]

                // Convert Markdown headings to bold and strip markers for PDF.
                let lines = document.content.components(separatedBy: "\n")
                let attrBody = NSMutableAttributedString()
                for (i, line) in lines.enumerated() {
                    let isHeading = line.hasPrefix("## ")
                    let text = isHeading ? String(line.dropFirst(3)) : line
                    let attrs = isHeading ? headingAttrs : bodyAttrs
                    attrBody.append(NSAttributedString(string: text, attributes: attrs))
                    if i < lines.count - 1 {
                        attrBody.append(NSAttributedString(string: "\n", attributes: bodyAttrs))
                    }
                }

                var origin = textRect.origin
                var remainingAttr = attrBody
                while remainingAttr.length > 0 {
                    ctx.beginPage()
                    let available = CGRect(origin: origin, size: textRect.size)
                    let fitted = fittedText(remainingAttr, in: available)
                    fitted.string.draw(in: available)
                    let drawnLength = fitted.length
                    if drawnLength >= remainingAttr.length { break }
                    remainingAttr = remainingAttr.attributedSubstring(
                        from: NSRange(location: drawnLength, length: remainingAttr.length - drawnLength)
                    ) as! NSMutableAttributedString
                    origin = textRect.origin
                }
            }
            return dest
        } catch {
            return nil
        }
    }

    // MARK: - Helpers

    private func bodyParagraphStyle() -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        style.paragraphSpacing = 8
        return style
    }

    /// Returns the portion of `attrStr` that fits within `rect` and its rendered length.
    private func fittedText(_ attrStr: NSAttributedString, in rect: CGRect) -> (string: NSAttributedString, length: Int) {
        let setter = CTFramesetterCreateWithAttributedString(attrStr)
        var fitRange = CFRange()
        CTFramesetterSuggestFrameSizeWithConstraints(setter, CFRange(), nil, rect.size, &fitRange)
        let length = min(fitRange.length, attrStr.length)
        let fitted = attrStr.attributedSubstring(from: NSRange(location: 0, length: length))
        return (fitted, length)
    }
}
