// RUN: %target-typecheck-verify-swift -requirement-machine-inferred-signatures=verify
// RUN: %target-swift-frontend -typecheck %s -debug-generic-signatures -requirement-machine-inferred-signatures=verify 2>&1 | %FileCheck %s

class S<T, U> where T : P, U == T.T {}

protocol P {
  associatedtype T
}

struct G<X, T, U> {}

class C : P {
  typealias T = Int
}

// CHECK-LABEL: Generic signature: <X, T, U where X : S<T, Int>, T : C, U == Int>
extension G where X : S<T, U>, T : C {}
