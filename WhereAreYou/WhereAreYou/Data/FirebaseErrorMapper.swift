//
//  FirebaseErrorMapper.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import FirebaseStorage

/// Firebase NSError → AppError 변환기
enum FirebaseErrorMapper {

    static func map(_ error: Error) -> AppError {
        let nsError = error as NSError

        switch nsError.domain {
        case AuthErrorDomain:
            return mapAuth(nsError)
        case FirestoreErrorDomain:
            return mapFirestore(nsError)
        case "com.firebase.database":
            return mapDatabase(nsError)
        case StorageErrorDomain:
            return mapStorage(nsError)
        default:
            return mapGeneral(nsError)
        }
    }

    private static func mapAuth(_ error: NSError) -> AppError {
        guard let code = AuthErrorCode(rawValue: error.code) else {
            return .unknown(error)
        }
        switch code {
        case .networkError:
            return .network
        case .userNotFound, .userTokenExpired, .invalidUserToken:
            return .notAuthenticated
        case .emailAlreadyInUse:
            return .alreadyExists
        default:
            return .unknown(error)
        }
    }

    private static func mapFirestore(_ error: NSError) -> AppError {
        switch FirestoreErrorCode.Code(rawValue: error.code) {
        case .notFound:
            return .notFound
        case .permissionDenied, .unauthenticated:
            return .permissionDenied
        case .alreadyExists:
            return .alreadyExists
        case .unavailable:
            return .network
        default:
            return .unknown(error)
        }
    }

    private static func mapDatabase(_ error: NSError) -> AppError {
        switch error.code {
        case -4:
            return .network
        case -3:
            return .permissionDenied
        default:
            return .unknown(error)
        }
    }

    private static func mapStorage(_ error: NSError) -> AppError {
        switch StorageErrorCode(rawValue: error.code) {
        case .objectNotFound:
            return .notFound
        case .unauthorized, .unauthenticated:
            return .permissionDenied
        case .quotaExceeded:
            return .unknown(error)
        case .retryLimitExceeded:
            return .network
        default:
            return .unknown(error)
        }
    }

    private static func mapGeneral(_ error: NSError) -> AppError {
        if error.domain == NSURLErrorDomain {
            return .network
        }
        return .unknown(error)
    }

}
