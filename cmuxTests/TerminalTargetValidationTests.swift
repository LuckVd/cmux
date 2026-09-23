import Foundation
import Testing
#if canImport(cmux_DEV)
@testable import cmux_DEV
#elseif canImport(cmux)
@testable import cmux
#endif

@Suite(.serialized)
@MainActor
struct TerminalTargetValidationTests {
    @Test(arguments: ["terminal.paste", "mobile.terminal.paste", "surface.read_text"])
    func socketRejectsUnrecognizedSurfaceBeforeResolvingTarget(method: String) async throws {
        let request: [String: Any] = [
            "id": "target-validation",
            "method": method,
            "params": ["surface": UUID().uuidString, "text": "MARKER", "submit_key": "none"]
        ]
        let data = try JSONSerialization.data(withJSONObject: request)
        let line = try #require(String(data: data, encoding: .utf8))
        let response = try #require(await TerminalController.shared.processCommandUsingSocketExecutionPolicyAsync(line))
        let payload = try #require(JSONSerialization.jsonObject(with: Data(response.utf8)) as? [String: Any])
        #expect(payload["ok"] as? Bool == false)
        let error = try #require(payload["error"] as? [String: Any])
        #expect(error["code"] as? String == "invalid_params")
    }

}
