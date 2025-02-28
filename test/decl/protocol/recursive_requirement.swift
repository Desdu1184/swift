// RUN: %target-typecheck-verify-swift

// -----

protocol Foo {
  associatedtype Bar : Foo
}

struct Oroborous : Foo {
  typealias Bar = Oroborous
}

// -----

protocol P {
 associatedtype A : P
}

struct X<T: P> {
}

func f<T : P>(_ z: T) {
 _ = X<T.A>()
}

// -----

protocol PP2 {
  associatedtype A : P2 = Self
}

protocol P2 : PP2 {
  associatedtype A = Self
}

struct X2<T: P2> {
}

struct Y2 : P2 {
  typealias A = Y2
}

func f<T : P2>(_ z: T) {
 _ = X2<T.A>()
}

// -----

protocol P3 {
 associatedtype A: P4 = Self
}

protocol P4 : P3 {}

protocol DeclaredP : P3, // expected-warning{{redundant conformance constraint 'Self' : 'P3'}}
P4 {} // expected-note{{conformance constraint 'Self' : 'P3' implied here}}

struct Y3 : DeclaredP {
}

struct X3<T:P4> {}

func f2<T:P4>(_ a: T) {
 _ = X3<T.A>()
}

f2(Y3())

// -----

protocol Alpha {
  associatedtype Beta: Gamma
}

protocol Gamma {
  associatedtype Delta: Alpha
}

struct Epsilon<T: Alpha, // expected-note{{conformance constraint 'U' : 'Gamma' implied here}}
               U: Gamma> // expected-warning{{redundant conformance constraint 'U' : 'Gamma'}}
  where T.Beta == U,
        U.Delta == T {}

// -----

protocol AsExistentialA {
  var delegate : AsExistentialB? { get }
}
protocol AsExistentialB {
  func aMethod(_ object : AsExistentialA)
}

protocol AsExistentialAssocTypeA {
  var delegate : AsExistentialAssocTypeB? { get } // expected-warning {{use of protocol 'AsExistentialAssocTypeB' as a type must be written 'any AsExistentialAssocTypeB'}}
}
protocol AsExistentialAssocTypeB {
  func aMethod(_ object : AsExistentialAssocTypeA)
  associatedtype Bar
}

protocol AsExistentialAssocTypeAgainA {
  var delegate : AsExistentialAssocTypeAgainB? { get }
  associatedtype Bar
}
protocol AsExistentialAssocTypeAgainB {
  func aMethod(_ object : AsExistentialAssocTypeAgainA) // expected-warning {{use of protocol 'AsExistentialAssocTypeAgainA' as a type must be written 'any AsExistentialAssocTypeAgainA'}}
}

// SR-547
protocol A {
    associatedtype B1: B
    associatedtype C1: C
    
    mutating func addObserver(_ observer: B1, forProperty: C1)
}

protocol C {
    
}

protocol B {
    associatedtype BA: A
    associatedtype BC: C
    
    func observeChangeOfProperty(_ property: BC, observable: BA)
}
