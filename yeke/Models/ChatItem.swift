//
//  ChatItem.swift
//  uthere
//
//  Created by Mihri Minaz on 10.11.20.
//

import CoreData
import Combine

extension ChatItem: Comparable {
  
//  static func withID(_ id: Int, context: NSManagedObjectContext) -> ChatItem {
//      // look up icao in Core Data
//      let request = fetchRequest(NSPredicate(format: "id = %@", id))
//      let chatItems = (try? context.fetch(request)) ?? []
//      if let chatItem = chatItems.first {
//          // if found, return it
//          return chatItem
//      } else {
////          // if not, create one and fetch from FlightAware
////          let chatItem = ChatItem(context: context)
////          chatItem.id = id
////          ChatItemRequest.fetch(id) { chatItemInfo in
////              self.update(from: chatItemInfo, context: context)
////          }
////          return chatItem
//      }
//    
//  }
  
  static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<ChatItem> {
      let request = NSFetchRequest<ChatItem>(entityName: "ChatItem")
      request.sortDescriptors = [NSSortDescriptor(key: "createdOn", ascending: true)]
      request.predicate = predicate
      return request
  }
  
  public static func < (lhs: ChatItem, rhs: ChatItem) -> Bool {
      lhs.id < rhs.id
  }
  
//  var id: Int
//  var code: String
//  var createdOn: String
//  var lastMessage: ChatMessage?
//  var receiveVendorId: String?
//  var messageList: [ChatMessage]?
//
  
  func setMessagesToChat(messages: [Message], context: NSManagedObjectContext) {
    self.messageList = NSSet(array: messages)
    self.objectWillChange.send()
    
    self.messageList?.forEach { item in
      if let messageItem = item as? Message {
        messageItem.objectWillChange.send()
      }
     }
    
    try? context.save()
  }
  
  func appendMessagesToChat(message: Message, context: NSManagedObjectContext) {
    if self.messageList == nil { self.messageList = [] }

    let mSet = NSMutableSet(set: self.messageList!)
    mSet.add(message)
    self.messageList = mSet

    
    self.objectWillChange.send()
    self.messageList?.forEach { item in
      if let messageItem = item as? Message {
        messageItem.objectWillChange.send()
      }
     }
    try? context.save()

  }
}
