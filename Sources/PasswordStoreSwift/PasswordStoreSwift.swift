import Foundation

public class PasswordStore{
    public static func store(credentials:Credentials,for server:String) throws{
        let query: [String : Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: credentials.username,
            kSecAttrServer as String: server,
            kSecValueData as String: credentials.password.data(using: String.Encoding.utf8)!
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else{
            if status == -25299 {
                throw KeychainError.alreadySaved
            }else{
                throw KeychainError.unhandledError(status: status)
            }
        }
    }
    public static func delete(for server:String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else{
            throw KeychainError.unhandledError(status: status)
        }
    }
    public static func hasLogIn(for server:String) -> Bool{
        do{
            _ = try getItem(for: server)
            return true
        }catch(_){
            return false
        }
    }
    public static func getLogIn(for server:String) throws -> Credentials{
        let item = try getItem(for: server)
        guard let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8),
            let username = existingItem[kSecAttrAccount as String] as? String
        else {
            throw KeychainError.unexpectedPasswordData
        }
        return Credentials(username: username, password: password)
    }
    private static func getItem(for server:String) throws -> CFTypeRef{
        let query:[String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        var items: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &items)
        guard status != errSecItemNotFound else{
            throw KeychainError.noPassword
        }
        guard status == errSecSuccess else{
            throw KeychainError.unhandledError(status: status)
        }
        guard let result = items else{
            throw KeychainError.noPassword
        }
        return result
    }
}
public struct Credentials{
    var username:String
    var password:String
    public init(username:String,password:String){
        self.username = username
        self.password = password
    }
}
public enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
    case alreadySaved
}
