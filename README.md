# SwiftDetailer

A multi-platform SwiftUI component for editing fielded data.

Available as an open source library to be incorporated in SwiftUI apps.

_SwiftDetailer_ is part of the [OpenAlloc](https://github.com/openalloc) family of open source Swift software tools.

macOS | iOS
:---:|:---:
![](https://github.com/openalloc/SwiftDetailer/blob/main/Images/macOSb.png)  |  ![](https://github.com/openalloc/SwiftDetailer/blob/main/Images/iOSc.png)

## Features

* Convenient editing (and viewing) of fielded data in your app
* Presently targeting macOS v11+ and iOS v14+\*\*
* Supporting both value and reference semantics (including Core Data, which uses the latter)
* Can be used with various collection container types, such as `List`, `Table`, `LazyVStack`, etc.\*
* `.editDetailer` View modifier, to support (bound, read/write) view 
* `.viewDetailer` View modifier, to support (unbound, read-only) view
* Option to add new item
* Option to delete item
* Option to validate at field-level, with indicators
* Option to validate at record-level, with alert view
* Optional `DetailerMenu` package available, for convenient invocation
* Minimal use of View type erasure (i.e., use of `AnyView`)
* No external dependencies!

\* And also the companion [Tabler](https://github.com/openalloc/SwiftTabler) component (by the same author)

\*\* Other platforms like macCatalyst, iPad on Mac, watchOS, tvOS, etc. are poorly supported, if at all. Please contribute to improve support!

## Detailer Example

An example, showing the basic use of _Detailer_. As a baseline, start with a display of rows of data in a `List`:

```swift
import SwiftUI

struct Fruit: Identifiable {
    var id: String
    var name: String
    var weight: Double
    var color: Color
}

struct ContentView: View {

    @State private var fruits: [Fruit] = [
        Fruit(id: "🍌", name: "Banana", weight: 118, color: .brown),
        Fruit(id: "🍓", name: "Strawberry", weight: 12, color: .red),
        Fruit(id: "🍊", name: "Orange", weight: 190, color: .orange),
        Fruit(id: "🥝", name: "Kiwi", weight: 75, color: .green),
        Fruit(id: "🍇", name: "Grape", weight: 7, color: .purple),
        Fruit(id: "🫐", name: "Blueberry", weight: 2, color: .blue),
    ]

    var body: some View {
        List(fruits) { fruit in
            HStack {
                Text(fruit.id)
                Text(fruit.name).foregroundColor(fruit.color)
                Spacer()
                Text(String(format: "%.0f g", fruit.weight))
            }
        }
    }
}
```

Then, to add basic support for a detail page, targeting both macOS and iOS, you'll need to:

* A. Import the `SwiftDetailer` and `SwiftDetailerMenu` packages.
* B. Add state property for element to edit, and a typealias for cleaner code.
* C. Give each row a menu (context for macOS; swipe for iOS).
* D. Add a call to `editDetailer`, available as a modifier.
* E. Include a `Form` containing the fields to edit, and ...
* F. Add an action handler to save a modified `Fruit` element.

These are shown (and annotated) in the modified code below:

```swift
import SwiftUI
import Detailer         // A
import DetailerMenu

struct Fruit: Identifiable {
    var id: String
    var name: String
    var weight: Double
    var color: Color
}

struct ContentView: View {

    @State private var fruits: [Fruit] = [
        Fruit(id: "🍌", name: "Banana", weight: 118, color: .brown),
        Fruit(id: "🍓", name: "Strawberry", weight: 12, color: .red),
        Fruit(id: "🍊", name: "Orange", weight: 190, color: .orange),
        Fruit(id: "🥝", name: "Kiwi", weight: 75, color: .green),
        Fruit(id: "🍇", name: "Grape", weight: 7, color: .purple),
        Fruit(id: "🫐", name: "Blueberry", weight: 2, color: .blue),
    ]
    
    @State private var toEdit: Fruit? = nil // B

    typealias Context = DetailerContext<Fruit>

    var body: some View {
        List(fruits) { fruit in
            HStack {
                Text(fruit.id)
                Text(fruit.name).foregroundColor(fruit.color)
                Spacer()
                Text(String(format: "%.0f g", fruit.weight))
            }
            .modifier(menu(fruit)) // C
        }
        .editDetailer(.init(onSave: saveAction),
                      toEdit: $toEdit,
                      originalID: toEdit?.id,
                      detailContent: editDetail) // D
    }
    
    // E
    private func editDetail(ctx: Context, fruit: Binding<Fruit>) -> some View {
        Form {
            TextField("ID", text: fruit.id)
            TextField("Name", text: fruit.name)
            TextField("Weight", value: fruit.weight, formatter: NumberFormatter())
            ColorPicker("Color", selection: fruit.color)
        }
    }
    
    // F
    private func saveAction(ctx: Context, fruit: Fruit) {
        if let n = fruits.firstIndex(where: { $0.id == fruit.id }) {
            fruits[n] = fruit
        }
    }
    
    // C
#if os(macOS)
    private func menu(_ fruit: Fruit) -> EditDetailerContextMenu<Fruit> {
        EditDetailerContextMenu(fruit) { toEdit = $0 }
    }
#elseif os(iOS)
    private func menu(_ fruit: Fruit) -> EditDetailerSwipeMenu<Fruit> {
        EditDetailerSwipeMenu(fruit) { toEdit = $0 }
    }
#endif
}
```

On macOS, ctrl-click (or right-click) on a row to invoke the context menu. On iOS, swipe the row to invoke the menu.

For a full implementation, with ability to add new records, see the _DetailerDemo_ project (link below). It extends the example with operations to add new records, delete records, and validate input. 

It shows _Detailer_ used with `LazyVGrid` and `Table` containers.

## Menuing

You can invoke _Detailer_ by various methods. One way is via context or swipe menus. For _optional_ menu support see [SwiftDetailerMenu](https://github.com/openalloc/SwiftDetailerMenu).

The use of context menus for macOS and iOS:

macOS | iOS
:---:|:---:
![](https://github.com/openalloc/SwiftDetailer/blob/main/Images/macOSa.png)  |  ![](https://github.com/openalloc/SwiftDetailer/blob/main/Images/iOSb.png)

And swipe menu for iOS:

iOS
:---:
![](https://github.com/openalloc/SwiftDetailer/blob/main/Images/iOSa.png)

## Validation

You can _optionally_ validate data using _Detailer_. Two approaches are available: field and record level.

Field and record level validation can be used individually or in concert.

### Field-level validation

This is a *lightweight* form of validation where individual fields get a closure to test their validity. As they are executed with each change, they should NOT run expensive operations, like hitting a remote server.

Field-level validation is implemented as modifiers in the detail form, as in this example of three(3) validators used in the demo app:

```swift
private func editDetail(ctx: DetailerContext<Fruit>, fruit: Binding<Fruit>) -> some View {
    Form {
        TextField("ID", text: fruit.id)
            .validate(ctx, fruit, \.id) { $0.count > 0 }
        TextField("Name", text: fruit.name)
            .validate(ctx, fruit, \.name) { $0.count > 0 }
        TextField("Weight", value: fruit.weight, formatter: NumberFormatter())
            .validate(ctx, fruit, \.weight) { $0 > 0 }
        ColorPicker("Color", selection: fruit.color)
    }
}
```

The first two are testing string length. The third is testing the numerical value.

By default, invalid fields will be suffixed with a warning icon, currently an "exclamationmark.triangle", as displayed in the images above. This image is configurable.

All field-level validations must return `true` for the `Save` button to be enabled.

**TIP**: for consistent margin spacing in layout, you can create a validation that always succeeds: `.validate(...) { _ in true }`.

### Record-level validation

This can be a *heavyweight* form of validation executed when the user presses the `Save` button.

It's a parameter of the `DetailerConfig` initialization, specifically `onValidate: (Context, Element) -> [String]`.

In your action handler, test the record and, if okay, return `[]`, an empty string array. Populate the array with messages if invalid. They will be presented to the user in an alert.

If this validation is used, the user will not be able to save changes until it returns `[]`.


## Configuration

Defaults can vary by platform. See the `DetailerConfigDefaults` code for specifics.

The `can` handlers are typically used to enable or disable controls, such as menu items. They are constrained by the definition of their `on` counterparts.

The `on` handlers, when defined, will enable the associated operation.

- `minWidth: CGFloat` - minimum sheet width; default varies by platform
- `canEdit: (Element) -> Bool` - per-element modification enabling, if `onSave` defined; defaults to `{ _ in true }`
- `canDelete: (Element) -> Bool` - per-element deletion enabling, if `onDelete` defined; defaults to `{ _ in true }`
- `onDelete: ((Element) -> Void)?` - handler for deletion; defaults to `nil`
- `onValidate: (Context, Element) -> [String]` - handler for *heavyweight* validation; defaults to  `{ _, _ in [] }`
- `onSave: ((Context, Element) -> Void)?` - handler for user save; defaults to `nil`
- `onCancel: (Context, Element) -> Void` - handler for user cancel; defaults to `{ _, _ in }`
- `titler: ((Element) -> String)?` - handler for title generation; defaults to `nil`
- `validateIndicator: (Bool) -> AnyView` - defaults to "exclamationmark.triangle" image, with additional attributes

## See Also

This library is a member of the _OpenAlloc Project_.

* [_OpenAlloc_](https://openalloc.github.io) - product website for all the _OpenAlloc_ apps and libraries
* [_OpenAlloc Project_](https://github.com/openalloc) - Github site for the development project, including full source code

## License

Copyright 2021, 2022 OpenAlloc LLC

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Contributing

Contributions are welcome. You are encouraged to submit pull requests to fix bugs, improve documentation, or offer new features. 

The pull request need not be a production-ready feature or fix. It can be a draft of proposed changes, or simply a test to show that expected behavior is buggy. Discussion on the pull request can proceed from there.
