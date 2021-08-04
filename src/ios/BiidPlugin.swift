import biidCoreSDK
import biidSecProvSDK
import CoreLocation

enum ErrorMessage: String {
    case NoConnection = "Connection error"
    case InvalidToken = "Invalid token"
    case InvalidCedentials = "Invalid credentials"
    case UserLocked = "User locked"
    case ClientError = "Client error"
    case InvalidUserState = "Invalid user state"
    case ValidationError = "Validation Error"
    case TransactionNotPending = "Transaction not pending"
    case BiometricsError = "Biometrics Error"
    case UserCancelled = "User Cancelled"
    case PhoneNumberVerificationLimit = "Phone Number Verification Limit"
    case VerificationCodeBlocked = "Verification Code Blocked"
    case VerificationCodeExpired = "Verification Code Expired"
}

@objc(BiidPlugin) class BiidPlugin : CDVPlugin{
    // MARK: Properties
    var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)

     func message(msg: String) -> String {
        return "[Biid] " + msg
    }
    
    func SP_message(msg: String) -> String {
       return "[Biid SecProv] " + msg
   }
    
    // MARK: Initialization
    
    /// Initializes the biid client. Does nothing if the client is already initialised.
    @objc(initialize:) func initialize(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)

        do {
            try SDK.getClient.initialize()
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
        catch (let exception) {
            // Handle exception
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: message(msg: exception.localizedDescription))
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }

        

    }

    // MARK: Authentication

    /// Authenticates a user
    @objc(authenticate:) func authenticate(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let param1 = (command.arguments[0] as? NSObject)?.value(forKey: "username") as? String
        let param2 = (command.arguments[0] as? NSObject)?.value(forKey: "token") as? String
        let param3 = (command.arguments[0] as? NSObject)?.value(forKey: "userID") as? String
        
        if let username = param1, let token = param2, let userID = param3 {
            let entity = Entity(withID: userID)
            SDK.getClient.authenticate(
                withUsername: username,
                accessToken: token,
                entity: entity,
                onSuccess: {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }, onNoConnection: {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }, onInvalidToken: { (error) in
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }, onClientError:  { (error) in
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                })
        } else {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: message(msg: "calling authenticate() function needs username and device token"))
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
        
        
        
    }
    
    /// Returns the device's installationID
    @objc(getInstallationID:) func getInstallationID(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)

        do {
            let installationID = try SDK.getClient.getInstallationID()
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: installationID)
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
        catch (let exception) {
            // Handle exception
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: message(msg: exception.localizedDescription))
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }

        

    }

    // MARK: User
    
    /// Request the details of the current user
    ///
    /// NOTE: This call always returns the status of the user even if the user is in a locked state.
    /// If the User is locked, a basic user object will be returned (without any registration fields).
    /// In a very rare case, where the server is not synced with the local certificate state on the device, and
    /// an additional request is sent, a user locked error may be returned.
    /// In these circumstances, UserLockedErrors should be caught and handled in the normal way.
    @objc(requestUser:) func requestUser(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        SDK.getClient.requestUser(
            onSuccess: { (user) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: String(describing: user))
                if user.status == User.Status.unregistered {
                    // Unregistered
                }
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onNoConnection: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidToken: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onUserLockedError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.UserLocked.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onClientError:  { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })
        
        
        
    }
    
    /// Register the user for the selected entity
    @objc(registerUser:) func registerUser(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        SDK.getClient.requestUser(
            onSuccess: { (user) in
                SDK.getClient.registerUser(
                    withUser: user,
                    onSuccess: { (user) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: String(describing: user))
                        if user.status == User.Status.unregistered {
                            // Unregistered
                        }
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onNoConnection: {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onInvalidUserStateError: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidUserState.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onInvalidToken: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onValidationError: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ValidationError.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onUserLockedError: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.UserLocked.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onClientError:  { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    })
            }, onNoConnection: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidToken: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onUserLockedError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.UserLocked.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onClientError:  { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })
        
        
        
        
        
    }
    
    

        /// Return Transactions for current user
    @objc(requestUserTransactions:) func requestUserTransactions(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let max = (command.arguments[0] as? NSObject)?.value(forKey: "max") as? Int ?? 100
        
        let offset = (command.arguments[0] as? NSObject)?.value(forKey: "offset") as? Int
        
        let statusRaw = (command.arguments[0] as? NSObject)?.value(forKey: "status") as? NSArray
        var status: [Transaction.Status]? = []
        if statusRaw != nil{
            for elem in statusRaw! {
                if let transactionStatus = Transaction.Status.init(rawValue: elem as! String) {
                    status?.append(transactionStatus)
                }
            }
        }
        
        let typeRaw = (command.arguments[0] as? NSObject)?.value(forKey: "type") as? String
        var type: Transaction.TransactionType?
        if(typeRaw != nil){
            type = Transaction.TransactionType.init(rawValue: typeRaw!)
        }
        
        let docTypeRaw = (command.arguments[0] as? NSObject)?.value(forKey: "documentType") as? String
        var docType: Document.DocumentType?
        if(docTypeRaw != nil){
            docType = Document.DocumentType.init(rawValue: docTypeRaw!)
        }
        
        
        SDK.getClient.requestUserTransactions(
            max: max,
            offset: offset,
            status: status,
            type: type,
            documentType: docType,
            onSuccess: { transactions in
                let transactionDetails = transactions.map { (transaction) -> String in
                    
                    let typeString = transaction.type?.rawValue ?? ""
                    
                    return "\(typeString) : \(transaction.id!) \(transaction.status!)"
                }.joined(separator: "\n\n")
                
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: transactionDetails)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onNoConnection: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidUserStateError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidUserState.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidToken: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onUserLockedError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.UserLocked.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onClientError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })
        
        
        
    }
    
    // MARK: Certification
    
    /// Certifies the user at accreditation Level 1
    @objc(certifyUserAtLevel1:) func certifyUserAtLevel1(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        SDK.getClient.certifyUserAtLevel1(
            onSuccess: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onNoConnection: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidUserStateError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidUserState.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidToken: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onUserLockedError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.UserLocked.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onClientError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })
        
        
        
        
    }
    
    /// Certifies the user at accreditation Level 2 or Level 3
    @objc(certifyUser:) func certifyUser(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let diacRaw = command.arguments[0] as? String
        
        if let code = diacRaw {
            
            SDK.getClient.certifyUser(
                withDIAC: code,
                onSuccess: {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }, onNoConnection: {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }, onInvalidUserStateError: { (error) in
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidUserState.rawValue))
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }, onInvalidToken: { (error) in
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }, onValidationError: { (error) in
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ValidationError.rawValue))
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }, onUserLockedError: { (error) in
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.UserLocked.rawValue))
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }, onClientError: { (error) in
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                })
            
        } else {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: "calling certifyUser() function needs a valid Digital Identity Access Code that the user received by a different channel"))
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
        
        
        
        
    }
    
    
    // MARK: Authentication Transactions
    
    /// Creates an authentication transaction for the currently selected entity
    @objc(createAuthenticationTransaction:) func createAuthenticationTransaction(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let transactionInfoRaw = (command.arguments[0] as? NSObject)?.value(forKey: "transactionInfo") as? NSObject
        let transactionInfo = TransactionInfo()
        if transactionInfoRaw != nil{
            transactionInfo[TransactionInfo.title] = transactionInfoRaw?.value(forKey: "title") as? String ?? ""
            transactionInfo[TransactionInfo.description] = transactionInfoRaw?.value(forKey: "description") as? String ?? ""
            let locationRaw = transactionInfoRaw?.value(forKey: "location") as? NSArray
            if locationRaw != nil {
                transactionInfo[TransactionInfo.location] = Location(latitude: Double(locationRaw![0] as? String ?? "0.0") ?? 0.0, longitude: Double(locationRaw![1] as? String ?? "0.0") ?? 0.0)
            } else {
            transactionInfo[TransactionInfo.location] =  Location(latitude: CLLocationDegrees(arc4random_uniform(90)), longitude: -CLLocationDegrees(arc4random_uniform(180)))
            }
            
            if let additional = transactionInfoRaw?.value(forKey: "additionalProperties") as? NSDictionary {
                for property in additional {
                    transactionInfo["\(property.key)"] = "\(property.value)"
                }
            }
        }
        
        let disableNotifications = (command.arguments[0] as? NSObject)?.value(forKey: "disableNotifications") as? Bool ?? true
        
        
        SDK.getClient.createAuthenticationTransaction(
            withTransactionInfo: transactionInfo,
            disableNotification: disableNotifications,
            onSuccess: { (transaction) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: String(describing: transaction))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onNoConnection: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidUserStateError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidUserState.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidToken: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onValidationError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ValidationError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onUserLockedError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.UserLocked.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onClientError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }
        )
        
        
        
    }
    
    /// Requests an authentication transaction for the selected entity
    @objc(requestAuthenticationTransaction:) func requestAuthenticationTransaction(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let transactionID = command.arguments[0] as? String ?? ""
        
        SDK.getClient.requestAuthenticationTransaction(
            forTransactionID: transactionID,
            onSuccess: { (transaction) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: String(describing: transaction))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onNoConnection: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidUserStateError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidUserState.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidToken: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onUserLockedError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.UserLocked.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onClientError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })
        
        
        
    }
    
    /// Confirms an authentication transaction for the selected entity
    @objc(confirmAuthentication:) func confirmAuthentication(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let transactionID = (command.arguments[0] as? NSObject)?.value(forKey: "transactionID") as? String ?? ""
        let locationRaw = (command.arguments[0] as? NSObject)?.value(forKey: "location") as? NSArray
        var location: CLLocation
        if(locationRaw != nil) {
            location = CLLocation(latitude: Double(locationRaw![0] as? String ?? "0.0") ?? 0.0, longitude: Double(locationRaw![1] as? String ?? "0.0") ?? 0.0)
        } else {
            location = CLLocation(latitude: CLLocationDegrees(arc4random_uniform(90)), longitude: CLLocationDegrees(arc4random_uniform(180)))
        }
        
        SDK.getClient.requestAuthenticationTransaction(
            forTransactionID: transactionID,
            onSuccess: { (transaction) in
                
                SDK.getClient.confirmAuthentication(
                    forTransaction: transaction,
                    withLocation: location,
                    onSuccess: {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onNoConnection: {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onInvalidUserStateError: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidUserState.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onInvalidToken: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onTransactionNotPendingError: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.TransactionNotPending.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onUserLockedError: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.UserLocked.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onClientError: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    })
                
                
            }, onNoConnection: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidUserStateError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidUserState.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidToken: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onUserLockedError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.UserLocked.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onClientError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })
        
        
        
        
        
    }
    
    /// Rejects an authentication transaction for the selected entity
    @objc(rejectAuthentication:) func rejectAuthentication(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let transactionID = (command.arguments[0] as? NSObject)?.value(forKey: "transactionID") as? String ?? ""
        let locationRaw = (command.arguments[0] as? NSObject)?.value(forKey: "location") as? NSArray
        var location: CLLocation
        if(locationRaw != nil) {
            location = CLLocation(latitude: Double(locationRaw![0] as? String ?? "0.0") ?? 0.0, longitude: Double(locationRaw![1] as? String ?? "0.0") ?? 0.0)
        } else {
            location = CLLocation(latitude: CLLocationDegrees(arc4random_uniform(90)), longitude: CLLocationDegrees(arc4random_uniform(180)))
        }
        
        SDK.getClient.rejectAuthentication(
            forTransactionID: transactionID,
            withLocation: location,
                     onSuccess: {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                     }, onNoConnection: {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                     }, onInvalidUserStateError: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidUserState.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                     }, onInvalidToken: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                     }, onTransactionNotPendingError: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.TransactionNotPending.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                     }, onUserLockedError: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.UserLocked.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                     }, onClientError: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                 })
        
        
        
        
        
    }
    
    // MARK: Document Transactions
    
    /// Requests a documents transaction for the selected entity
    @objc(requestDocumentsTransaction:) func requestDocumentsTransaction(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let transactionID = command.arguments[0] as? String ?? ""
        
        SDK.getClient.requestDocumentsTransaction(
            forTransactionID: transactionID,
            onSuccess: { (transaction) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: String(describing: transaction))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onNoConnection: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidUserStateError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidUserState.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidToken: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onUserLockedError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.UserLocked.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onClientError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })
        
        
        
        
    }
    
    /// Signs documents in a transaction
    @objc(signDocuments:) func signDocuments(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let transactionID = (command.arguments[0] as? NSObject)?.value(forKey: "transactionID") as? String ?? ""
        let locationRaw = (command.arguments[0] as? NSObject)?.value(forKey: "location") as? NSArray
        var location: CLLocation
        if(locationRaw != nil) {
            location = CLLocation(latitude: Double(locationRaw![0] as? String ?? "0.0") ?? 0.0, longitude: Double(locationRaw![1] as? String ?? "0.0") ?? 0.0)
        } else {
            location = CLLocation(latitude: CLLocationDegrees(arc4random_uniform(90)), longitude: CLLocationDegrees(arc4random_uniform(180)))
        }
        
        SDK.getClient.requestDocumentsTransaction(
            forTransactionID: transactionID,
            onSuccess: { (transaction) in
                
                SDK.getClient.signDocuments(
                    forTransaction: transaction,
                    withLocation: location,
                    onSuccess: {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onNoConnection: {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onInvalidUserStateError: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidUserState.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onInvalidToken: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onTransactionNotPendingError: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.TransactionNotPending.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onUserLockedError: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.UserLocked.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }, onClientError: { (error) in
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    })
                
            }, onNoConnection: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidUserStateError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidUserState.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidToken: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onUserLockedError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.UserLocked.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onClientError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })
        
        
        
        
        
        
    }
    /// Rejects the documents in a transaction for the selected entity
    @objc(rejectDocuments:) func rejectDocuments(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let transactionID = (command.arguments[0] as? NSObject)?.value(forKey: "transactionID") as? String ?? ""
        let locationRaw = (command.arguments[0] as? NSObject)?.value(forKey: "location") as? NSArray
        var location: CLLocation
        if(locationRaw != nil) {
            location = CLLocation(latitude: Double(locationRaw![0] as? String ?? "0.0") ?? 0.0, longitude: Double(locationRaw![1] as? String ?? "0.0") ?? 0.0)
        } else {
            location = CLLocation(latitude: CLLocationDegrees(arc4random_uniform(90)), longitude: CLLocationDegrees(arc4random_uniform(180)))
        }
        
        
        SDK.getClient.rejectDocuments(
            forTransactionID: transactionID,
            withLocation: location,
            onSuccess: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onNoConnection: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidUserStateError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidUserState.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidToken: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onTransactionNotPendingError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.TransactionNotPending.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onUserLockedError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.UserLocked.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onClientError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })
        
        
        
        
        
        
    }

    // MARK: Push Notifications

    /// Registers a device for Push Notifications NB Requires the user to be authenticated and to have a selected entity
    @objc(registerUserDevice:) func registerUserDevice(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let param1 = command.arguments[0] as? String
        
        if let token = param1 {
            
            SDK.getClient.registerUserDevice(
                withDeviceToken: Data(token.utf8),
                onSuccess: {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }, onNoConnection: {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }, onInvalidToken: { (error) in
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }, onUserLockedError: { (error) in
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.UserLocked.rawValue))
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }, onClientError: { (error) in
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                })
            
        } else {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: message(msg: "calling registerUserDevice() function needs a device token"))
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }

        

    }
    
    /// Unregisters a device for Push Notifications
    @objc(unregisterUserDevice:) func unregisterUserDevice(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        SDK.getClient.unregisterUserDevice(
            onSuccess: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onNoConnection: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.NoConnection.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidToken: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.InvalidToken.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onUserLockedError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.UserLocked.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onClientError: { (error) in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })

    }
    
    // MARK: Security Provider
    
    /// Initializes the biid client. Does nothing if the client is already initialised.
    @objc(SP_initialize:) func SP_initialize(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let idRaw = command.arguments[0] as? String
        
        if let id = idRaw {
            
            do {
                try biidSecProvSDK.SecuritySDK.getClient.initialize(withInstallationID: id)
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            } catch let exception as biidSecProvSDK.ClientException {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: SP_message(msg: exception.localizedDescription))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            } catch let exception as biidCoreSDK.ClientException {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: SP_message(msg: exception.localizedDescription))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            } catch let exception {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: SP_message(msg: exception.localizedDescription))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }
        } else {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: message(msg: "calling SP_initialize() function needs an installation ID"))
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
        
        
        
    }
    
    /// Logs in the specified user
    @objc(SP_login:) func SP_login(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let username = (command.arguments[0] as? NSObject)?.value(forKey: "username") as? String ?? ""
        let passcode = (command.arguments[0] as? NSObject)?.value(forKey: "password") as? String ?? ""
        
        
        biidSecProvSDK.SecuritySDK.getClient.login(
            withUsername: username,
            andPassword: passcode,
            onSuccess: { updatePasscode in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: updatePasscode)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onNoConnection: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.NoConnection.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidCredentials: { error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.InvalidCedentials.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onUserBlocked: { error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.UserLocked.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onClientError: { error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })
    }
    
    /// Returns true if the user password is securely stored in the keychain. False otherwise
    @objc(SP_isBiometricEnabled:) func SP_isBiometricEnabled(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let username = command.arguments[0] as? String ?? ""
        
        let client = biidSecProvSDK.SecuritySDK.getClient

        let enabled = client.isBiometricAuthenticationEnabled(forUsername: username)
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: enabled.description)
        
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        
    }
    
    ///Saves the login username and password to the Keychain. Can only be retrieved with biometric authentication
    ///
    /// Call this method after a successful login if the user has given consent. This method does not validate the password
    @objc(SP_enableBiometrics:) func SP_enableBiometrics(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let username = (command.arguments[0] as? NSObject)?.value(forKey: "username") as? String ?? ""
        let passcode = (command.arguments[0] as? NSObject)?.value(forKey: "password") as? String ?? ""
        
        let client = biidSecProvSDK.SecuritySDK.getClient
        
        client.enableBiometricAuthentication(
            withUsername: username,
            andPassword: passcode,
            onSuccess: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onClientError: { error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })
        
    }
    
    /// Deletes the password from the keychain
    @objc(SP_disableBiometrics:) func SP_disableBiometrics(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let username = command.arguments[0] as? String ?? ""
        
        let client = biidSecProvSDK.SecuritySDK.getClient
        
        client.disableBiometricAuthentication(
            withUsername: username,
            onSuccess: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            },
            onClientError: { error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })
        
    }
    
    /// Returns the current access token
    @objc(SP_getAccessToken:) func SP_getAccessToken(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        
        let client = biidSecProvSDK.SecuritySDK.getClient
        
        guard let accessToken = client.getAccessToken() else {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.ClientError.rawValue))
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: accessToken)
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        
    }
    
    /// Invalidates the current access token
    @objc(SP_logout:) func SP_logout(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        
        let client = biidSecProvSDK.SecuritySDK.getClient
        
        client.logout(
            onSuccess: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onNoConnection: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.NoConnection.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onClientError: { error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })
        
    }
    
    
    /// Retrieves the password of the specified user from the keychain and logs in
    @objc(SP_loginWithBiometrics:) func SP_loginWithBiometrics(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let username = command.arguments[0] as? String ?? ""
       
        
        let client = biidSecProvSDK.SecuritySDK.getClient

        client.setBiometricAuthenticationReason(withReason: "Access \(username)'s saved password")

        client.loginWithBiometrics(
            withUsername: username,
            onSuccess: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            },
            onUserCancelled: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.UserCancelled.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            },
            onNoConnection: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.NoConnection.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            },
            onBiometricsError: {  error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.BiometricsError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            },
            onInvalidCredentials: {  error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.InvalidCedentials.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            },
            onUserBlocked: {  error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.UserLocked.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            },
            onClientError: { error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })
        
        
        
    }
    
    /// Request a verification code that will be sent in an sms to the specified phone number
    @objc(SP_requestPhoneNumberVerification:) func SP_requestPhoneNumberVerification(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let phoneNumber = command.arguments[0] as? String ?? ""
       
        
        let client = biidSecProvSDK.SecuritySDK.getClient
        
        client.requestPhoneNumberVerification(
            forPhoneNumber: phoneNumber,
            onSuccess: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onNoConnection: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.NoConnection.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onValidationError: { error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.ValidationError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onPhoneNumberVerificationLimitError: { error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.PhoneNumberVerificationLimit.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onClientError: {error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })
        
        
        
    }
    
    /// Verify Phone number
    @objc(SP_verifyPhoneNumber:) func SP_verifyPhoneNumber(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let phoneNumber = (command.arguments[0] as? NSObject)?.value(forKey: "phone") as? String ?? ""
        let code = Int((command.arguments[0] as? NSObject)?.value(forKey: "code") as? String ?? "") ?? 0
       
        
        let client = biidSecProvSDK.SecuritySDK.getClient
        
        client.verifyPhoneNumber(
            forPhoneNumber: phoneNumber,
            withVerificationCode: code,
            onSuccess: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onNoConnection: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.NoConnection.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onValidationError: { error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.ValidationError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onVerificationCodeExpired: {error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.VerificationCodeExpired.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onInvalidCredentials: { error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.InvalidCedentials.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onVerificationCodeBlocked: { error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.VerificationCodeBlocked.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onClientError: { error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })
        
        
        
    }
    
    /// Register with Security Provider
    @objc(SP_register:) func SP_register(_ command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        let username = (command.arguments[0] as? NSObject)?.value(forKey: "username") as? String ?? ""
        let password = (command.arguments[0] as? NSObject)?.value(forKey: "password") as? String ?? ""
        let phoneNumber = (command.arguments[0] as? NSObject)?.value(forKey: "phone") as? String ?? ""
       
        
        let client = biidSecProvSDK.SecuritySDK.getClient
        
        client.register(
            withUsername: username,
            andPassword: password,
            andPhoneNumber: phoneNumber,
            onSuccess: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onNoConnection: {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.NoConnection.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onValidationError: { error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.ValidationError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }, onClientError: { error in
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: self.SP_message(msg: ErrorMessage.ClientError.rawValue))
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            })
        
        
        
    }
}
