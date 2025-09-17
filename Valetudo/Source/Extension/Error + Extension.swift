enum CollectedErrors: Error, CustomStringConvertible {
    case multiple([Error])

    var description: String {
        switch self {
        case .multiple(let errors):
            return errors.map { "\($0)" }.joined(separator: "\n")
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

fileprivate actor ErrorCollector {
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

