//
//  ChatRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-30.
//

import Foundation

protocol ChatRepository {
    func fetchMessages(appointmentID: String, completion: @escaping (Result<[Chat], Error>) -> Void)
    func sendMessage(appointmentID: String, content: String, completion: @escaping (Result<Chat, Error>) -> Void)
    func shareLocation(appointmentID: String, coordinate: Coordinate, completion: @escaping (Result<Chat, Error>) -> Void)
    func sharePlace(appointmentID: String, place: Place, completion: @escaping (Result<Chat, Error>) -> Void)
}
