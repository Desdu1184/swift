// RUN: %target-typecheck-verify-swift -requirement-machine-protocol-signatures=on -requirement-machine-inferred-signatures=on

func testInvalidConformance() {
  // expected-error@+1 {{type 'T' constrained to non-protocol, non-class type 'Int'}}
  func invalidIntConformance<T>(_: T) where T: Int {}

  // expected-error@+1 {{type 'T' constrained to non-protocol, non-class type 'Int'}}
  struct InvalidIntConformance<T: Int> {}

  struct S<T> {
    // expected-error@+2 {{type 'T' constrained to non-protocol, non-class type 'Int'}}
    // expected-note@+1 {{use 'T == Int' to require 'T' to be 'Int'}}
    func method() where T: Int {}
  }
}

// Check directly-concrete same-type constraints
typealias NotAnInt = Double

protocol X {}

// expected-error@+1{{generic signature requires types 'Double' and 'Int' to be the same}}
extension X where NotAnInt == Int {}

protocol EqualComparable {
  func isEqual(_ other: Self) -> Bool
}

func badTypeConformance1<T>(_: T) where Int : EqualComparable {} // expected-error{{type 'Int' in conformance requirement does not refer to a generic parameter or associated type}}

func badTypeConformance2<T>(_: T) where T.Blarg : EqualComparable { } // expected-error{{'Blarg' is not a member type of type 'T'}}

func badTypeConformance3<T>(_: T) where (T) -> () : EqualComparable { }
// expected-error@-1{{type '(T) -> ()' in conformance requirement does not refer to a generic parameter or associated type}}

func badTypeConformance4<T>(_: T) where (inout T) throws -> () : EqualComparable { }
// expected-error@-1{{type '(inout T) throws -> ()' in conformance requirement does not refer to a generic parameter or associated type}}

func badTypeConformance5<T>(_: T) where T & Sequence : EqualComparable { }
// expected-error@-1 {{non-protocol, non-class type 'T' cannot be used within a protocol-constrained type}}

func badTypeConformance6<T>(_: T) where [T] : Collection { }
// expected-warning@-1{{redundant conformance constraint '[T]' : 'Collection'}}

func concreteSameTypeRedundancy<T>(_: T) where Int == Int {}
// expected-warning@-1{{redundant same-type constraint 'Int' == 'Int'}}

func concreteSameTypeRedundancy<T>(_: T) where Array<Int> == Array<T> {}
// expected-warning@-1{{redundant same-type constraint 'Array<Int>' == 'Array<T>'}}

protocol P {}
struct S: P {}
func concreteConformanceRedundancy<T>(_: T) where S : P {}
// expected-warning@-1{{redundant conformance constraint 'S' : 'P'}}

class C {}
func concreteLayoutRedundancy<T>(_: T) where C : AnyObject {}
// expected-warning@-1{{redundant constraint 'C' : 'AnyObject'}}

func concreteLayoutConflict<T>(_: T) where Int : AnyObject {}
// expected-error@-1{{type 'Int' in conformance requirement does not refer to a generic parameter or associated type}}

class C2: C {}
func concreteSubclassRedundancy<T>(_: T) where C2 : C {}
// expected-warning@-1{{redundant superclass constraint 'C2' : 'C'}}

class D {}
func concreteSubclassConflict<T>(_: T) where D : C {}
// expected-error@-1{{type 'D' in conformance requirement does not refer to a generic parameter or associated type}}

protocol UselessProtocolWhereClause where Int == Int {}
// expected-warning@-1 {{redundant same-type constraint 'Int' == 'Int'}}

protocol InvalidProtocolWhereClause where Self: Int {}
// expected-error@-1 {{type 'Self' constrained to non-protocol, non-class type 'Int'}}

typealias Alias<T> = T where Int == Int
// expected-warning@-1 {{redundant same-type constraint 'Int' == 'Int'}}

func cascadingConflictingRequirement<T>(_: T) where DoesNotExist : EqualComparable { }
// expected-error@-1 {{cannot find type 'DoesNotExist' in scope}}

func cascadingInvalidConformance<T>(_: T) where T : DoesNotExist { }
// expected-error@-1 {{cannot find type 'DoesNotExist' in scope}}

func trivialRedundant1<T>(_: T) where T: P, T: P {}
// expected-warning@-1 {{redundant conformance constraint 'T' : 'P'}}

func trivialRedundant2<T>(_: T) where T: AnyObject, T: AnyObject {}
// expected-warning@-1 {{redundant constraint 'T' : 'AnyObject'}}

func trivialRedundant3<T>(_: T) where T: C, T: C {}
// expected-warning@-1 {{redundant superclass constraint 'T' : 'C'}}

func trivialRedundant4<T>(_: T) where T == T {}
// expected-warning@-1 {{redundant same-type constraint 'T' == 'T'}}

protocol TrivialRedundantConformance: P, P {}
// expected-warning@-1 {{redundant conformance constraint 'Self' : 'P'}}

protocol TrivialRedundantLayout: AnyObject, AnyObject {}
// expected-warning@-1 {{redundant constraint 'Self' : 'AnyObject'}}
// expected-error@-2 {{duplicate inheritance from 'AnyObject'}}

protocol TrivialRedundantSuperclass: C, C {}
// expected-warning@-1 {{redundant superclass constraint 'Self' : 'C'}}
// expected-error@-2 {{duplicate inheritance from 'C'}}

protocol TrivialRedundantSameType where Self == Self {
// expected-warning@-1 {{redundant same-type constraint 'Self' == 'Self'}}
  associatedtype T where T == T
  // expected-warning@-1 {{redundant same-type constraint 'Self.T' == 'Self.T'}}
}

struct G<T> { }

protocol Pair {
  associatedtype A
  associatedtype B
}

func test1<T: Pair>(_: T) where T.A == G<Int>, T.A == G<T.B>, T.B == Int { }
// expected-warning@-1 {{redundant same-type constraint 'T.A' == 'G<T.B>'}}


protocol P1 {
  func p1()
}

protocol P2 : P1 { }

protocol P3 {
  associatedtype P3Assoc : P2
}

protocol P4 {
  associatedtype P4Assoc : P1
}

func inferSameType2<T : P3, U : P4>(_: T, _: U) where U.P4Assoc : P2, T.P3Assoc == U.P4Assoc {}
// expected-warning@-1{{redundant conformance constraint 'U.P4Assoc' : 'P2'}}

protocol P5 {
  associatedtype Element
}

protocol P6 {
  associatedtype AssocP6 : P5
}

protocol P7 : P6 {
  associatedtype AssocP7: P6
}

// expected-warning@+1{{redundant conformance constraint 'Self.AssocP6.Element' : 'P6'}}
extension P7 where AssocP6.Element : P6,
        AssocP7.AssocP6.Element : P6,
        AssocP6.Element == AssocP7.AssocP6.Element {
  func nestedSameType1() { }
}

protocol P8 {
  associatedtype A
  associatedtype B
}

protocol P9 : P8 {
  associatedtype A
  associatedtype B
}

protocol P10 {
  associatedtype A
  associatedtype C
}

class X3 { }

func sameTypeConcrete2<T : P9 & P10>(_: T) where T.B : X3, T.C == T.B, T.C == X3 { }
// expected-warning@-1{{redundant superclass constraint 'T.B' : 'X3'}}


// Redundant requirement warnings are suppressed for inferred requirements.

protocol P11 {
 associatedtype X
 associatedtype Y
 associatedtype Z
}

func inferred1<T : Hashable>(_: Set<T>) {}
func inferred2<T>(_: Set<T>) where T: Hashable {}
func inferred3<T : P11>(_: T) where T.X : Hashable, T.Z == Set<T.Y>, T.X == T.Y {}
func inferred4<T : P11>(_: T) where T.Z == Set<T.Y>, T.X : Hashable, T.X == T.Y {}
func inferred5<T : P11>(_: T) where T.Z == Set<T.X>, T.Y : Hashable, T.X == T.Y {}
func inferred6<T : P11>(_: T) where T.Y : Hashable, T.Z == Set<T.X>, T.X == T.Y {}
