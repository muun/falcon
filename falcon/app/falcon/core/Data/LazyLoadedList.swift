//
//  LazyLoadedList.swift
//  Created by Federico Bond on 08/01/2021.
//

public class LazyLoadedList<Element>: Collection {

    typealias LoadMoreFunction = (_ limit: Int, _ offset: Int) -> [Element]

    public let total: Int
    private var elements: [Element]
    private let onLoadMore: LoadMoreFunction?

    public init() {
        self.elements = []
        self.total = 0
        self.onLoadMore = nil
    }

    init(total: Int, initialElements: [Element], onLoadMore: @escaping LoadMoreFunction) {
        self.total = total
        self.elements = initialElements
        self.onLoadMore = onLoadMore
    }

    public var startIndex: Int {
        elements.startIndex
    }

    public var endIndex: Int {
        elements.endIndex
    }

    public var count: Int {
        elements.count
    }

    public var isEmpty: Bool {
        elements.isEmpty
    }

    public subscript(index: Int) -> Element {
        return elements[index]
    }

    public func index(after i: Int) -> Int {
        return elements.index(after: i)
    }

    public func loadMore(count: Int) -> Bool {
        let offset = elements.count

        if let nextElements = self.onLoadMore?(count, offset) {
            if nextElements.isEmpty {
                return false
            }
            elements.append(contentsOf: nextElements)
            return true
        }

        return false
    }

}
