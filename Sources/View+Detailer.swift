//
//  View+Detailer.swift
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
import CoreData

public extension View {
    typealias ProjectedValue<E> = ObservedObject<E>.Wrapper where E: ObservableObject
    typealias EditContentC<E, D> = (DetailerContext<E>, ProjectedValue<E>) -> D where E: Identifiable & ObservableObject
    typealias EditContentR<E, D> = (DetailerContext<E>, Binding<E>) -> D where E: Identifiable
    typealias ViewContent<E, D> = (E) -> D where E: Identifiable
    
    /// For Random Access Collection source
    func editDetailer<E, D>(_ config: DetailerConfig<E>,
                            toEdit: Binding<E?>,
                            isAdd: Binding<Bool>,
                            @ViewBuilder detailContent: @escaping EditContentR<E, D>) -> some View
    where E: Identifiable,
          D: View
    {
        self.sheet(item: toEdit) { element in
#if os(macOS)
            EditDetailR(config: config,
                        element: element,
                        isAdd: isAdd,
                        detailContent: detailContent)
#elseif os(iOS)
            NavigationView {
                EditDetailR(config: config,
                           element: element,
                           isAdd: isAdd,
                           detailContent: detailContent)
            }
            .navigationViewStyle(StackNavigationViewStyle())
#endif
        }
    }
    
    /// For Core Data source
    func editDetailer<E, D>(_ config: DetailerConfig<E>,
                            toEdit: Binding<E?>,
                            isAdd: Binding<Bool>,
                            @ViewBuilder detailContent: @escaping EditContentC<E, D>) -> some View
    where E: Identifiable & ObservableObject,
          D: View
    {
        self.sheet(item: toEdit) { element in
#if os(macOS)
            EditDetailC(config: config,
                        element: element,
                        isAdd: isAdd,
                        detailContent: detailContent)
#elseif os(iOS)
            NavigationView {
                EditDetailC(config: config,
                            element: element,
                            isAdd: isAdd,
                            detailContent: detailContent)
            }
            .navigationViewStyle(StackNavigationViewStyle())
#endif
        }
    }
    
    func viewDetailer<E, D>(_ config: DetailerConfig<E>,
                            toView: Binding<E?>,
                            @ViewBuilder viewContent: @escaping ViewContent<E, D>) -> some View
    where E: Identifiable,
          D: View
    {
        self.sheet(item: toView) { element in
#if os(macOS)
            ViewDetailR(config: config,
                       element: element,
                       viewContent: viewContent)
#elseif os(iOS)
            NavigationView {
                ViewDetailR(config: config,
                           element: element,
                           viewContent: viewContent)
            }
            .navigationViewStyle(StackNavigationViewStyle())
#endif
        }
    }
}
