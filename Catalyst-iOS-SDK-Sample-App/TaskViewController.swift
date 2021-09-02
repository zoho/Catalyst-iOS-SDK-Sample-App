//
//  TaskViewController.swift
//  CatalystTestApp
//
//  Created by Umashri R on 08/09/20.
//  Copyright © 2020 Umashri R. All rights reserved.
//

import UIKit
import Catalyst

class DetailViewController : UITableViewController
{
    var columns : [ ZCatalystColumn ] = [ ZCatalystColumn ]()
    var task : ZCatalystRow?
    var cellPadding : CGFloat = 0
    
    init( task : ZCatalystRow? )
    {
        self.task = task
        super.init( style : .plain )
        if let homeController = self.navigationController?.viewControllers[ 0 ] as? HomeController, let table = homeController.task
        {
            self.getColumns( from : table )
        }
        else
        {
            self.getTable()
        }
    }
    
    init( id : Int64 )
    {
        super.init( style : .plain )
        if let homeController = self.navigationController?.viewControllers[ 0 ] as? HomeController, let table = homeController.task
        {
            self.getColumns( from : table )
            self.getRow( with : id, from : table )
        }
        else
        {
            self.getTable( rowId : id )
        }
    }
    
    required init?( coder : NSCoder )
    {
        fatalError( "init( coder : ) has not been implemented" )
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.register( UITableViewCell.self, forCellReuseIdentifier : "TaskDetail" )
        
        self.tableView.register( Field.self, forCellReuseIdentifier : Field.identifier )
        self.tableView.register( BooleanField.self, forCellReuseIdentifier : BooleanField.identifier )
        self.cellPadding = self.view.bounds.width * 0.01
        
        tableView.tableFooterView = nil
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
            let value : Bool? = task?[ columns[ indexPath.row ].name ]
            let cell = BooleanField.dequeue( self.tableView, for : indexPath, displayLabel : columns[ indexPath.row ].name, value : value, cellPadding : cellPadding )
            return cell
        }
        else
        {
            let value : String? = task?[ columns[ indexPath.row ].name ]
            let cell = Field.dequeue( self.tableView, for : indexPath, displayLabel : columns[ indexPath.row ].name, value : value, cellPadding : cellPadding )
            return cell
        }
    }
    
    // MARK: - Fetch data from Catalyst sdk
    
    func getTable( rowId : Int64? = nil )
    {
        ZCatalystApp.shared.getDataStoreInstance().getTable( name : "Tasks") { ( result ) in
            switch result
            {
            case .success( let table ) :
                self.getColumns( from : table )
                if let rowId = rowId
                {
                    self.getRow( with : rowId, from : table )
                }
                DispatchQueue.main.async
                {
                    if let homeController = self.navigationController?.viewControllers[ 0 ] as? HomeController, let table = homeController.task
                    {
                        homeController.task = table
                    }
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
                self.task = row
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
