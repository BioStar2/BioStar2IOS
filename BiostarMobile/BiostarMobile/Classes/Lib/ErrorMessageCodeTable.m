/*
 * Copyright 2015 Suprema(biostar2@suprema.co.kr)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ErrorMessageCodeTable.h"


@implementation ErrorMessageCodeTable

+ (NSString*)getMessage:(NSInteger)code
{
    switch (code) {
        case ACCESSGROUPLEVEL_DUPLICATED_NAME            : return @"Name Already Exists";
        case ACCESSGROUP_NOT_FOUND                       : return @"Access Group Not Found";
        case ACCESSLEVEL_NOT_FOUND                       : return @"Access Level Not Found";
        case ADMIN_COULD_NOT_BE_DELETED                  : return @"Administrator cannot be deleted.";
        case ADMIN_COULD_NOT_HAVE_OTHER_PERMISSION       : return @"Admin is not allowed to have other permissions.";
        case ALREADY_LOGGED_IN                           : return @"Already Logged In";
        case BIOSTAR_UPDATE_NOT_EXIST                    : return @"Update for BioStar does not exist.";
        case BIOSTAR_UPDATE_SERVER_BUSY                  : return @"BioStar server is busy.  Please try again later.";
        case CARD_ID_IS_REQUIRED                         : return @"Card Id is required.";
        case CARD_NOT_FOUND                              : return @"Card Not Found";
        case COULD_HAVE_FULL_ACCESS_DEVICES              : return @"Device with full access enabled cannot be assigned to Access Group";
        case COULD_NOT_UPDATE_OR_DELETE_PREDEFINED_ITEMS : return @"Predefined items cannot be updated.";
            //		 case DB_CONFIGURATION_FAILED                     : return "Invalid Database Configuration";
            //		 case DB_CONNECTION_FAILED                        : return "Connection to database failed.";
            //		 case DB_INTERNAL_ERROR                           : return "Database Internal Error";
            //		 case DB_INVALID_VALUE_ERROR                      : return "Invalid Value";
        case DEVICE_COULD_NOT_ENABLE_FULL_ACCESS         : return @"Unable to enable full access for Device included in Access Group";
        case DEVICE_GROUP_NOT_FOUND                      : return @"Device Group Not Found";
        case DEVICE_HAS_INVALID_CONFIG                   : return @"Device has configuration which server can not be parsed. Factory reset is recommended.";
        case DEVICE_IS_BUSY                              : return @"Device is now busy. Please try again later.";
        case DEVICE_IS_NOT_CONNECTED                     : return @"Device Not Connected";
        case DEVICE_IS_NOT_READY                         : return @"Device Not Ready";
        case DEVICE_NOT_FOUND                            : return @"Device Not Found";
        case DEVICE_NOT_SUPPORTED                        : return @"Request Not Supported By Device";
        case DEVICE_REQUEST_TIMEOUT                      : return @"Device Timed Out";
        case DEVICE_USERS_FULL                           : return @"Users cannot be added anymore.";
        case DOOR_GROUP_NOT_FOUND                        : return @"Door Group Not Found";
        case DOOR_NOT_FOUND                              : return @"Door Not Found";
        case DUPLICATED_CARD                             : return @"Duplicate Card";
        case DUPLICATED_DEVICE                           : return @"Duplicate Device";
        case DUPLICATED_DEVICE_GROUP                     : return @"Duplicate Device Group";
        case DUPLICATED_FINGERPRINT                      : return @"Duplicate Fingerprint";
        case DUPLICATED_LOGIN_ID                         : return @"Duplicate Login ID";
        case DUPLICATED_USER                             : return @"Duplicate User";
        case DUPLICATED_USERGROUP                        : return @"Duplicate User Group";
        case DUPLICATE_USER_GROUP                        : return @"Duplicate User Group";
        case ERR_NUM_CARD_ID_ALREADY_EXISTS              : return @"Card ID already exists.";
        case ERR_NUM_DEVICE_ALREADY_USED                 : return @"Device already being used.";
        case ERR_NUM_DEVICE_NOT_IN_SAME_RS485            : return @"Device does not exist within same RS485 network.";
        case ERR_NUM_DOOR_GROUP_NAME_ALREADY_EXISTS      : return @"Door group name already exists.";
        case ERR_NUM_DOOR_GROUP_NOT_FOUND                : return @"Door Group Not Found";
        case ERR_NUM_DOOR_NAME_ALREADY_EXISTS            : return @"Door name already exists.";
        case ERR_NUM_RELAY_ALREADY_USED                  : return @"Relay already being used.";
        case EXCEED_DESCRIPTION_MAX_LENGTH               : return @"Maximum length of Description exceeded.";
        case EXCEED_NAME_MAX_LENGTH                      : return @"Maximum length of Name exceeded.";
        case EXPIRY_DATE_IS_LT_START                     : return @"Expiration Date is less than Start Date.";
        case FAILED_TO_ADD_DEVICE                        : return @"Failed to add device.";
        case FAILED_TO_ENROLL_USER                       : return @"Enroll user failed.";
        case FAILED_TO_EXECUTE_DB_QUERY                  : return @"One or more values are invalid. Check the values and try again.";
        case FAILED_TO_PARSE_JSON                        : return @"Failed to parse JSON.";
        case FAILED_TO_PARSE_JSON_INTERNAL               : return @"Failed to parse JSON.";
        case FAILED_TO_SCAN_FINGERPRINT                  : return @"Failed to scan fingerprint.";
        case FAILED_TO_UPGRADE_FIRMWARE                  : return @"Failed to upgrade firmware.";
        case FAILED_TO_VERIFY_FINGERPRINT                : return @"Failed to verify fingerprint.";
        case FINGERPRINT_QUALITY_TOO_LOW                 : return @"Fingerprint quality is too low.";
        case HOLIDAYGROUP_NOT_FOUND                      : return @"Holiday Group Not Found";
        case ID_COULD_NOT_BE_CHANGED                     : return @"ID cannot be modified.";
        case INVALID_COUNT_OF_FACETEMPLATE               : return @"Too Many Face Templates";
        case INVALID_COUNT_OF_FINGERPRINT                : return @"Too Many Fingerprints";
        case INVALID_DEVICE_STATUS                       : return @"Invalid Device Status";
        case INVALID_DOOR                                : return @"Invalid Door";
        case INVALID_EMAIL                               : return @"Invalid Email";
        case INVALID_EXPIRY_DATE                         : return @"Invalid Expiration Date";
        case INVALID_JSON_FORMAT                         : return @"Invalid JSON";
        case INVALID_LENGTH_OF_EMAIL                     : return @"Invalid Length of Email";
        case INVALID_LENGTH_OF_LOGINID                   : return @"Invalid Length of Login Id";
        case INVALID_LENGTH_OF_MESSAGE                   : return @"Invalid Length of Message";
        case INVALID_LENGTH_OF_PASSWORD                  : return @"Invalid Length of Password";
        case INVALID_LENGTH_OF_PHONE_NUM                 : return @"Invalid Length of Telephone";
        case INVALID_LENGTH_OF_PIN                       : return @"Invalid Length of PIN";
        case INVALID_LENGTH_OF_TITLE                     : return @"Invalid Length of Title";
        case INVALID_LENGTH_OF_USERID                    : return @"Invalid Length of ID";
        case INVALID_LOGINID                             : return @"Invalid Login ID";
        case INVALID_PARAMETERS                          : return @"Invalid Parameters";
        case INVALID_PHONE                               : return @"Invalid Telephone";
        case INVALID_PIN                                 : return @"Invalid PIN";
        case INVALID_QUERY_PARAMETER                     : return @"Invalid Query";
        case INVALID_SECURITY_LEVEL                      : return @"Invalid Security Level";
        case INVALID_USERID                              : return @"Invalid User ID";
        case INVALID_USER_NAME                           : return @"Invalid User Name";
        case LAUNCHER_REQUEST_TIMEOUT                    : return @"Launcher failed to respond.";
        case LOGIN_FAILED                                : return @"ID or password is incorrect.\nMake sure you're using ID or password for BioStar 2.";
        case LOGIN_REQUIRED                              : return @"Login Required";
        case METHOD_NOT_ALLOWED                          : return @"Request Method Not Allowed";
        case NET_CONNECTION_FAILED                       : return @"Connection to device failed";
        case NET_INVALID_ADDRESS                         : return @"Invalid Network Address";
        case NET_MALFORMED_HEADER                        : return @"Invalid Header";
        case NET_MALFORMED_PAYLOAD                       : return @"Invalid Payload";
        case NET_WRONG_CHECKSUM                          : return @"Invalid Checksum";
        case NOT_DEFINED                                 : return @"Not Defined";
        case NOT_SUPPORTED_REQUEST                       : return @"Request Not Supported";
        case NO_ACCESSGROUP_NAME_EXISTS                  : return @"There is no Access Group with specified name.";
        case OVER_MAX_ACCESS_GROUPS                      : return @"Too Many Access Groups";
        case PARENT_DOOR_GROUP_IS_REQUIRED               : return @"Parent door group is required.";
        case PARENT_USER_GROUP_NOT_FOUND                 : return @"Parent User Group Not Found";
        case PARENT_USER_GROUP_NOT_SET                   : return @"Parent User Group Not Set";
        case PARTIAL_SUCCESS                             : return @"Processed with some errors";
        case PERMISSION_DENIED                           : return @"Permission Denied";
        case PERMISSION_NOT_FOUND                        : return @"Permission Not Found";
        case PREFERENCE_NOT_FOUND                        : return @"Preference Not Found";
        case SCHEDULE_NOT_FOUND                          : return @"Schedule Not Found";
        case SERVER_ERROR                                : return @"Server Error";
            //		 case SERVER_ERROR_DETAIL_MESSAGE                 : return "An unknown error occurred. Please check the log file for detail information.";
        case SESSION_TIMEOUT                             : return @"Session Invalid";
        case SUCCESS                                     : return @"Successful";
        case TOO_MANY_ACCESSGROUP                        : return @"There are too many access groups.";
        case TOO_MANY_ACCESS_GROUP_ASSIGNED              : return @"Too many access groups are assigned for given user.";
        case TOO_MANY_DEVICE_OPERATOR                    : return @"Maximum of 10 Device operators are allowed";
        case USER_GROUP_NOT_FOUND                        : return @"User Group Not Found";
        case USER_NOT_EXIST                              : return @"User does not exist.";
        case USER_NOT_FOUND                              : return @"User Not Found";
        case WEB_REQUEST_TIMEOUT                         : return @"Request Timed Out";
        case WEB_SOCKET_INVALID_SESSION                  : return @"Invalid session in web socket.";
        case WEB_SOCKET_NOT_FOUND                        : return @"Web socket not found.";
    }
    return nil;
}


@end



