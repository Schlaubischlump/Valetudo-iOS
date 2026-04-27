import Foundation

enum CollectedErrors: Error, CustomStringConvertible {
    case multiple([Error])

    var description: String {
        switch self {
        case let .multiple(errors):
            errors.map { "\($0)" }.joined(separator: "\n")
        }
    }
}

func collecting<T>(_ block: (_ run: (_ f: () throws -> Void) -> Void) throws -> T) throws -> T {
    var errors: [Error] = []

    func run(_ f: () throws -> Void) {
        do {
            try f()
        } catch {
            errors.append(error)
        }
    }

    let result = try block(run)

    if !errors.isEmpty {
        throw CollectedErrors.multiple(errors)
    }

    return result
}

private actor ErrorCollector {
    private(set) var errors: [Error] = []

    func append(_ error: Error) {
        errors.append(error)
    }
}

func collecting<T: Sendable>(
    _ block: @MainActor (_ run: (_ f: @MainActor () async throws -> Void) async -> Void) async throws -> T
) async throws -> T {
    let collector = ErrorCollector()

    func run(_ f: @MainActor () async throws -> Void) async {
        do { try await f() }
        catch { await collector.append(error) }
    }

    let result = try await block(run)
    let errors = await collector.errors

    if !errors.isEmpty {
        throw CollectedErrors.multiple(errors)
    }

    return result
}

/// Retries an async throwing operation up to `maxRetries` times.
/// - Parameters:
///   - maxRetries: Maximum number of attempts (≥ 1).
///   - delay: Optional delay between retries (in seconds).
///   - operation: The async closure to execute, which may throw.
/// - Returns: The successful result of the operation.
/// - Throws: The last thrown error if all retries fail.
func retry<T>(
    maxRetries: Int,
    delay: TimeInterval? = nil,
    operation: @Sendable @escaping () async throws -> T
) async throws -> T {
    precondition(maxRetries > 0, "maxRetries must be at least 1")

    var lastError: Error?

    for attempt in 1 ... maxRetries {
        do {
            return try await operation()
        } catch {
            lastError = error

            // If not the last attempt, wait before retrying
            if attempt < maxRetries, let delay {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            } else if attempt == maxRetries {
                throw error
            }
        }
    }

    throw lastError!
}
