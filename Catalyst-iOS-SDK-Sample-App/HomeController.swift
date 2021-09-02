//
//  HomeController.swift
//  CatalystTestApp
//
//  Created by Umashri R on 03/09/20.
//  Copyright © 2020 Umashri R. All rights reserved.
//

import UIKit
import ZCatalyst

class HomeController : UITableViewController
{
    static let cellIdentifier = "tableViewCell"
    var tasksFrom = [ "All Tasks", "Today", "High Priority" ]
    var dataBuilder = CatalystDataBuilder()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !ZCatalystApp.shared.isUserSignedIn()
        {
            ZCatalystApp.shared.showLogin { ( error ) in
                if let error = error
                {
                    print( "Error occurred in login. Error >> \( error )" )
                }
                else
                {
                    self.getProjects()
                }
            }
        }
        else
        {
            getProjects()
        }
        tableView.register( UITableViewCell.self, forCellReuseIdentifier : HomeController.cellIdentifier )
        self.tableView.register( AddRowCell.self, forCellReuseIdentifier : AddRowCell.identifier )
        tableView.tableFooterView = nil
        
        let logoutButton = UIBarButtonItem( title : "Logout", style : .plain, target : self, action : #selector( logout ) )
        self.navigationItem.setRightBarButton( logoutButton, animated : true )
        self.navigationItem.title = "Todo"
    }

    // MARK: - Table view data source

    override func numberOfSections( in tableView : UITableView ) -> Int
    {
        return 2
    }

    override func tableView( _ tableView : UITableView, numberOfRowsInSection section : Int ) -> Int
    {
        if section == 0
        {
            return tasksFrom.count
        }
        else
        {
            if let projects = dataBuilder.getData().getProjects()
            {
                return projects.count + 1
            }
            return 0
        }
    }
    
    override func tableView( _ tableView : UITableView, cellForRowAt indexPath : IndexPath ) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell( withIdentifier : HomeController.cellIdentifier, for : indexPath )
        if indexPath.section == 0
        {
            cell.textLabel?.text = tasksFrom[ indexPath.row ]
        }
        else
        {
            if indexPath.row == 0
            {
                let addRow = AddRowCell.dequeue( self.tableView, indexPath : indexPath, title : "+ Add a Project", tableName : "Projects", dataBuilder : dataBuilder, cellPadding : self.view.bounds.width * 0.01 )
                return addRow
            }
            else
            {
                if let projects = dataBuilder.getData().getProjects()
                {
                    cell.textLabel?.text = projects[ indexPath.row - 1 ][ "Title" ]
                }
            }
        }
        return cell
    }
    
    override func tableView( _ tableView : UITableView, titleForHeaderInSection section : Int ) -> String?
    {
        if section == 0
        {
            return "Tasks"
        }
        else
        {
            return "Projects"
        }
    }
    
    override func tableView( _ tableView : UITableView, didSelectRowAt indexPath : IndexPath )
    {
        let controller = ListViewController( tableName : "Tasks", searchOptions : constructSearchOption( indexPath : indexPath ), dataBuilder : dataBuilder )
        self.navigationController?.pushViewController( controller, animated : true )
    }
    
    // MARK: - Fetch data from Catalyst sdk
    
    func getProjects()
    {
        ZCatalystApp.shared.getDataStoreInstance().getTable( name : "Projects") { ( result ) in
            switch result
            {
            case .success( let table ) :
                self.dataBuilder.setProject( table : table )
                table.getRows { ( rowsResult ) in
                    switch rowsResult
                    {
                    case .success( let rows ) :
                        self.dataBuilder.setProjects( rows )
                        DispatchQueue.main.async {
                            self.tableView.reloadSections( [ 1 ], with : .none )
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
    
    //MARK: - Utility functions
    
    func constructSearchOption( indexPath : IndexPath ) -> ZCatalystSearchOptions?
    {
        if indexPath.section == 0
        {
            if tasksFrom[ indexPath.row ] == "Today"
            {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                var searchColumns = ZCatalystSearchOptions.TableColumns( tableName : "Tasks" )
                searchColumns.add( column : "DueDate" )
                var searchOptions = ZCatalystSearchOptions( searchText : dateFormatter.string( from : Date() ), searchColumns: [  searchColumns ] )
                var displayColumns = ZCatalystSearchOptions.TableColumns( tableName : "Tasks" )
                displayColumns.add( column : "Title" )
                searchOptions.add( displayColumns : displayColumns )
                return searchOptions
            }
            else if tasksFrom[ indexPath.row ] == "Next 7 days"
            {
                var searchColumns = ZCatalystSearchOptions.TableColumns( tableName : "Tasks" )
                searchColumns.add( column : "DueDate" )
                var searchOptions = ZCatalystSearchOptions( searchText : "2020-09-07 20:00:00", searchColumns: [  searchColumns ] )
                var displayColumns = ZCatalystSearchOptions.TableColumns( tableName : "Tasks" )
                displayColumns.add( column : "Title" )
                searchOptions.add( displayColumns : displayColumns )
                return searchOptions
            }
            else if tasksFrom[ indexPath.row ] == "High Priority"
            {
                var searchColumns = ZCatalystSearchOptions.TableColumns( tableName : "Tasks" )
                searchColumns.add( column : "Priority" )
                var searchOptions = ZCatalystSearchOptions( searchText : "High", searchColumns: [  searchColumns ] )
                var displayColumns = ZCatalystSearchOptions.TableColumns( tableName : "Tasks" )
                displayColumns.add( column : "Title" )
                searchOptions.add( displayColumns : displayColumns )
                return searchOptions
            }
            return nil
        }
        else
        {
            if let projects = dataBuilder.getData().getProjects(), let projectId : String = projects[ indexPath.row - 1 ].getValue( forKey : "ROWID" )
            {
                var searchColumns = ZCatalystSearchOptions.TableColumns( tableName : "Tasks" )
                searchColumns.add( column : "ProjectId" )
                var searchOptions = ZCatalystSearchOptions( searchText : projectId, searchColumns: [  searchColumns ] )
                var displayColumns = ZCatalystSearchOptions.TableColumns( tableName : "Tasks" )
                displayColumns.add( column : "Title" )
                searchOptions.add( displayColumns : displayColumns )
                return searchOptions
            }
            return nil
        }
    }
    
    @objc func logout()
    {
        ZCatalystApp.shared.logout { ( error ) in
            if let error = error
            {
                print( "Error occurred while logging out >>> \( error )" )
            }
            else
            {
                print( "User logged out successfully..." )
                self.dataBuilder = CatalystDataBuilder()
                self.tableView.reloadData()
                ZCatalystApp.shared.showLogin { ( error ) in
                    if let error = error
                    {
                        print( "Error occurred in login. Error >> \( error )" )
                    }
                    else
                    {
                        self.getProjects()
                    }
                }
            }
        }
    }
}

protocol Builder
{
    func setProjects( _ projects : [ ZCatalystRow ] )
    
    func setProject( table : ZCatalystTable )
    
    func setTasks( _ tasks : [ ZCatalystRow ] )
    
    func setTask( table : ZCatalystTable )
    
    func setColumns( _ columns : [ ZCatalystColumn ], for table : ZCatalystTable )
    
    func addFilePath( for id : Int64, path : URL )
}

class CatalystDataBuilder : Builder
{
    private var data = CatalystData()
    
    func getData() -> CatalystData
    {
        return data
    }
    
    func setProjects( _ projects : [ ZCatalystRow ] )
    {
        data.setProjects( projects )
    }
    
    func setProject( table : ZCatalystTable )
    {
        data.setProject( table : table )
    }
    
    func setTasks( _ tasks : [ ZCatalystRow ] )
    {
        data.setTasks( tasks )
    }
    
    func setTask( table : ZCatalystTable )
    {
        data.setTask( table : table )
    }
    
    func setColumns( _ columns : [ ZCatalystColumn ], for table : ZCatalystTable )
    {
        data.setColumns( columns, for : table )
    }
    
    func setFolder( folder : ZCatalystFolder )
    {
        data.setFolder( folder : folder )
    }
    
    func addFile( _ file : ZCatalystFile )
    {
        data.addFile( file )
    }
    
    func addFilePath( for id : Int64, path : URL )
    {
        data.addFilePath( for : id, path : path )
    }
}

struct CatalystData
{
    private var projects : [ ZCatalystRow ]?
    private var tasks : [ ZCatalystRow ]?
    private var project : ZCatalystTable?
    private var task : ZCatalystTable?
    private var projectsColumn : [ ZCatalystColumn ]?
    private var tasksColumn : [ ZCatalystColumn ]?
    private var folder : ZCatalystFolder?
    private var files : [ ZCatalystFile ]?
    private var filePaths : [ Int64 : URL ]?
    
    mutating func setProjects( _ projects : [ ZCatalystRow ] )
    {
        self.projects = projects
    }
    
    mutating func setProject( table : ZCatalystTable )
    {
        self.project = table
    }
    
    mutating func setTasks( _ tasks : [ ZCatalystRow ] )
    {
        self.tasks = tasks
    }
    
    mutating func setTask( table : ZCatalystTable )
    {
        self.task = table
    }
    
    mutating func setColumns( _ columns : [ ZCatalystColumn ], for table : ZCatalystTable )
    {
        if table.name == "Tasks"
        {
            self.task = table
            self.tasksColumn = columns
        }
        else if table.name == "Projects"
        {
            self.project = table
            self.projectsColumn = columns
        }
    }
    
    mutating func setFolder( folder : ZCatalystFolder )
    {
        self.folder = folder
    }
    
    mutating func addFile( _ file : ZCatalystFile )
    {
        if self.files == nil
        {
            self.files = [ ZCatalystFile ]()
        }
        self.files?.append( file )
    }
    
    mutating func addFilePath( for id : Int64, path : URL )
    {
        if self.filePaths == nil
        {
            self.filePaths = [ Int64 : URL ]()
        }
        self.filePaths?.updateValue( path, forKey : id )
    }
    
    func getProject() -> ZCatalystTable?
    {
        return project
    }
    
    func getTask() -> ZCatalystTable?
    {
        return task
    }
    
    func getProjects() -> [ ZCatalystRow ]?
    {
        return projects
    }
    
    func getTasks() -> [ ZCatalystRow ]?
    {
        return tasks
    }
    
    func getProjectColumns() -> [ ZCatalystColumn ]?
    {
        return projectsColumn
    }
    
    func getTaskColumns() -> [ ZCatalystColumn ]?
    {
        return tasksColumn
    }
    
    func getFolder() -> ZCatalystFolder?
    {
        return folder
    }
    
    func getFile( id : Int64 ) -> ZCatalystFile?
    {
        if let files = files
        {
            for file in files
            {
                if file.id == id
                {
                    return file
                }
            }
        }
        return nil
    }
    
    func getFilePath( for id : Int64 ) -> URL?
    {
        return self.filePaths?[ id ]
    }
}

func getCurrentViewController() -> UIViewController?
{
    let window = UIApplication.shared.windows.first { $0.isKeyWindow }
    if let rootController = window?.rootViewController
    {
        var currentController : UIViewController! = rootController
        while( currentController.presentedViewController != nil )
        {
            currentController = currentController.presentedViewController
        }
        return currentController
    }
    return nil
}


