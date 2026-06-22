import SwiftUI

/// Renders a string as styled markdown (bold, italic, code, lists, links).
/// Falls back to plain `Text` if the markdown cannot be parsed, so the view
/// never shows an empty bubble on a bad parse.
///
/// Handles the `AttributedString(markdown:)` initialiser added in iOS 15.
struct MarkdownText: View {
    let raw: String

    init(_ raw: String) {
        self.raw = raw
    }

    var body: some View {
        Text(attributed)
            .textSelection(.enabled)
    }

    private var attributed: AttributedString {
        (try? AttributedString(
            markdown: raw,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlinesOnlyPreservingWhitespace
            )
        )) ?? AttributedString(raw)
    }
}
