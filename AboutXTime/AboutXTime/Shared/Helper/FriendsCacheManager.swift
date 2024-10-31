//
//  FriendsCacheManager.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/10/4.
//

import Foundation

class FriendsCacheManager {
    static let shared = FriendsCacheManager()
    private let friendsCache = NSCache<NSString, FriendWrapper>()
    private let cacheLock = NSLock()

    private init() {}

    func getFriendFromCache(friendId: String) -> Friend? {
        let friendId = friendId as NSString
        cacheLock.lock()
        defer { cacheLock.unlock() }

        let cachedFriend = friendsCache.object(forKey: friendId)?.friend
        print("Fetching friend from cache: \(friendId). Found: \(cachedFriend != nil)")
        return cachedFriend
    }

    func cacheFriend(_ friend: Friend) {
        let friendId = friend.id as NSString
        let friendWrapper = FriendWrapper(friend: friend)

        cacheLock.lock()
        defer { cacheLock.unlock() }

        friendsCache.setObject(friendWrapper, forKey: friendId)
        print("Caching friend: \(friendId)")
    }
}
