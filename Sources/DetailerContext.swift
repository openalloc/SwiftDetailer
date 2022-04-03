//
//  DetailerContext.swift
//
// Copyright 2022 FlowAllocator LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftUI

public struct DetailerContext<Element>
    where Element: Identifiable
{
    public typealias Config = DetailerConfig<Element>
    public typealias OnValidate = (AnyKeyPath, Bool) -> Void

    // MARK: Parameters

    public let config: Config
    public let onValidate: OnValidate
    public let originalID: Element.ID?

    public init(config: Config,
                onValidate: @escaping OnValidate,
                originalID: Element.ID? = nil)
    {
        self.config = config
        self.onValidate = onValidate
        self.originalID = originalID
    }
}
