//
//  iImagePickerController.swift
//  iComponents
//
//  Created by Tak Rahul on 09/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

private let cameraNotAvailable = "Device has no camera."
private var imageSelectionMessage = "Choose Photo"
private let takePhoto = "Take Photo"
private let selectFromGallery = "Select From Gallery"
private let viewPhoto = "View Photo"
private let settings = "Settings"
private let cancel = "Cancel"
private let ok = "OK"
private var cameraPermissionAlertTitle = "\"Your App Would\" Like to Access the Camera"
private var cameraPermissionAlertMessage = "Application will use camera to take photos"
private var photoLibraryPermissionAlertTitle = "\"Your App Would\" Like to Access Your Photos"
private var photoLibraryPermissionAlertMessage =  "Application will use photo library to select photo"

open class ImagePickerController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, KACircleCropViewControllerDelegate {
    
    var imagePickerController: UIImagePickerController?
    
    /// Default appearance of the button
    public var isCameraAccess: Bool = true
    public var isGalleryAccess: Bool = true
    public var isPhotoAvailable: Bool = false
    public var isProfilePic: Bool = false
    public var isOvalCrop: Bool = true
    public var imageCropRect: CGSize = CGSize(width: 1.0, height: 1.0)
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setDataWhenViewDidLoad()
        
    }
    func setDataWhenViewDidLoad() {
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String]
        if !(appName == nil) {
            cameraPermissionAlertTitle = "\"\(appName!) Would\" Like to Access the Camera"
            photoLibraryPermissionAlertTitle = "\"\(appName!) Would\" Like to Access Your Photos"
        }
        let path = Bundle.main.path(forResource: "Info", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!) as? [String: AnyObject]
        let appCameraPermissionAlertMessage = dict?["NSCameraUsageDescription"]
        let appPhotoLibraryPermissionAlertMessage = dict?["NSPhotoLibraryUsageDescription"]
        if !(appCameraPermissionAlertMessage == nil) {
            cameraPermissionAlertMessage = (appCameraPermissionAlertMessage as? String)!
        }
        if !(appPhotoLibraryPermissionAlertMessage == nil) {
            photoLibraryPermissionAlertMessage = (appPhotoLibraryPermissionAlertMessage as? String)!
        }
    }
    
    open func loadImagePicker(cameraAccess: Bool = true, galleryAccess: Bool = true, ovalCrop: Bool = true, cropSize: CGSize = CGSize(width: 1.0, height: 1.0), selectMessage: String, photoAvailable: Bool) {
        isCameraAccess = cameraAccess
        isGalleryAccess = galleryAccess
        imageCropRect = cropSize
        isOvalCrop = ovalCrop
        imageSelectionMessage = selectMessage
        isPhotoAvailable = photoAvailable
        
        guard isCameraAccess == false && isGalleryAccess == false else {
            setupView()
            return
        }
    }
    
    // MARK: View setup
    func setupView() {
        
        // Show picker if both modes selected
        // If either 1 of image picker type is enabled, direct open image picker with type
        if isCameraAccess && isGalleryAccess {
            let imageSelectionAlert = UIAlertController.init(title: imageSelectionMessage, message: nil, preferredStyle: .actionSheet)
            let takePhotoAction = UIAlertAction.init(title: takePhoto, style: .default, handler: { (action: UIAlertAction) in
                self.checkForPermissions(type: .camera)
            })
            
            let selectFromGalleryAction = UIAlertAction.init(title: selectFromGallery, style: .default, handler: { (action: UIAlertAction) in
                self.checkForPermissions(type: .photoLibrary)
            })
            
            let cancelAction = UIAlertAction.init(title: cancel, style: .destructive, handler: nil)
            
            imageSelectionAlert.addAction(takePhotoAction)
            imageSelectionAlert.addAction(selectFromGalleryAction)
            imageSelectionAlert.addAction(cancelAction)
            
            // use popOver
            let popPresenter: UIPopoverPresentationController? = imageSelectionAlert.popoverPresentationController
            popPresenter?.sourceView = self.view
            popPresenter?.sourceRect = CGRect(x: 0, y: MainScreen.height - 170, width: MainScreen.width, height: 100)
            
            self.present(imageSelectionAlert, animated: true, completion: nil)
            
        } else {
            self.checkForPermissions(type: isCameraAccess ? .camera : .photoLibrary)
        }
    }
    
    // *****
    // Kind of method for make another picture as profile picture.
    // Method will be override in child class to get the image and set as profile pic
    // *****

    open func makeProfilePicture() {
        
    }
    
    open func deletePicture() {
        
    }
    
    open func viewPictureAction() {
        
    }
    
    func checkForPermissions(type: UIImagePickerControllerSourceType) {
        if type == .camera {
            checkCameraPermissons()
        } else if type == .photoLibrary {
            callPhotoLibrary()
        }
    }
    
    func openImagePickerWith(type: UIImagePickerControllerSourceType) {
        if imagePickerController == nil {
            imagePickerController = UIImagePickerController()
            imagePickerController?.delegate = self
        }
        imagePickerController?.allowsEditing = false
        imagePickerController?.sourceType = type
        self.present(imagePickerController!, animated: true, completion: nil)
    }
    
    // Image picker delegates
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        let image: UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        
        weak var weakSelf = self
        picker.dismiss(animated: true) {
            let circleCropController = KACircleCropViewController(withImage: image, cropSize: self.imageCropRect)
            
            circleCropController.delegate = weakSelf!
            circleCropController.isOvalCrop = self.isOvalCrop
            weakSelf?.present(circleCropController, animated: true, completion: nil)
        }
    }
    
    public func circleCropDidCancel() {
        //Basic dismiss
        dismiss(animated: false, completion: nil)
    }
    
    public func circleCropDidCropImage(_ image: UIImage) {
        weak var weakSelf = self
        dismiss(animated: true) {
            weakSelf?.iImagePickerController(weakSelf!, croppedImage: image)
        }
    }
    
    // *****
    // Kind of delegate method for iImagePickerController
    // Method will be override in child class to get the cropped image
    // *****
    open func iImagePickerController(_ imagePicker: ImagePickerController!, croppedImage: UIImage!) {
        
    }
    
    // *****
    // Check camera permissions
    // *****
    func checkCameraPermissons() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            callCamera()
        } else {
            let alert: UIAlertController = UIAlertController(title: nil, message: cameraNotAvailable, preferredStyle: .alert)
            let okButton: UIAlertAction = UIAlertAction(title: ok, style: .default) { action -> Void in
                print("Cancel")
            }
            alert.addAction(okButton)
            
        }
    }
    
    fileprivate func callCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .authorized:
            openImagePickerWith(type: .camera)
        case .denied:
            alertForCameraAccess()
        case .notDetermined:
            alertForAllowCameraAccessViaSetting()
        default:
            alertForCameraAccess()
        }
    }
    
    fileprivate func alertForCameraAccess() {
        let alert: UIAlertController = UIAlertController(title: cameraPermissionAlertTitle, message: cameraPermissionAlertMessage, preferredStyle: .alert)
        
        let settingsButton: UIAlertAction = UIAlertAction(title: settings, style: .default ) { action -> Void in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url as URL)
            }
        }
        let cancelButton: UIAlertAction = UIAlertAction(title: cancel, style: .cancel) { action -> Void in
            print("Cancel")
        }
        alert.addAction(settingsButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func alertForAllowCameraAccessViaSetting() {
        if AVCaptureDevice.devices(for: AVMediaType.video).count > 0 {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                DispatchQueue.main.async() {
                    self.callCamera()
                }
            }
        }
    }
    
    // *****
    // Check photo library
    // *****
    fileprivate func callPhotoLibrary() {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
        case .authorized:
            openImagePickerWith(type: .photoLibrary)
        case .denied:
            alertForPhotoLibraryAccess()
        case .notDetermined:
            alertForAllowPhotoLibraryAccessViaSettings()
        default:
            alertForPhotoLibraryAccess()
        }
    }
    
    fileprivate func alertForPhotoLibraryAccess() {
        
        let alert: UIAlertController = UIAlertController(title: photoLibraryPermissionAlertTitle, message: photoLibraryPermissionAlertMessage, preferredStyle: .alert)
        
        let settingsButton: UIAlertAction = UIAlertAction(title: settings, style: .default ) { action -> Void in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url as URL)
            }
        }
        let cancelButton: UIAlertAction = UIAlertAction(title: cancel, style: .cancel) { action -> Void in
            print("Cancel")
        }
        alert.addAction(settingsButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func alertForAllowPhotoLibraryAccessViaSettings() {
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                self.callPhotoLibrary()
            }
        }
    }
    // MARK: 
    // MARK: Dealloc methods
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
