//
//  TasksViewController.swift
//  CatalystTestApp
//
//  Created by Umashri R on 04/09/20.
//  Copyright © 2020 Umashri R. All rights reserved.
//

import UIKit
import Catalyst

class ListViewController : UITableViewController
{
    var tableName : String
    var searchOptions : ZCatalystSearchOptions?
    let dataBuilder : CatalystDataBuilder
    var tasks : [ [ String : Any? ] ]?
    var rows : [ ZCatalystRow ]?
    
    init( tableName : String searchOptions : ZCatalystSearchOptions?, dataBuilder : CatalystDataBuilder )
    {
        self.searchOptions = searchOptions
        self.dataBuilder = dataBuilder
        super.init( style : .plain )
        self.getTasks()
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

    // MARK: - Table view data source

    override func numberOfSections( in tableView : UITableView ) -> Int
    {
        return 1
    }

    override func tableView( _ tableView : UITableView, numberOfRowsInSection section : Int ) -> Int
    {
        return tasks.count + 1
    }
    
    override func tableView( _ tableView : UITableView, cellForRowAt indexPath : IndexPath ) -> UITableViewCell
    {
        if indexPath.row == 0
        {
            let cell = AddRowCell.dequeue( self.tableView, indexPath : indexPath, title : "+ Add a Task", cellPadding : self.view.bounds.width * 0.01 )
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell( withIdentifier : "Task", for : indexPath )
            cell.textLabel?.text = tasks[ indexPath.row - 1 ][ "Title" ] as? String
            return cell
        }
    }
    
    override func tableView( _ tableView : UITableView, didSelectRowAt indexPath : IndexPath )
    {
        if let idStr = tasks[ indexPath.row ][ "ROWID" ] as? String, let id = Int64( idStr )
        {
            self.navigationController?.pushViewController( DetailViewController( tableName : "Tasks", rowId : id, dataBuilder : dataBuilder ), animated : true )
        }
        else if let id = tasks[ indexPath.row ][ "ROWID" ] as? Int64
        {
            self.navigationController?.pushViewController( DetailViewController( tableName : "Tasks", rowId : id, dataBuilder : dataBuilder ), animated : true )
        }
    }
    
    // MARK: - Fetch data from Catalyst sdk
    
    func getTasks()
    {
        if let searchOptions = searchOptions
        {
            ZCatalystApp.shared.search( searchOptions : searchOptions ) { ( result ) in
                switch result
                {
                case .success( let result ) :
                    if let tasks = result.output[ "Tasks" ] as? [ [ String : Any ]  ]
                    {
                        self.tasks = tasks
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .error( let error ) :
                    print( "Error occurred >>> \( error )" )
                }
            }
        }
        else
        {
            ZCatalystApp.shared.getDataStoreInstance().getTable( name : "Tasks" ) { ( result ) in
                switch result
                {
                case .success( let table ) :
                    table.getRows { ( rowResult ) in
                        switch rowResult
                        {
                        case .success( let rows ) :
                            for row in rows
                            {
                                self.tasks.append( row.getData() )
                            }
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.dataBuilder.setTask( table : table )
                                self.dataBuilder.setTasks( rows )
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
