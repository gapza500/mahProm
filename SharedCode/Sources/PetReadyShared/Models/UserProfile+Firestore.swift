#if canImport(FirebaseFirestore)
import FirebaseFirestore

public extension UserProfile {
    init?(document: DocumentSnapshot) {
        guard var data = document.data() else { return nil }
        let displayName = data["displayName"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let phone = data["phone"] as? String
        let roleString = data["role"] as? String ?? ""
        let statusString = data["status"] as? String ?? UserApprovalStatus.pending.rawValue

        guard let role = UserType(rawValue: roleString),
              let status = UserApprovalStatus(rawValue: statusString) else {
            return nil
        }

        let createdAt: Date?
        if let timestamp = data["createdAt"] as? Timestamp {
            createdAt = timestamp.dateValue()
        } else {
            createdAt = nil
        }

        self.init(
            id: document.documentID,
            displayName: displayName,
            email: email,
            phone: phone,
            role: role,
            status: status,
            createdAt: createdAt
        )
    }

    func toFirestoreData() -> [String: Any] {
        var payload: [String: Any] = [
            "displayName": displayName,
            "email": email.lowercased(),
            "role": role.rawValue,
            "status": status.rawValue
        ]
        if let phone {
            payload["phone"] = phone
        }
        return payload
    }
}
#endif
