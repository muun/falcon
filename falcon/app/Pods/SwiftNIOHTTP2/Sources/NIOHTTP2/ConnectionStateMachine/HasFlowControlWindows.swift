//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2019 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

/// A protocol implemented by HTTP/2 connection state machine states with flow control windows.
protocol HasFlowControlWindows {
    var inboundFlowControlWindow: HTTP2FlowControlWindow { get }

    var outboundFlowControlWindow: HTTP2FlowControlWindow { get }
}
