// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -typecheck -enable-library-evolution -enable-experimental-concurrency -emit-module-interface-path %t/Library.swiftinterface -DLIBRARY -module-name Library %s

// REQUIRES: concurrency

#if LIBRARY
@available(SwiftStdlib 5.5, *)
public func fn() async {
  fatalError()
}

@available(SwiftStdlib 5.5, *)
public func reasyncFn(_: () async -> ()) reasync {
  fatalError()
}

@available(SwiftStdlib 5.5, *)
public func takesSendable(
  _ block: @Sendable @escaping () async throws -> Void
) { }

// RUN: %target-typecheck-verify-swift -enable-experimental-concurrency -I %t

#else
import Library

@available(SwiftStdlib 5.5, *)
func callFn() async {
  await fn()
}
#endif

// RUN: %FileCheck %s <%t/Library.swiftinterface
// CHECK: // swift-module-flags:{{.*}} -enable-experimental-concurrency
// CHECK: public func fn() async
// CHECK: public func reasyncFn(_: () async -> ()) reasync
// CHECK: public func takesSendable(_ block: @escaping @Sendable () async throws ->

// RUN: %target-swift-frontend -typecheck -enable-library-evolution -enable-experimental-concurrency -emit-module-interface-path %t/Library.swiftinterface -DLIBRARY -module-name Library %s -module-interface-preserve-types-as-written
// RUN: %FileCheck %s <%t/Library.swiftinterface
