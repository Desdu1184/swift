// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend-emit-module -emit-module-path %t/FakeDistributedActorSystems.swiftmodule -module-name FakeDistributedActorSystems -disable-availability-checking %S/../Inputs/FakeDistributedActorSystems.swift
// RUN: %target-build-swift -module-name main -Xfrontend -disable-availability-checking -j2 -parse-as-library -I %t %s %S/../Inputs/FakeDistributedActorSystems.swift -o %t/a.out
// RUN: %target-run %t/a.out | %FileCheck %s --enable-var-scope --color

// X: %target-run-simple-swift( -Xfrontend -module-name=main -Xfrontend -disable-availability-checking  -parse-as-library -Xfrontend -I -Xfrontend %t ) | %FileCheck %s

// REQUIRES: executable_test
// REQUIRES: concurrency
// REQUIRES: distributed

// rdar://76038845
// UNSUPPORTED: use_os_stdlib
// UNSUPPORTED: back_deployment_runtime

// FIXME(distributed): Distributed actors currently have some issues on windows, isRemote always returns false. rdar://82593574
// UNSUPPORTED: windows

import Distributed
import FakeDistributedActorSystems

typealias DefaultDistributedActorSystem = FakeRoundtripActorSystem

distributed actor Greeter: CustomStringConvertible {
  distributed func echo(name: String) -> String {
    return "Echo: \(name) (impl on: \(self.id))"
  }

  distributed func error() throws -> String {
    throw SomeError()
  }

  nonisolated var description: String {
    "\(Self.self)(\(id))"
  }
}

struct SomeError: Error {}

// ==== Test -------------------------------------------------------------------

func test() async throws {
  let system = DefaultDistributedActorSystem()

  let local = Greeter(system: system)
  let ref = try Greeter.resolve(id: local.id, using: system)

  let reply = try await ref.echo(name: "Caplin")
  // CHECK: > encode argument name:name, value: Caplin
  // CHECK-NOT: > encode error type
  // CHECK: > encode return type: Swift.String
  // CHECK: > done recording
  // CHECK: >> remoteCall
  // CHECK: > decode return type: Swift.String
  // CHECK: > decode argument: Caplin
  // CHECK: << onReturn: Echo: Caplin (impl on: ActorAddress(address: "<unique-id>"))

  print("got: \(reply)")
  // CHECK: got: Echo: Caplin (impl on: ActorAddress(address: "<unique-id>"))
}

@main struct Main {
  static func main() async {
    try! await test()
  }
}
