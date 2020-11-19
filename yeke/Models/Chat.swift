//
//  Chat.swift
//  yeke
//
//  Created by Mihri Minaz on 13.11.20.
//

import CoreData
import Combine

extension Chat: Comparable {
//    static func withICAO(_ icao: String, context: NSManagedObjectContext) -> Airport {
//        // look up icao in Core Data
//        let request = fetchRequest(NSPredicate(format: "icao_ = %@", icao))
//        let airports = (try? context.fetch(request)) ?? []
//        if let airport = airports.first {
//            // if found, return it
//            return airport
//        } else {
//            // if not, create one and fetch from FlightAware
//            let airport = Airport(context: context)
//            airport.icao = icao
//            AirportInfoRequest.fetch(icao) { airportInfo in
//                self.update(from: airportInfo, context: context)
//            }
//            return airport
//        }
//    }
//
//    func fetchChats() {
//        Self.chatRequest?.stopFetching()
//        if let context = managedObjectContext {
//            Self.chatRequest = GeneralRequest.create(airport: icao, howMany: 90)
//            Self.chatRequest?.fetch(andRepeatEvery: 60)
//            Self.chatResultsCancellable = Self.chatRequest?.results.sink { results in
//                for faflight in results {
//                    Flight.update(from: faflight, in: context)
//                }
//                do {
//                    try context.save()
//                } catch(let error) {
//                    print("couldn't save flight update to CoreData: \(error.localizedDescription)")
//                }
//            }
//        }
//    }

//    private static var chatRequest: GeneralRequest!
//    private static var chatResultsCancellable: AnyCancellable?

//    static func update(from info: AirportInfo, context: NSManagedObjectContext) {
//        if let icao = info.icao {
//            let airport = self.withICAO(icao, context: context)
//            airport.latitude = info.latitude
//            airport.longitude = info.longitude
//            airport.name = info.name
//            airport.location = info.location
//            airport.timezone = info.timezone
//            airport.objectWillChange.send()
//            airport.flightsTo.forEach { $0.objectWillChange.send() }
//            airport.flightsFrom.forEach { $0.objectWillChange.send() }
//            try? context.save()
//        }
//    }
//
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Chat> {
        let request = NSFetchRequest<Chat>(entityName: "Chat")
        request.sortDescriptors = [NSSortDescriptor(key: "location", ascending: true)]
        request.predicate = predicate
        return request
    }
//
//    var flightsTo: Set<Flight> {
//        get { (flightsTo_ as? Set<Flight>) ?? [] }
//        set { flightsTo_ = newValue as NSSet }
//    }
//    var flightsFrom: Set<Flight> {
//        get { (flightsFrom_ as? Set<Flight>) ?? [] }
//        set { flightsFrom_ = newValue as NSSet }
//    }
//
//    var icao: String {
//        get { icao_! } // TODO: maybe protect against when app ships?
//        set { icao_ = newValue }
//    }
//
//    var friendlyName: String {
//        let friendly = AirportInfo.friendlyName(name: self.name ?? "", location: self.location ?? "")
//        return friendly.isEmpty ? icao : friendly
//    }
//    public var id: String { icao }
//  public var cose: String { icao }
//  public var id: Int { id }
//

    public static func < (lhs: Chat, rhs: Chat) -> Bool {
      if  let lhsCreatedOn = lhs.createdOn, let rhsCreatedOn = rhs.createdOn {
        return lhsCreatedOn < rhsCreatedOn
      }
      return false
      
    }
}
