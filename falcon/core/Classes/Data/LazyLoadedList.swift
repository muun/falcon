//
//  LazyLoadedList.swift
//  core.root-all-notifications
//
//  Created by Federico Bond on 08/01/2021.
//

public class LazyLoadedList<Element>: Collection {

    typealias TotalFunction = () -> Int
    typealias LoadMoreFunction = (_ limit: Int, _ offset: Int) -> [Element]

    private var elements: [Element]
    private let totalFactory: TotalFunction
    private let onLoadMore: LoadMoreFunction?

    public lazy var total = totalFactory()

    private let queue = DispatchQueue(label: "LazyLoadedList")

    public init() {
        self.elements = []
        self.totalFactory = { 0 }
        self.onLoadMore = nil
    }

    init(total: @escaping TotalFunction, onLoadMore: @escaping LoadMoreFunction) {
        Logger.log(.info, "memo: new list")
        self.elements = []
        self.totalFactory = total
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
