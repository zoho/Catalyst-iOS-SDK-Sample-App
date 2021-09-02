//
//  ButtonFieldCell.swift
//  CatalystTestApp
//
//  Created by Umashri R on 22/09/20.
//  Copyright © 2020 Umashri R. All rights reserved.
//

import UIKit
import ZCatalyst
import MobileCoreServices

class ButtonFieldCell : UITableViewCell
{
    let background = UIView()
    let button = UIButton()
    let label = UILabel()
    var displayLabel = String()
    var cellPadding : CGFloat = 0
    var rowDataDelegate : RowDataDelegate?
    var dataBuilder : CatalystDataBuilder?
    var attachmentName : String?
    var isReadOnly : Bool = false
    static var identifier = "ButtonFieldCell"
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected( _ selected : Bool, animated : Bool )
    {
        super.setSelected( selected, animated : animated )
    }
    
    static func dequeue( _ tableView : UITableView, for indexPath : IndexPath, displayLabel : String, attachmentName : String?, dataBuilder : CatalystDataBuilder, rowDataDelegate : RowDataDelegate?, isReadOnly : Bool, cellPadding : CGFloat ) -> ButtonFieldCell
    {
        let cell = tableView.dequeueReusableCell( withIdentifier : ButtonFieldCell.identifier, for : indexPath ) as? ButtonFieldCell ?? ButtonFieldCell()
        cell.rowDataDelegate = rowDataDelegate
        cell.attachmentName = attachmentName
        cell.displayLabel = displayLabel
        cell.cellPadding = cellPadding
        cell.dataBuilder = dataBuilder
        cell.isReadOnly = isReadOnly
        cell.constructCell()
        return cell
    }
    
    func setConstraints()
    {
        background.leadingAnchor.constraint( equalTo : contentView.leadingAnchor ).isActive = true
        background.widthAnchor.constraint( equalTo : contentView.widthAnchor, multiplier : 0.4 ).isActive = true
        background.topAnchor.constraint( equalTo : contentView.topAnchor ).isActive = true
        background.bottomAnchor.constraint( equalTo : contentView.bottomAnchor ).isActive = true
        
        label.leadingAnchor.constraint( equalTo : contentView.leadingAnchor, constant : cellPadding ).isActive = true
        label.trailingAnchor.constraint( equalTo : background.trailingAnchor, constant : -cellPadding ).isActive = true
        label.centerYAnchor.constraint( equalTo : contentView.centerYAnchor ).isActive = true
        
        button.trailingAnchor.constraint( equalTo : self.contentView.trailingAnchor, constant : -cellPadding ).isActive = true
        button.leadingAnchor.constraint( equalTo : background.trailingAnchor, constant : cellPadding ).isActive = true
        button.centerYAnchor.constraint( equalTo : self.contentView.centerYAnchor ).isActive = true
    }
    
    func constructCell()
    {
        for subview in self.contentView.subviews
        {
            subview.removeFromSuperview()
        }
        for subview in background.subviews
        {
            subview.removeFromSuperview()
        }
        
        if #available( iOS 13.0, * )
        {
            background.backgroundColor = .secondarySystemBackground
        }
        else
        {
            background.backgroundColor = UIColor( red : 0.98, green : 0.98, blue : 0.98, alpha : 1.0 )
        }
        background.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview( background )
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = displayLabel
        label.font = UIFont.systemFont( ofSize : 14 )
        label.textColor = .systemGray
        label.textAlignment = .right
        background.addSubview( label )
        
        button.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview( button )
        if let name = rowDataDelegate?.getAttachmentName()
        {
            button.setTitle( name, for : .normal )
        }
        else if let attachmentName = attachmentName
        {
            button.setTitle( attachmentName, for : .normal )
        }
        else if let row = rowDataDelegate?.getRow(), row.id == 0
        {
            button.setTitle( "+ Add an Attachment", for : .normal )
        }
        button.setTitleColor( .systemBlue, for : .normal )
        button.addTarget( self, action : #selector( navigate ), for: .touchUpInside )
        
        setConstraints()
    }
    
    @objc func navigate()
    {
        let open = UIAlertAction( title : "Open Attachment", style : .default ) { ( _ ) in
            if let url = self.rowDataDelegate?.getAttachmentURL()
            {
                self.endEditing( true )
                let documentInteractionController = UIDocumentInteractionController( url : url )
                documentInteractionController.delegate = self
                documentInteractionController.presentPreview( animated : true )
            }
            else if let _ = self.rowDataDelegate?.getAttachmentName()
            {
                let attachmentId : String? = self.rowDataDelegate?.getRow()?.getValue( forKey : "Attachment" )
                if let attachmentId = attachmentId, let id = Int64( attachmentId )
                {
                    if let folder = self.dataBuilder?.getData().getFolder()
                    {
                        if let file = self.dataBuilder?.getData().getFile( id : id )
                        {
                            if let url = self.dataBuilder?.getData().getFilePath( for : id )
                            {
                                self.endEditing( true )
                                let documentInteractionController = UIDocumentInteractionController( url : url )
                                documentInteractionController.delegate = self
                                documentInteractionController.presentPreview( animated : true )
                            }
                            else
                            {
                                self.downloadFile( file )
                            }
                        }
                        else
                        {
                            self.getFile( id : id, folder : folder )
                        }
                    }
                    else
                    {
                        self.getFolder( fileId : id )
                    }
                }
            }
        }
        
        let takePhoto = UIAlertAction( title : "Take photo", style : .default ) { ( _ ) in
            self.addImagePickerController( sourceType : .camera )
        }

        let addPhotoFromLibrary = UIAlertAction( title : "Add photo from library", style : .default) { ( _ ) in
            self.addImagePickerController( sourceType : .photoLibrary )
        }
        
        self.endEditing( true )
        let addFiles = UIAlertAction( title : "Add Files", style : .default) { ( _ ) in
            let documentPickerViewController = UIDocumentPickerViewController( documentTypes : [ kUTTypeFolder as String, kUTTypePDF as String, kUTTypeGIF as String, kUTTypeMP3 as String, kUTTypePNG as String, kUTTypeJPEG as String, kUTTypeMPEG as String, kUTTypeText as String, kUTTypeRTFD as String, kUTTypeAudio as String, kUTTypeImage as String, kUTTypeMovie as String, kUTTypeVideo as String, kUTTypeMPEG4 as String ], in : .import )
            documentPickerViewController.allowsMultipleSelection = false
            documentPickerViewController.delegate = self
            ( getCurrentViewController() as? UINavigationController )?.present( documentPickerViewController, animated : true, completion : nil )
        }

        let cancel = UIAlertAction( title : "Cancel", style : .cancel) { ( _ ) in
        }

        let remove = UIAlertAction( title : "Remove Photo", style : .destructive) { ( _ ) in
            self.rowDataDelegate?.setAttachmentURL( nil )
            self.rowDataDelegate?.setAttachmentName( nil )
            self.rowDataDelegate?.setRowData( for : "Attachment", value : nil )
        }

        var alertActions = [ UIAlertAction ]()
        if rowDataDelegate?.getAttachmentURL() == nil && rowDataDelegate?.getAttachmentName() == nil
        {
            alertActions = [ takePhoto, addPhotoFromLibrary, addFiles, cancel ]
        }
        else
        {
            if isReadOnly
            {
                alertActions = [ open, takePhoto, addPhotoFromLibrary, addFiles, cancel ]
            }
            else
            {
                alertActions = [ open, takePhoto, addPhotoFromLibrary, addFiles, cancel, remove ]
            }
        }

        let alert : UIAlertController = getAlertController( title : nil, message : nil, preferredStyle : .actionSheet, with : alertActions )

        self.endEditing( true )
        getCurrentViewController()?.present( alert, animated : true, completion : nil )
    }
    
    func getAlertController( title : String?, message : String?, preferredStyle : UIAlertController.Style, with actions : [ UIAlertAction ]? ) -> UIAlertController
    {
        let alert = UIAlertController( title : title, message : message, preferredStyle : preferredStyle )
        
        if let actions = actions
        {
            for action in actions
            {
                alert.addAction( action )
            }
        }
        return alert
    }
    
    func addImagePickerController( sourceType : UIImagePickerController.SourceType )
    {
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable( sourceType )
        {
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            self.endEditing( true )
            getCurrentViewController()?.present( imagePicker, animated : true, completion : nil )
        }
        else
        {
            let okButton = UIAlertAction( title : "OK", style : .cancel ) { ( _ ) in
            }
            let alert : UIAlertController = getAlertController( title : "Permission denied", message : nil, preferredStyle : .alert, with : [ okButton ] )
            
            self.endEditing( true )
            getCurrentViewController()?.present( alert, animated : true, completion : nil )
        }
    }
    
    func getFolder( fileId : Int64 )
    {
        ZCatalystApp.shared.getFileStoreInstance().getFolder( id : 2823000000006561) { ( result ) in
            switch result
            {
            case .success( let folder ) :
                self.getFile( id : fileId, folder : folder )
                self.dataBuilder?.setFolder( folder : folder )
            case .error( let error ) :
                print( "Error occurred >>> \( error )" )
            }
        }
    }
    
    func getFile( id : Int64, folder : ZCatalystFolder )
    {
        folder.getFile( fileId : id) { ( result ) in
            switch result
            {
            case .success( let file ) :
                self.downloadFile( file )
                self.dataBuilder?.addFile( file )
            case .error( let error ) :
                print( "Error occurred >>> \( error )" )
            }
        }
    }
    
    func downloadFile( _ file : ZCatalystFile )
    {
        file.download { ( result ) in
            switch result
            {
            case .success( let fileResult ) :
                self.dataBuilder?.addFilePath( for : file.id, path : fileResult.1 )
                do
                {
                    let downloadedData = try Data( contentsOf : fileResult.1 )
                    DispatchQueue.main.async( execute : {
                        print("transfer completion OK!")
                        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true ).first! as NSString
                        let destinationPath = documentDirectoryPath.appendingPathComponent( file.name )
                        let fileURL = URL( fileURLWithPath : destinationPath )
                        FileManager.default.createFile( atPath : fileURL.path, contents : downloadedData, attributes : nil )
                        if FileManager.default.fileExists( atPath : fileURL.path )
                        {
                            self.endEditing( true )
                            self.dataBuilder?.addFilePath( for : file.id, path : fileURL )
                            print( "pdfFileURL present!" ) // Confirm that the file is here!
                            let documentInteractionController = UIDocumentInteractionController( url : fileURL )
                            documentInteractionController.delegate = self
                            documentInteractionController.presentPreview( animated : true )
                        }
                    } )
                }
                catch
                {
                    print( error )
                }
            case .error( let error ) :
                print( "Error occurred >>> \( error )" )
            }
        }
    }
}

extension ButtonFieldCell : UIDocumentPickerDelegate
{
    func documentPicker( _ controller : UIDocumentPickerViewController, didPickDocumentsAt urls : [ URL ] )
    {
        if let url = urls.first
        {
            self.rowDataDelegate?.setAttachmentURL( url )
        }
    }
}

extension ButtonFieldCell : UIDocumentInteractionControllerDelegate
{
    func documentInteractionControllerViewControllerForPreview( _ controller : UIDocumentInteractionController ) -> UIViewController
    {
        if let controller = getCurrentViewController()
        {
            return controller
        }
        return UIViewController()
    }
}

extension ButtonFieldCell : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController( _ picker : UIImagePickerController, didFinishPickingMediaWithInfo info : [ UIImagePickerController.InfoKey : Any ] )
    {
        if let url = info[ UIImagePickerController.InfoKey.imageURL ] as? URL
        {
            self.rowDataDelegate?.setAttachmentURL( url )
        }
    }
    
    func imagePickerControllerDidCancel( _ picker : UIImagePickerController )
    {
        picker.dismiss( animated : true, completion : nil )
    }
}
