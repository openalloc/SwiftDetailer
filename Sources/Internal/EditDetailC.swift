//
//  EditDetailC.swift
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

/// Core Data support
struct EditDetailC<Element, Detail>: View
where Element: Identifiable & ObservableObject,
      Detail: View
{
    typealias ProjectedValue = ObservedObject<Element>.Wrapper
    typealias DetailContent = (DetailerContext<Element>, ProjectedValue) -> Detail
    
    var config: DetailerConfig<Element>
    @ObservedObject var element: Element
    @Binding var isAdd: Bool
    var detailContent: DetailContent
    
    var body: some View {
        EditDetailBase(config: config,
                       element: element,
                       isAdd: $isAdd) { context in
            detailContent(context, $element)
        }
    }
}
