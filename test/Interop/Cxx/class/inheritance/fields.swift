// RUN: %target-run-simple-swift(-I %S/Inputs/ -Xfrontend -enable-cxx-interop)
//
// REQUIRES: executable_test
//
// Windows doesn't support -lc++ or -lstdc++.
// UNSUPPORTED: OS=windows-msvc

import StdlibUnittest
import Fields

var FieldsTestSuite = TestSuite("Getting and setting fields in base classes")

FieldsTestSuite.test("Fields from derived from all") {
  let derived = DerivedFromAll()
  expectEqual(derived.a, 1)
  expectEqual(derived.b, 2)
  expectEqual(derived.c, 3)
  expectEqual(derived.d, 4)
  expectEqual(derived.e, 5)
  expectEqual(derived.f, 6)

  var mutable = DerivedFromAll()
  mutable.a = 42
  mutable.d = 44
  mutable.e = 46
  mutable.f = 48

  expectEqual(mutable.a, 42)
  expectEqual(mutable.d, 44)
  expectEqual(mutable.e, 46)
  expectEqual(mutable.f, 48)
}

FieldsTestSuite.test("Fields from derived from non trivial") {
  let derived = NonTrivialDerivedFromAll()
  expectEqual(derived.a, 1)
  expectEqual(derived.b, 2)
  expectEqual(derived.c, 3)
  expectEqual(derived.d, 4)
  expectEqual(derived.e, 5)
  expectEqual(derived.f, 6)

  var mutable = NonTrivialDerivedFromAll()
  mutable.a = 42
  mutable.d = 44
  mutable.e = 46
  mutable.f = 48

  expectEqual(mutable.a, 42)
  expectEqual(mutable.d, 44)
  expectEqual(mutable.e, 46)
  expectEqual(mutable.f, 48)
}

FieldsTestSuite.test("Derived from class template") {
  var derived = DerivedFromClassTemplate()
  derived.value = 42
  expectEqual(derived.value, 42)
}

runAllTests()
