var exec = require('cordova/exec');

// =================== Biid Core =================== 

/**
 * Initializes the biid client. Does nothing if the client is already initialised.
 * 
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
module.exports.initialize = function (success, error) {
    exec(success, error, 'BiidPlugin', 'initialize', []);
};

/**
 * Authenticates a user
 * 
 * @param {Object} args : Object with the following arguments:
 *      {String} username 
 *      {String} token
 *      {String} userID
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
module.exports.authenticate = function (args, success, error) {
    exec(success, error, 'BiidPlugin', 'authenticate', [args]);
};

/**
 * Returns the device's installationID
 * 
 * @param {*} success : Success callback with data: String
 * @param {*} error : Error callback
 */
module.exports.getInstallationID = function (success, error) {
    exec(success, error, 'BiidPlugin', 'getInstallationID', []);
};

/**
 * Request the details of the current user
 * 
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
module.exports.requestUser = function (success, error) {
    exec(success, error, 'BiidPlugin', 'requestUser', []);
};

/**
 * Register the user for the selected entity
 * 
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.registerUser = function (success, error) {
    exec(success, error, 'BiidPlugin', 'registerUser', []);
};

/**
 * Return Transactions for current user
 * 
 * @param {Object} args : Object with the following arguments:
 *      {Int, optional} max: max number of returned transactions
 *      {Int, optional} offset: results offset
 *      {[String], optional} status: Transaction type. Available values:
 *               "PENDING"
 *               "EXPIRED"
 *               "CANCELLED"
 *               "FAILED"
 *               "REJECTED"
 *               "SUCCESSFUL"
 *      {String, optional} type: Transaction status. Available values:
 *               "AUTH" - Authentication transaction
 *               "DOC"  - Document signing transaction
 *               "MSG"  - Message only transaction
 *      {String, optional} documentType: Only returns transactions with documents of this type. Available values:
 *               "PDF"
 *               "XML"
 *               "MSG"
 *      
 *      Example:
 *          {
 *              "max": 100,
 *              "offset": 10,
 *              "status": ["PENDING", "REJECTED"],
 *              "type": "AUTH",
 *              "documentType": "PDF"
 *          }
 * 
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
module.exports.requestUserTransactions = function (args, success, error) {
    exec(success, error, 'BiidPlugin', 'requestUserTransactions', [args]);
};

/**
 *  Certifies the user at accreditation Level 1
 * 
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
module.exports.certifyUserAtLevel1 = function (success, error) {
    exec(success, error, 'BiidPlugin', 'certifyUserAtLevel1', []);
};

/**
 *  Certifies the user at accreditation Level 2 or Level 3
 * 
 * @param {String} code : Digital Identity Access Code that the user received by a different channel
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.certifyUser = function (code, success, error) {
    exec(success, error, 'BiidPlugin', 'certifyUser', [code]);
};

/**
 * Creates an authentication transaction for the currently selected entity
 * 
 * @param {Object} args : Object with the following arguments:
 *      {Object} transactionInfo: Transaction info with the following key-value pairs:
 *          {String} title
 *          {String} description
 *          {Array} location
 *          {Dictionary} additionalProperties: free [key-value] data
 *      {Bool} disableNotifications: Notification disabled for this transaction
 *      
 *      Example:
 *          {
 *              "transactionInfo": {
 *                  "title": "transaction title",
 *                  "description": "transaction description",
 *                  "location": ["40.41728671596139", "-3.703570504297772"],
 *                  "additionalProperties": {"someString": "this is a tring", "someInt": 30}
 *              },
 *              "disableNotifications": false,
 *          }
 * 
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
module.exports.createAuthenticationTransaction = function (args, success, error) {
    exec(success, error, 'BiidPlugin', 'createAuthenticationTransaction', [args]);
};


/**
 * Requests an authentication transaction for the selected entity
 * 
 * @param {String} id : Transaction ID
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
module.exports.requestAuthenticationTransaction = function (id, success, error) {
    exec(success, error, 'BiidPlugin', 'requestAuthenticationTransaction', [id]);
};

/**
 * Confirms an authentication transaction for the selected entity
 * 
 * @param {Object} args : Object with the following arguments:
 *      {String} transactionID: Transaction ID
 *      {Array} location: array with latitude and longitude in string format,
 * 
 *      Example:
 *          {
 *              "transactionID": "123456",
 *              "location": ["40.41728671596139", "-3.703570504297772"]
 *          }
 * 
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.confirmAuthentication = function (args, success, error) {
    exec(success, error, 'BiidPlugin', 'confirmAuthentication', [args]);
};

/**
 * Rejects an authentication transaction for the selected entity
 * 
 * @param {Object} args : Object with the following arguments:
 *      {String} transactionID: Transaction ID
 *      {Array} location: array with latitude and longitude in string format,
 * 
 *      Example:
 *          {
 *              "transactionID": "123456",
 *              "location": ["40.41728671596139", "-3.703570504297772"]
 *          }
 * 
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.rejectAuthentication = function (args, success, error) {
    exec(success, error, 'BiidPlugin', 'rejectAuthentication', [args]);
};


/**
 * Requests a documents transaction for the selected entity
 * 
 * @param {String} id : Transaction ID
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
module.exports.requestDocumentsTransaction = function (id, success, error) {
    exec(success, error, 'BiidPlugin', 'requestDocumentsTransaction', [id]);
};


/**
 * Signs documents in a transaction. 
 * 
 * @param {Object} args : Object with the following arguments:
 *      {String} transactionID: Transaction ID
 *      {Array} location: array with latitude and longitude in string format,
 * 
 *      Example:
 *          {
 *              "transactionID": "123456",
 *              "location": ["40.41728671596139", "-3.703570504297772"]
 *          }
 * 
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.signDocuments = function (args, success, error) {
    exec(success, error, 'BiidPlugin', 'signDocuments', [args]);
};


/**
 * Rejects the documents in a transaction for the selected entity
 * 
 * @param {Object} args : Object with the following arguments:
 *      {String} transactionID: Transaction ID
 *      {Array} location: array with latitude and longitude in string format,
 * 
 *      Example:
 *          {
 *              "transactionID": "123456",
 *              "location": ["40.41728671596139", "-3.703570504297772"]
 *          }
 * 
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.rejectDocuments = function (args, success, error) {
    exec(success, error, 'BiidPlugin', 'rejectDocuments', [args]);
};

// ---------- Push Notifications ---------- 

/**
 * Registers a device for Push Notifications NB Requires the user 
 * to be authenticated and to have a selected entity
 * 
 * @param {String} token : Device token
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
module.exports.registerUserDevice = function (token, success, error) {
    exec(success, error, 'BiidPlugin', 'registerUserDevice', [token]);
};

/**
 * Unregisters a device for Push Notifications
 * 
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.unregisterUserDevice = function (success, error) {
    exec(success, error, 'BiidPlugin', 'unregisterUserDevice', []);
};


// =================== Biid Security Provider =================== 

/**
 * Initializes the biid client. Does nothing if the client is already initialised.
 * 
 * @param {String} id : Device's installation ID
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.SP_initialize = function (id, success, error) {
    exec(success, error, 'BiidPlugin', 'SP_initialize', [id]);
};

/**
 * Logs in the specified user
 * 
 * @param {Object} args : Object with the following arguments:
 *      {String} username 
 *      {String} password
 * 
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.SP_login = function (args, success, error) {
    exec(success, error, 'BiidPlugin', 'SP_login', [args]);
};

/**
 * Returns true if the user password is securely stored in the keychain. False otherwise
 * 
 * @param {String} username
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.SP_isBiometricEnabled = function (username, success, error) {
    exec(success, error, 'BiidPlugin', 'SP_isBiometricEnabled', [username]);
};

/**
 * Saves the login username and password to the Keychain. Can only be retrieved with 
 * biometric authentication
 * 
 * Call this method after a successful login if the user has given consent. 
 * This method does not validate the password
 * 
 * @param {Object} args : Object with the following arguments:
 *      {String} username 
 *      {String} password
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.SP_enableBiometrics = function (args, success, error) {
    exec(success, error, 'BiidPlugin', 'SP_enableBiometrics', [args]);
};

/**
 * Deletes the password from the keychain
 * 
 * @param {String} username
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.SP_disableBiometrics = function (username, success, error) {
    exec(success, error, 'BiidPlugin', 'SP_disableBiometrics', [username]);
};

/**
 * Returns the current access token
 * 
 * @param {String} username
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.SP_getAccessToken = function (success, error) {
    exec(success, error, 'BiidPlugin', 'SP_getAccessToken', []);
};

/**
 * Invalidates the current access token
 * 
 * @param {String} username
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.SP_logout = function (success, error) {
    exec(success, error, 'BiidPlugin', 'SP_logout', []);
};

/**
 * Retrieves the password of the specified user from the keychain and logs in
 * 
 * @param {String} username
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.SP_loginWithBiometrics = function (username, success, error) {
    exec(success, error, 'BiidPlugin', 'SP_loginWithBiometrics', [username]);
};

/**
 * Request a verification code that will be sent in an sms to the specified phone number
 * 
 * @param {String} phone
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.SP_requestPhoneNumberVerification = function (phone, success, error) {
    exec(success, error, 'BiidPlugin', 'SP_requestPhoneNumberVerification', [phone]);
};

/**
 * Verify Phone number
 * 
 * @param {Object} args : Object with the following arguments:
 *      {String} phone 
 *      {String} code
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.SP_verifyPhoneNumber = function (args, success, error) {
    exec(success, error, 'BiidPlugin', 'SP_verifyPhoneNumber', [args]);
};

/**
 * Register with Security Provider
 * 
 * @param {Object} args : Object with the following arguments:
 *      {String} username 
 *      {String} password
 *      {String} phone
 * @param {*} success : Success callback
 * @param {*} error : Error callback
 */
 module.exports.SP_register = function (args, success, error) {
    exec(success, error, 'BiidPlugin', 'SP_register', [args]);
};