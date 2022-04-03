//
//  EditDetail.swift
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

/// RandomAccess support
struct EditDetailR<Element, Detail>: View
where Element: Identifiable,
      Detail: View
{
    typealias BoundValue = Binding<Element>
    typealias DetailContent = (DetailerContext<Element>, BoundValue) -> Detail
    
    let config: DetailerConfig<Element>
    @State var element: Element
    let originalID: Element.ID?
    let detailContent: DetailContent
    
    var body: some View {
        EditDetailBase(config: config,
                       element: element,
                       originalID: originalID) { context in
            detailContent(context, $element)
        }
    }
}




