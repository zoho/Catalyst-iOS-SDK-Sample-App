//
//  TasksViewController.swift
//  CatalystTestApp
//
//  Created by Umashri R on 04/09/20.
//  Copyright © 2020 Umashri R. All rights reserved.
//

import UIKit
import ZCatalyst

class ListViewController : UITableViewController
{
    var tableName : String
    var searchOptions : ZCatalystSearchOptions?
    let dataBuilder : CatalystDataBuilder
    var filteredRows : [ [ String : Any? ] ]?
    var rows : [ ZCatalystRow ]?
    var textField : UITextField?
    var displayLabel : String?
    var rowDataDelegate : RowDataDelegate?
    
    
    init( tableName : String, searchOptions : ZCatalystSearchOptions?, dataBuilder : CatalystDataBuilder )
    {
        self.tableName = tableName
        self.searchOptions = searchOptions
        self.dataBuilder = dataBuilder
        super.init( style : .plain )
        self.configureData()
    }
    
    func configureData()
    {
        if searchOptions == nil
        {
            if tableName == "Tasks"
            {
                if let table = dataBuilder.getData().getTask()
                {
                    if let rows = dataBuilder.getData().getTasks()
                    {
                        self.rows = rows
                    }
                    else
                    {
                        self.getRows( from : table )
                    }
                }
                else
                {
                    getTable()
                }
            }
            else
            {
                if let table = dataBuilder.getData().getProject()
                {
                    if let rows = dataBuilder.getData().getProjects()
                    {
                        self.rows = rows
                    }
                    else
                    {
                        self.getRows( from : table )
                    }
                }
                else
                {
                    getTable()
                }
            }
        }
        else
        {
            getRowsFromSearch()
        }
    }
    
    required init?( coder : NSCoder )
    {
        fatalError( "init( coder : ) has not been implemented" )
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.register( UITableViewCell.self, forCellReuseIdentifier : "Task" )
        self.tableView.register( AddRowCell.self, forCellReuseIdentifier : AddRowCell.identifier )
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        if let filteredRows = filteredRows
        {
            return filteredRows.count + 1
        }
        if let rows = rows
        {
            return rows.count + 1
        }
        return 0
    }
    
    override func tableView( _ tableView : UITableView, cellForRowAt indexPath : IndexPath ) -> UITableViewCell
    {
        if indexPath.row == 0
        {
            if tableName == "Tasks"
            {
                let cell = AddRowCell.dequeue( self.tableView, indexPath : indexPath, title : "+ Add a Task", tableName : "Tasks", dataBuilder : dataBuilder, cellPadding : self.view.bounds.width * 0.01 )
                return cell
            }
            else
            {
                let cell = AddRowCell.dequeue( self.tableView, indexPath : indexPath, title : "+ Add a Project", tableName : "Projects", dataBuilder : dataBuilder, cellPadding : self.view.bounds.width * 0.01 )
                return cell
            }
        }
        else
        {
            if let filteredRows = filteredRows
            {
                let cell = tableView.dequeueReusableCell( withIdentifier : "Task", for : indexPath )
                cell.textLabel?.text = filteredRows[ indexPath.row - 1 ][ "Title" ] as? String
                return cell
            }
            else
            {
                let title : String? = rows?[ indexPath.row - 1 ][ "Title" ]
                let cell = tableView.dequeueReusableCell( withIdentifier : "Task", for : indexPath )
                cell.textLabel?.text =  title
                return cell
            }
        }
    }
    
    override func tableView( _ tableView : UITableView, didSelectRowAt indexPath : IndexPath )
    {
        if let textField = textField, let rowDataDelegate = rowDataDelegate, let displayLabel = displayLabel, let id = rows?[ indexPath.row - 1 ].id
        {
            let title : String? = rows?[ indexPath.row - 1 ][ "Title" ]
            textField.text = title
            rowDataDelegate.setRowData( for : displayLabel, value : id )
            self.navigationController?.popViewController( animated : true )
            textField.endEditing( true )
        }
        else
        {
            if let filteredRows = filteredRows, let idStr = filteredRows[ indexPath.row - 1 ][ "ROWID" ] as? String, let id = Int64( idStr )
            {
                self.navigationController?.pushViewController( DetailViewController( tableName : "Tasks", rowId : id, dataBuilder : dataBuilder ), animated : true )
            }
            else if let id = rows?[ indexPath.row - 1 ].id
            {
                self.navigationController?.pushViewController( DetailViewController( tableName : "Tasks", rowId : id, dataBuilder : dataBuilder ), animated : true )
            }
        }
    }
    
    override func tableView( _ tableView : UITableView, canEditRowAt indexPath : IndexPath ) -> Bool
    {
        if indexPath.row != 0
        {
            return true
        }
        return false
    }
    
    override func tableView( _ tableView : UITableView, commit editingStyle : UITableViewCell.EditingStyle, forRowAt indexPath : IndexPath )
    {
        if editingStyle == .delete
        {
            tableView.beginUpdates()
            if let rows = rows
            {
                self.rows?.remove( at : indexPath.row - 1 )
                tableView.deleteRows( at : [ indexPath ], with : .automatic )
                deleteRow( row : rows[ indexPath.row - 1 ], id : rows[ indexPath.row - 1 ].id )
            }
            else
            {
                if let id = filteredRows?[ indexPath.row ][ "ROWID" ] as? Int64
                {
                    filteredRows?.remove( at : indexPath.row - 1 )
                    tableView.deleteRows( at : [ indexPath ], with : .automatic )
                    deleteRow( row : nil, id : id )
                }
            }
            tableView.endUpdates()
        }
    }
    
    // MARK: - Fetch data from Catalyst sdk
    
    func getTable()
    {
        ZCatalystApp.shared.getDataStoreInstance().getTable( name : tableName ) { ( result ) in
            switch result
            {
            case .success( let table ) :
                if self.tableName == "Tasks"
                {
                    self.dataBuilder.setTask( table : table )
                }
                else
                {
                    self.dataBuilder.setProject( table : table )
                }
                self.getRows( from : table )
            case .error( let error ) :
                print( "Error occurred >>> \( error )" )
            }
        }
    }
    
    func getRows( from table : ZCatalystTable )
    {
        table.getRows { ( rowResult ) in
            switch rowResult
            {
            case .success( let rows ) :
                self.rows = rows
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                if self.tableName == "Tasks"
                {
                    self.dataBuilder.setTasks( rows )
                }
                else
                {
                    self.dataBuilder.setProjects( rows )
                }
            case .error( let error ) :
            print( "Error occurred >>> \( error )" )
            }
        }
    }
    
    func getRowsFromSearch()
    {
        if let searchOptions = searchOptions
        {
            ZCatalystApp.shared.search( searchOptions : searchOptions ) { ( result ) in
                switch result
                {
                case .success( let result ) :
                    if let tasks = result[ "Tasks" ] as? [ [ String : Any ]  ]
                    {
                        self.filteredRows = tasks
                    }
                    else if let projects = result[ "Projects" ] as? [ [ String : Any ]  ]
                    {
                        self.filteredRows = projects
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .error( let error ) :
                    print( "Error occurred >>> \( error )" )
                }
            }
        }
    }
    
    func deleteRow( row : ZCatalystRow?, id : Int64 )
    {
        if let row = row
        {
            row.delete { ( error ) in
                if let error = error
                {
                    print( "Error occurred >>> \( error )" )
                }
            }
        }
        else
        {
            if tableName == "Tasks"
            {
                if let table = dataBuilder.getData().getTask()
                {
                    getRow( with : id, from : table )
                }
                else
                {
                    ZCatalystApp.shared.getDataStoreInstance().getTable( name : tableName ) { ( result ) in
                        switch result
                        {
                        case .success( let table ) :
                            if self.tableName == "Tasks"
                            {
                                self.dataBuilder.setTask( table : table )
                            }
                            else
                            {
                                self.dataBuilder.setProject( table : table )
                            }
                            self.getRow( with : id, from : table )
                        case .error( let error ) :
                            print( "Error occurred >>> \( error )" )
                        }
                    }
                }
            }
            else
            {
                if let table = dataBuilder.getData().getProject()
                {
                    getRow( with : id, from : table )
                }
                else
                {
                    ZCatalystApp.shared.getDataStoreInstance().getTable( name : tableName ) { ( result ) in
                        switch result
                        {
                        case .success( let table ) :
                            if self.tableName == "Tasks"
                            {
                                self.dataBuilder.setTask( table : table )
                            }
                            else
                            {
                                self.dataBuilder.setProject( table : table )
                            }
                            self.getRow( with : id, from : table )
                        case .error( let error ) :
                            print( "Error occurred >>> \( error )" )
                        }
                    }
                }
            }
        }
    }
    
    func getRow( with id : Int64, from table : ZCatalystTable )
    {
        table.getRow( id : id ) { ( result ) in
            switch result
            {
            case .success( let row ) :
                self.delete( row : row )
            case .error( let error ) :
                print( "Error occurred >>> \( error )" )
            }
        }
    }
    
    func delete( row : ZCatalystRow )
    {
        row.delete { ( error ) in
            if let error = error
            {
                print( "Error occurred >>> \( error )" )
            }
        }
    }
}
