//
//  TaskViewController.swift
//  CatalystTestApp
//
//  Created by Umashri R on 08/09/20.
//  Copyright © 2020 Umashri R. All rights reserved.
//

import UIKit
import ZCatalyst

class DetailViewController : UITableViewController
{
    let tableName : String
    let rowId : Int64
    let dataBuilder : CatalystDataBuilder
    var columns : [ ZCatalystColumn ] = [ ZCatalystColumn ]()
    var row : ZCatalystRow?
    var cellPadding : CGFloat = 5
    var attachmentName : String?
    
    init( tableName : String, rowId : Int64, dataBuilder : CatalystDataBuilder )
    {
        self.tableName = tableName
        self.dataBuilder = dataBuilder
        self.rowId = rowId
        super.init( style : .plain )
        self.configureData()
    }
    
    func configureData()
    {
        if tableName == "Tasks"
        {
            if let table = dataBuilder.getData().getTask()
            {
                if let columns = dataBuilder.getData().getTaskColumns()
                {
                    self.columns = columns
                }
                else
                {
                    getColumns( from : table )
                }
                if let rows = dataBuilder.getData().getTasks()
                {
                    for row in rows
                    {
                        if row.id == rowId
                        {
                            self.row = row
                        }
                    }
                    if self.row == nil
                    {
                        getRow( with : rowId, from : table )
                    }
                }
            }
            else
            {
                getTable( tableName : tableName, rowId : rowId )
            }
        }
        else if tableName == "Projects"
        {
            if let table = dataBuilder.getData().getProject()
            {
                if let columns = dataBuilder.getData().getProjectColumns()
                {
                    self.columns = columns
                }
                else
                {
                    getColumns( from : table )
                }
                if let rows = dataBuilder.getData().getProjects()
                {
                    for row in rows
                    {
                        if row.id == rowId
                        {
                            self.row = row
                        }
                    }
                    if self.row == nil
                    {
                        getRow( with : rowId, from : table )
                    }
                }
            }
            else
            {
                getTable( tableName : tableName, rowId : rowId )
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
        
        self.tableView.register( Field.self, forCellReuseIdentifier : Field.identifier )
        self.tableView.register( BooleanField.self, forCellReuseIdentifier : BooleanField.identifier )
        self.tableView.register( ForeignKeyField.self, forCellReuseIdentifier : ForeignKeyField.identifier )
        self.tableView.register( ButtonFieldCell.self, forCellReuseIdentifier : ButtonFieldCell.identifier )
        
        tableView.tableFooterView = nil
        tableView.allowsSelection = false
        
        let title : String? = row?[ "Title" ]
        self.navigationItem.title = title
        
        let editButton = UIBarButtonItem( title : "Edit", style : .plain, target : self, action : #selector( edit ) )
        self.navigationItem.setRightBarButton( editButton, animated : true )
    }
    
    override func viewWillAppear( _ animated : Bool )
    {
        super.viewWillAppear( animated )
        self.configureData()
        self.tableView.reloadData()
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
            let value : Bool? = row?[ columns[ indexPath.row ].name ]
            let cell = BooleanField.dequeue( self.tableView, for : indexPath, displayLabel : columns[ indexPath.row ].name, value : value, rowDataDelegate : nil, cellPadding : cellPadding )
            return cell
        }
        else if columns[ indexPath.row ].dataType == .foreignKey
        {
            let projId : String? = row?[ columns[ indexPath.row ].name ]
            if let projects = dataBuilder.getData().getProjects(), let projId = projId
            {
                for project in projects
                {
                    if project.id == Int64( projId )
                    {
                        let value : String? = project[ "Title" ]
                        let cell = ForeignKeyField.dequeue( self.tableView, for : indexPath, displayLabel : columns[ indexPath.row ].name, value : value, row : project, dataBuilder : dataBuilder, cellPadding : cellPadding )
                        return cell
                    }
                }
            }
            let cell = ForeignKeyField.dequeue( self.tableView, for : indexPath, displayLabel : columns[ indexPath.row ].name, value : nil, row : nil, dataBuilder : dataBuilder, cellPadding : cellPadding )
            return cell
        }
        else if columns[ indexPath.row ].name == "Attachment"
        {
            let id : String? = row?.getValue( forKey : "Attachment" )
            if let id = id, let attachmentId = Int64( id )
            {
                if let file = dataBuilder.getData().getFile( id : attachmentId )
                {
                    self.attachmentName = file.name
                }
                else
                {
                    if let folder = dataBuilder.getData().getFolder()
                    {
                        folder.getFile( fileId : attachmentId) { ( result ) in
                            switch result
                            {
                            case .success( let file ) :
                                self.dataBuilder.addFile( file )
                                self.attachmentName = file.name
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
                                        self.dataBuilder.addFile( file )
                                        self.attachmentName = file.name
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
            let cell = ButtonFieldCell.dequeue( tableView, for : indexPath, displayLabel : columns[ indexPath.row ].name, attachmentName : attachmentName, dataBuilder : dataBuilder, rowDataDelegate : self, isReadOnly : true, cellPadding : cellPadding )
            return cell
        }
        else
        {
            let value : String? = row?[ columns[ indexPath.row ].name ]
            let cell = Field.dequeue( self.tableView, for : indexPath, displayLabel : columns[ indexPath.row ].name, value : value, cellPadding : cellPadding )
            return cell
        }
    }
    
    @objc func edit()
    {
        self.navigationController?.pushViewController( CreateController( tableName : tableName, row : row, dataBuilder : dataBuilder ), animated : true )
    }
    
    // MARK: - Fetch data from Catalyst sdk
    
    func getTable( tableName : String, rowId : Int64? = nil )
    {
        ZCatalystApp.shared.getDataStoreInstance().getTable( name : tableName ) { ( result ) in
            switch result
            {
            case .success( let table ) :
                self.getColumns( from : table )
                if let rowId = rowId
                {
                    self.getRow( with : rowId, from : table )
                }
                if tableName == "Tasks"
                {
                    self.dataBuilder.setTask( table : table )
                }
                else if tableName == "Projects"
                {
                    self.dataBuilder.setProject( table : table )
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
                self.columns = columns
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
    
    func getRow( with id : Int64, from table : ZCatalystTable )
    {
        table.getRow( id : id ) { ( result ) in
            switch result
            {
            case .success( let row ) :
                self.row = row
                DispatchQueue.main.async
                {
                    self.tableView.reloadData()
                }
            case .error( let error ) :
                print( "Error occurred >>> \( error )" )
            }
        }
    }
}

extension DetailViewController : RowDataDelegate
{
    func getRow() -> ZCatalystRow?
    {
        return row
    }

    func setRowData( for columnName : String, value : Any? )
    {
    }

    func getAttachmentURL() -> URL?
    {
        return nil
    }

    func setAttachmentURL(_ url: URL?)
    {
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
