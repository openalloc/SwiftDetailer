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

struct EditDetail<Element, Detail>: View
    where Element: Identifiable,
    Detail: View
{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    typealias DetailContent = (DetailerContext<Element>, Binding<Element>) -> Detail
    typealias Validate<T> = (KeyPath<Element, T>) -> Void

    // MARK: Parameters

    // NOTE `element` not a binding, because we don't want to change data live
    // NOTE `isAdd` will be set to `false` on dismissal of sheet

    var config: DetailerConfig<Element>
    @State var element: Element
    @Binding var isAdd: Bool
    var detailContent: DetailContent

    // MARK: Locals

    @State private var invalidFields: Set<AnyKeyPath> = Set()
    @State private var showValidationAlert = false
    @State private var alertMessage: String? = nil

    private var context: DetailerContext<Element> {
        DetailerContext<Element>(config: config,
                                 onValidate: validateAction,
                                 isAdd: isAdd)
    }

    private var isDeleteAvailable: Bool {
        config.onDelete != nil
    }
    
    private var canDelete: Bool {
        isDeleteAvailable && config.canDelete(element)
    }
    
    private var isSaveAvailable: Bool {
        config.onSave != nil
    }

    private var canSave: Bool {
        isSaveAvailable && invalidFields.isEmpty
    }

    // MARK: Views

    var body: some View {
        VStack(alignment: .leading) { // .leading needed to keep title from centering
            #if os(macOS)
            Text(config.titler(element)).font(.largeTitle)
            #endif
            // this is where the user will typically declare a Form or VStack
            detailContent(context, $element)
            // .animation(.default)
        }
        .alert(isPresented: $showValidationAlert) {
            Alert(title: Text("Validation Failure"),
                  message: Text(alertMessage ?? "Requires valid entry before save."))
        }
        #if os(macOS)
        .padding()
        #endif
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: deleteAction) {
                    Text("Delete")
                }
                .keyboardShortcut(.delete)
                .opacity(isDeleteAvailable ? 1 : 0)
                .disabled(!canDelete)
            }

            ToolbarItem(placement: .cancellationAction) {
                Button(action: cancelAction) {
                    Text("Cancel")
                }
                .keyboardShortcut(.cancelAction)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(action: saveAction) {
                    Text("Save")
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!canSave)
            }
        }
        #if os(macOS)
        // NOTE on macOS, this seems to be needed to avoid excessive height
        .frame(minWidth: config.minWidth, maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        #endif

        #if os(iOS) || targetEnvironment(macCatalyst)
        .navigationTitle(config.titler(element))
        #endif
    }

    // MARK: Action Handlers

    // NOTE: should be invoked via async to avoid updating the state during view render
    private func validateAction(_ anyKeyPath: AnyKeyPath, _ result: Bool) {
        if result {
            // SUCCESS
            if invalidFields.contains(anyKeyPath) {
                invalidFields.remove(anyKeyPath)
            }
        } else {
            // FAIL
            if !invalidFields.contains(anyKeyPath) {
                invalidFields.insert(anyKeyPath)
            }
        }
    }

    private func saveAction() {
        guard let _onSave = config.onSave else { return }

        // display any validation changes
        let messages = config.onValidate(context, element)
        if messages.count > 0 {
            alertMessage = config.onValidate(context, element).joined(separator: "\n\n")
            showValidationAlert = true
            return
        }

        let invalidCount = invalidFields.count
        if invalidCount > 0 {
            alertMessage = "\(invalidCount) field(s) require valid values before you can save."
            showValidationAlert = true
            return
        }

        _onSave(context, element)
        dismissAction()
    }

    private func deleteAction() {
        guard let _onDelete = config.onDelete else { return }
        _onDelete(element.id)
        dismissAction()
    }

    private func cancelAction() {
        config.onCancel(context, element)
        dismissAction()
    }

    private func dismissAction() {
        isAdd = false
        presentationMode.wrappedValue.dismiss()
    }
}
