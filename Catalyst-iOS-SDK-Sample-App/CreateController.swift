//
//  CreateController.swift
//  CatalystTestApp
//
//  Created by Umashri R on 11/09/20.
//  Copyright © 2020 Umashri R. All rights reserved.
//

import UIKit
import ZCatalyst

class CreateController : UITableViewController
{
    let tableName : String
    let dataBuilder : CatalystDataBuilder
    var columns = [ ZCatalystColumn ]()
    {
        didSet
        {
            for index in 0..<columns.count
            {
                if columns[ index ].category == 1
                {
                    columns.remove( at : index )
                }
            }
        }
    }
    var row : ZCatalystRow?
    var cellPadding : CGFloat = 5
    var attachmentURL : URL?
    var attachmentName : String?
    
    init( tableName : String, row : ZCatalystRow?, dataBuilder : CatalystDataBuilder )
    {
        self.tableName = tableName
        self.dataBuilder = dataBuilder
        self.row = row
        super.init( style : .plain )
        if tableName == "Tasks"
        {
            if let table = dataBuilder.getData().getTask()
            {
                if row == nil
                {
                    self.row = table.newRow()
                }
                if let columns = dataBuilder.getData().getTaskColumns()
                {
                    for column in columns
                    {
                        if ( column.category != 1 )
                        {
                            if column.name == "isCompleted"
                            {
                                if self.row?.id != 0
                                {
                                    self.columns.append( column )
                                }
                            }
                            else
                            {
                                self.columns.append( column )
                            }
                        }
                    }
                }
                else
                {
                    getColumns( from : table )
                }
            }
            else
            {
                getTable( tableName : tableName )
            }
        }
        else if tableName == "Projects"
        {
            if let table = dataBuilder.getData().getProject()
            {
                if row == nil
                {
                    self.row = table.newRow()
                }
                if let columns = dataBuilder.getData().getProjectColumns()
                {
                    for column in columns
                    {
                        if column.category != 1
                        {
                            self.columns.append( column )
                        }
                    }
                }
                else
                {
                    getColumns( from : table )
                }
            }
            else
            {
                getTable( tableName : tableName )
            }
        }
    }
    
    required init?( coder : NSCoder )
    {
        fatalError( "init( coder : ) has not been implemented" )
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.register( TextFieldCell.self, forCellReuseIdentifier : TextFieldCell.identifier )
        self.tableView.register( BooleanField.self, forCellReuseIdentifier : BooleanField.identifier )
        self.tableView.register( ButtonFieldCell.self, forCellReuseIdentifier : ButtonFieldCell.identifier )
        self.tableView.allowsSelection = false
//        self.cellPadding = self.tableView.bounds.width * 0.01
        
        if row?.id == 0
        {
            if tableName == "Tasks"
            {
                self.navigationItem.title = "Create Task"
            }
            else
            {
                self.navigationItem.title = "Create Project"
            }
        }
        else
        {
            if tableName == "Tasks"
            {
                self.navigationItem.title = "Edit Task"
            }
            else
            {
                self.navigationItem.title = "Edit Project"
            }
        }
        
        let editButton = UIBarButtonItem( title : "Save", style : .plain, target : self, action : #selector( save ) )
        self.navigationItem.setRightBarButton( editButton, animated : true )
        
        addTapGestureRecognizer( with : #selector( done ) )
    }

    // MARK: - Table view data source

    override func numberOfSections( in tableView : UITableView ) -> Int
    {
        return 1
    }

    override func tableView( _ tableView : UITableView, numberOfRowsInSection section : Int ) -> Int
    {
        return columns.count
    }
    
    override func tableView( _ tableView : UITableView, cellForRowAt indexPath : IndexPath ) -> UITableViewCell
    {
        if columns[ indexPath.row ].dataType == .boolean
        {
            let cell = BooleanField.dequeue( self.tableView, for : indexPath, displayLabel : columns[ indexPath.row ].name, value : nil, rowDataDelegate : self, cellPadding : cellPadding )
            return cell
        }
        else if columns[ indexPath.row ].name == "Attachment"
        {
            let id : String? = row?.getValue( forKey : "Attachment" )
            if let id = id, let attachmentId = Int64( id )
            {
                if let file = dataBuilder.getData().getFile( id : attachmentId )
                {
                    self.setAttachmentName( file.name )
                }
                else
                {
                    if let folder = dataBuilder.getData().getFolder()
                    {
                        folder.getFile( fileId : attachmentId) { ( result ) in
                            switch result
                            {
                            case .success( let file ) :
                                self.setAttachmentName( file.name )
                                self.dataBuilder.addFile( file )
                                DispatchQueue.main.async {
                                    self.tableView.reloadRows( at : [ indexPath ], with : .automatic )
                                }
                            case .error( let error ) :
                                print( "Error occurred >>> \( error )" )
                            }
                        }
                    }
                    else
                    {
                        ZCatalystApp.shared.getFileStoreInstance().getFolder( id : 2823000000006561 ) { ( folderResult ) in
                            switch folderResult
                            {
                            case .success( let folder ) :
                                self.dataBuilder.setFolder( folder : folder )
                                folder.getFile( fileId : attachmentId) { ( result ) in
                                    switch result
                                    {
                                    case .success( let file ) :
                                        self.setAttachmentName( file.name )
                                        self.dataBuilder.addFile( file )
                                        DispatchQueue.main.async {
                                            self.tableView.reloadRows( at : [ indexPath ], with : .automatic )
                                        }
                                    case .error( let error ) :
                                        print( "Error occurred >>> \( error )" )
                                    }
                                }
                            case .error( let error ) :
                                print( "Error occurred >>> \( error )" )
                            }
                        }
                    } 
                }
            }
            let cell = ButtonFieldCell.dequeue( tableView, for : indexPath, displayLabel : columns[ indexPath.row ].name, attachmentName : nil, dataBuilder : dataBuilder, rowDataDelegate : self, isReadOnly : false, cellPadding : cellPadding )
            return cell
        }
        else
        {
            let cell = TextFieldCell.dequeue( tableView, for : indexPath, column : columns[ indexPath.row ], value : nil, rowDataDelegate : self, dataBuilder : dataBuilder, cellPadding : cellPadding )
            return cell
        }
    }
    
    func addTapGestureRecognizer( with action : Selector )
    {
        let gesture = UITapGestureRecognizer( target : self, action : action )
        gesture.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer( gesture )
    }
    
    @objc func done( _ sender : AnyObject )
    {
        self.tableView.endEditing( true )
    }
    
    @objc func save()
    {
        if let row = row
        {
            var isMandatoryFilled = true
            for column in columns
            {
                if column.isMandatory == true, row.getData()[ column.name ] == nil
                {
                    isMandatoryFilled = false
                }
            }
            if isMandatoryFilled
            {
                if row.id != 0
                {
                    row.update { ( result ) in
                        switch result
                        {
                        case .success( let updatedRow ) :
                            print( "Edit successful" )
                            if self.tableName == "Tasks"
                            {
                                if let rows = self.dataBuilder.getData().getTasks()
                                {
                                    var rows = rows
                                    for index in 0..<rows.count
                                    {
                                        if rows[ index ].id == updatedRow.id
                                        {
                                            rows[ index ] = updatedRow
                                            self.dataBuilder.setTasks( rows )
                                        }
                                    }
                                }
                            }
                            else
                            {
                                if let rows = self.dataBuilder.getData().getProjects()
                                {
                                    var rows = rows
                                    for index in 0..<rows.count
                                    {
                                        if rows[ index ].id == updatedRow.id
                                        {
                                            rows[ index ] = updatedRow
                                            self.dataBuilder.setProjects( rows )
                                        }
                                    }
                                }
                            }
                            DispatchQueue.main.async {
                                ( getCurrentViewController() as? UINavigationController )?.popViewController( animated : true )
                            }
                        case .error( let error ) :
                            print( "Error occurred >>> \( error )" )
                        }
                    }
                }
                else
                {
                    if let attachmentURL = attachmentURL
                    {
                        if let folder = dataBuilder.getData().getFolder()
                        {
                            folder.upload( filePath : attachmentURL) { ( fileResult ) in
                                switch fileResult
                                {
                                case .success( let file ) :
                                    self.dataBuilder.addFile( file )
                                    row.setColumnValue( columnName : "Attachment", value : file.id )
                                    self.create( row : row )
                                case .error( let error ) :
                                    print( "Error occurred >>> \( error )" )
                                }
                            }
                        }
                        else
                        {
                            ZCatalystApp.shared.getFileStoreInstance().getFolder( id : 2823000000006561 ) { ( folderResult ) in
                                switch folderResult
                                {
                                case .success( let folder ) :
                                    self.dataBuilder.setFolder( folder : folder )
                                    folder.upload( filePath : attachmentURL) { ( fileResult ) in
                                        switch fileResult
                                        {
                                        case .success( let file ) :
                                            self.dataBuilder.addFile( file )
                                            row.setColumnValue( columnName : "Attachment", value : file.id )
                                            self.create( row : row )
                                        case .error( let error ) :
                                            print( "Error occurred >>> \( error )" )
                                        }
                                    }
                                case .error( let error ) :
                                    print( "Error occurred >>> \( error )" )
                                }
                            }
                        }
                    }
                    else
                    {
                        create( row : row )
                    }
                }
            }
            else
            {
                let okButton = UIAlertAction( title : "OK", style : .cancel) { ( _ ) in
                    getCurrentViewController()?.dismiss(animated: true, completion: nil)
                }
                let alert = UIAlertController( title : "Error", message : "Mandatory not filled", preferredStyle : .alert )
                alert.addAction( okButton )
                getCurrentViewController()?.present( alert, animated : true, completion : {
                    alert.view.superview?.isUserInteractionEnabled = true
                } )
            }
        }
    }
    
    // MARK: - Fetch data from Catalyst sdk
    
    func getTable( tableName : String )
    {
        ZCatalystApp.shared.getDataStoreInstance().getTable( name : tableName ) { ( result ) in
            switch result
            {
            case .success( let table ) :
                self.getColumns( from : table )
                if tableName == "Tasks"
                {
                    self.dataBuilder.setTask( table : table )
                }
                else if tableName == "Projects"
                {
                    self.dataBuilder.setProject( table : table )
                }
                if self.row == nil
                {
                    self.row = table.newRow()
                }
            case .error( let error ) :
                print( "Error occurred >>> \( error )" )
            }
        }
    }
    
    func getColumns( from table : ZCatalystTable )
    {
        table.getColumns { ( result ) in
            switch result
            {
            case .success( let columns ) :
                for column in columns
                {
                    if column.category != 1
                    {
                        if column.name == "isCompleted"
                        {
                            if self.row?.id != 0
                            {
                                self.columns.append( column )
                            }
                        }
                        else
                        {
                            self.columns.append( column )
                        }
                    }
                }
                self.dataBuilder.setColumns( columns, for : table )
                DispatchQueue.main.async
                {
                    self.tableView.reloadData()
                }
            case .error( let error ) :
                print( "Error occurred >>> \( error )" )
            }
        }
    }
    
    func create( row : ZCatalystRow )
    {
        row.create { ( result ) in
            switch result
            {
            case .success( let createdRow ) :
                print( "Create successful..." )
                if self.tableName == "Tasks"
                {
                    if let rows = self.dataBuilder.getData().getTasks()
                    {
                        var rows = rows
                        rows.append( createdRow )
                        self.dataBuilder.setTasks( rows )
                    }
                }
                else
                {
                    if let rows = self.dataBuilder.getData().getProjects()
                    {
                        var rows = rows
                        rows.append( createdRow )
                        self.dataBuilder.setProjects( rows )
                    }
                }
                DispatchQueue.main.async {
                    ( getCurrentViewController() as? UINavigationController )?.popViewController( animated : true )
                }
            case .error( let error ) :
                print( "Error occurred >>> \( error )" )
            }
        }
    }
}

extension CreateController : RowDataDelegate
{
    func getRow() -> ZCatalystRow?
    {
        return self.row
    }
    
    func setRowData( for columnName : String, value : Any? )
    {
        self.row?.setColumnValue( columnName : columnName, value : value )
    }
    
    func getAttachmentURL() -> URL?
    {
        return attachmentURL
    }
    
    func setAttachmentURL( _ url : URL? )
    {
        self.attachmentURL = url
        self.attachmentName = url?.lastPathComponent
        self.tableView.reloadRows( at : [ IndexPath( row : 6, section : 0 ) ], with : .automatic )
    }
    
    func getAttachmentName() -> String?
    {
        return attachmentName
    }
    
    func setAttachmentName( _ name : String? )
    {
        self.attachmentName = name
    }
}

protocol RowDataDelegate
{
    func getRow() -> ZCatalystRow?
    func setRowData( for columnName : String, value : Any? )
    func getAttachmentURL() -> URL?
    func setAttachmentURL( _ url : URL? )
    func getAttachmentName() -> String?
    func setAttachmentName( _ name : String? )
}
