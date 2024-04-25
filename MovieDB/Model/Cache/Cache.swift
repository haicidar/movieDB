//
//  Cache.swift
//  MovieDB
//
//  Created by Muhammad Haidar Rais on 25/04/24.
//

import Foundation
import UIKit

private class ObjectWrapper {
  let value: Any

  init(_ value: Any) {
    self.value = value
  }
}

private class KeyWrapper<KeyType: Hashable>: NSObject {
  let key: KeyType
  init(_ key: KeyType) {
    self.key = key
  }

  override var hash: Int {
    return key.hashValue
  }

  override func isEqual(_ object: Any?) -> Bool {
    guard let other = object as? KeyWrapper<KeyType> else {
      return false
    }
    return key == other.key
  }
}

public class Cache<KeyType: Hashable, ObjectType> {

  private let cache: NSCache<KeyWrapper<KeyType>, ObjectWrapper> = NSCache()

  public init(withName: String, lowMemoryAware: Bool = true) {
    self.name = withName
    guard lowMemoryAware else { return }

    NotificationCenter.default.addObserver( self, selector: #selector(onLowMemory), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  @objc private func onLowMemory() {
    removeAllObjects()
  }

  public var name: String {
    get { return cache.name }
    set { cache.name = newValue }
  }

  public func object(forKey key: KeyType) -> ObjectType? {
    return cache.object(forKey: KeyWrapper(key))?.value as? ObjectType
  }

  public func setObject(_ obj: ObjectType, forKey key: KeyType) { // 0 cost
    return cache.setObject(ObjectWrapper(obj), forKey: KeyWrapper(key))
  }

  public func removeObject(forKey key: KeyType) {
    return cache.removeObject(forKey: KeyWrapper(key))
  }

  public func removeAllObjects() {
    return cache.removeAllObjects()
  }

}
