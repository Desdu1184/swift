# This source file is part of the Swift.org open source project
#
# Copyright (c) 2014 - 2021 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See http://swift.org/LICENSE.txt for license information
# See http://swift.org/CONTRIBUTORS.txt for Swift project authors

# NOTE: Subdirectories must be added in dependency order.

add_subdirectory(Basic)
add_subdirectory(AST)
if(SWIFT_ENABLE_EXPERIMENTAL_STRING_PROCESSING)
  add_subdirectory(ExperimentalRegex)
endif()
add_subdirectory(SIL)
add_subdirectory(Optimizer)
