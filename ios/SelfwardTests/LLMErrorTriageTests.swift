import XCTest
@testable import Selfward

// MARK: - Retry classification

final class LLMRetryClassificationTests: XCTestCase {

    func testClassify429AsRateLimitedWithRetryAfter() {
        let error = LLMErrorTriage.classifyHTTPFailure(
            status: 429,
            retryAfter: "12",
            data: Data("too many requests".utf8),
            apiKey: "sekret"
        )
        guard case .rateLimited(let retryAfter) = error, retryAfter == 12 else {
            return XCTFail("Expected .rateLimited(12), got \(error)")
        }
    }

    func testClassify529AsRateLimited() {
        let error = LLMErrorTriage.classifyHTTPFailure(
            status: 529,
            retryAfter: nil,
            data: Data("model overloaded".utf8),
            apiKey: ""
        )
        guard case .rateLimited = error else {
            return XCTFail("Expected .rateLimited, got \(error)")
        }
    }

    func testClassify413ContextHintsAsContextLengthExceeded() {
        let error = LLMErrorTriage.classifyHTTPFailure(
            status: 413,
            retryAfter: nil,
            data: Data(#"{"error":"this model's maximum context length is 32768 tokens"}"#.utf8),
            apiKey: ""
        )
        guard case .contextLengthExceeded = error else {
            return XCTFail("Expected .contextLengthExceeded, got \(error)")
        }
    }

    func testClassifyGeneric400AsApiError() {
        let error = LLMErrorTriage.classifyHTTPFailure(
            status: 400,
            retryAfter: nil,
            data: Data("invalid api key".utf8),
            apiKey: "sekret"
        )
        guard case .apiError(let msg) = error else {
            return XCTFail("Expected .apiError, got \(error)")
        }
        XCTAssertFalse(msg.contains("sekret"), "API key must never leak into the surfaced error")
    }

    func testIsRateLimitLikeMatchesBodyHeuristics() {
        XCTAssertTrue(LLMErrorTriage.isRateLimitLike(LLMError.apiError("HTTP 429: too many requests")))
        XCTAssertTrue(LLMErrorTriage.isRateLimitLike(LLMError.apiError("stream closed, provider overloaded")))
        XCTAssertFalse(LLMErrorTriage.isRateLimitLike(LLMError.apiError("HTTP 500: internal error")))
        XCTAssertFalse(LLMErrorTriage.isRateLimitLike(LLMError.emptyResponse))
    }
}
