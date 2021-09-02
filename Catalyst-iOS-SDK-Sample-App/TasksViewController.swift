//
//  TasksViewController.swift
//  CatalystTestApp
//
//  Created by Umashri R on 04/09/20.
//  Copyright © 2020 Umashri R. All rights reserved.
//

import UIKit
import Catalyst

class TasksListViewController : UITableViewController
{
    var searchOptions : ZCatalystSearchOptions?
    var tasks = [ String? ]()
    
    init( searchOptions : ZCatalystSearchOptions? )
    {
        self.searchOptions = searchOptions
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
    }

    // MARK: - Table view data source

    override func numberOfSections( in tableView : UITableView ) -> Int
    {
        return 1
    }

    override func tableView( _ tableView : UITableView, numberOfRowsInSection section : Int ) -> Int
    {
        return tasks.count
    }
    
    override func tableView( _ tableView : UITableView, cellForRowAt indexPath : IndexPath ) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell( withIdentifier : "Task", for : indexPath )
        cell.textLabel?.text = tasks[ indexPath.row ]
        return cell
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
                    let tasks = result.output[ "Tasks" ] as? [ [ String : Any ]  ]
                    if let tasks = tasks
                    {
                        for task in tasks
                        {
                            self.tasks.append( task[ "Title" ] as? String )
                        }
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
                                self.tasks.append( row.getValue( forKey : "Title" ) )
                            }
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
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
