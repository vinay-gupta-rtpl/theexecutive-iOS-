//
//  Alert.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 06/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//
import Foundation

struct AlertTitle {
    static let success = "Success"
    static let error = "Error"
    static let alert = "Alert"
    static let none = ""
}

struct AlertButton {
    static let okay = "OK"
    static let cancel = "Cancel"
    static let exit = "Exit"
}

// MARK: - Validation Alert Message
struct AlertValidation {
    static let somethingWentWrong = "Something went wrong. Please try again."
    
    struct Empty {
        static let email = "Email Address is required."
        static let password = "Password is required."
        static let firstName = "First Name is required."
        static let lastName = "Last Name is required."
        static let mobileNumber = "Mobile Number is required."
        static let address = "Street Address Line 1 is required."
        static let country = "Country is required."
        static let state = "State is required."
        static let city = "City is required."
        static let noCityForState = "No cities available."
        static let currentPassword = "Current Password is required."
        static let newPassword = "New Password is required."
        static let confirmNewPassword = "Confirm New Password is required."
        static let postcode = "Zip/ Postal Code is required."
        static let birthDate = "Birth Date is required."
        static let confirmPassword = "Confirm Password is required."
        static let searchEmpty = "Oops.. we couldn't find what you need."
        
        static let orderNumber = "Order number is required."
        static let bankNumber = "Bank number is required."
        static let holderAccountNumber = "Holder account number is required."
        static let transferAmount = "Transfer amount is required."
        static let bankRecipient =  "Bank recipient is required."
        static let transferMethod = "Transfer method is required."
        static let transferDate = "Transfer date is required."
        static let attachmentImage = "Attachment File is required."
    }
    
    struct Invalid {
        static let firstName = "Maximum 50 characters allowed in first name."
        static let lastName = "Maximum 50 characters allowed in last name."
        static let email = "Email address is required in valid format."
        //        static let password = "Password must contain 8 or more characters, special character and number."
        static let password = "Password must contain 8 or more characters, at least 1 alphabet and 1 number."
        static let mobileNumber = "Length should be between 8 to 16."
        static let passwordAndConfirmPasswordDiffer = "The password does not match, kindly enter the same password as above."
        static let loginCredential = "The email address or password do not match with our system, Kindly enter the valid credentials."
        static let loginToWishlist = "Oops.. we couldn't connect to your wishlist, Kindly login/Register to the app."
        static let tapOnWishlist = "Please login before adding items to your wishlist."
        static let tapOnCheckout = "Please login before checkout."
        static let emptyNotificationList = "Notification listing is empty."
        static let postcode = "5 characters are allowed in Zip/ Postal Code."
        static let noUserExist = "No user exists with this email id."
    }
    
    struct NoDataAvailable {
        static let country = "No country available right now."
        static let catalog = "Oops.. we couldn't find what you need."
        static let search = "No results found for the search"
        static let reason = "No Reason selected"
        static let item = "No Item selected"
        static let wishlist = "Your wishlist is empty"
        static let cart = "Your Cart is empty!"
    }
    
    struct Length {
        static let phoneNumberMinimum = 8
        static let phoneNumberMaximum = 16
    }
}

// MARK: - Success Alert Message
struct AlertSuccessMessage {
    static let login = "Welcome aboard, you are now a member of The Executive. Kindly verify your email."
     static let socialLogin = "Welcome aboard, you are now a member of The Executive."
    static let mailSent = "We have sent you an email, please follow the instruction to reset password."
    
    struct Product {
        static let addedToBag = "Product added to bag."
        static let addedToWishlist = "added to wishlist." 
    }
}

// MARK: - Failure Alert Message
struct AlertFailureMessage {
    static let mailNotSent = "Sorry, some error occured. Please try again."
    static let orderInfo = "There was some error while getting order's detail."
    static let userAlreadyExist = "It seems like you are already registered with us, Kindly login."
}

// MARK: - Alert Message
struct AlertMessage {
    static let noInternet = "No Internet Connection"
    static let logoutConfirm = "Are you sure you want to logout from application?"
    static let returnConfirm = "Return request succesfully submitted."
    static let addressChanged = "your address has been changed successfully."
    static let defaultAddressDelete = "You can not delete default address. For deleting this make another address default."
    static let passwordChange = "Your password successfully changed."
    
    static let wishlistRemove = "Are you sure you want to remove item from your wishlist?"    
    static let shoppingBagItemRemove = "Are you sure you want to remove item from your shopping bag?"
    
    static let addressUpdatedSuccessfully = "Your information has been updated successfully."
    static let addressAddedSuccessfully = "Address has been added successfully."
    static let confirmCancelOrder = "Do you want to cancel your order?"
    static let sureToDeleteShippingAddress = "Are you sure you want to remove this address?"
    
    static let UploadAttachmentPhotoMessage: String = "Upload Recipient Photo"
    static let MovedFromCartToWishlist = "moved to wishlist successfully."
    static let outOfStockHandling = "Please change the product qty or move it to your wishlist."
    static let quantityUnavailable = "No more quantity available for this product."
    
    static let paymentMethodNotSelected = "Please select a payment method for your order."
    static let selectOneOption = "Please select at least one option."
    static let enterCorrectAmount = "Enter correct amount"
    static let noProductAvailable = "No more product available"
    static let selectSize = "Select Size"
}
