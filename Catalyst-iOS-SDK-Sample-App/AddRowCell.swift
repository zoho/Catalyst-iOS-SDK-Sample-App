//
//  AddARowCell.swift
//  CatalystTestApp
//
//  Created by Umashri R on 11/09/20.
//  Copyright © 2020 Umashri R. All rights reserved.
//

import UIKit

class AddRowCell : UITableViewCell
{
    let button = UIButton()
    let cellPadding : CGFloat = 0
    var dataBuilder : CatalystDataBuilder?
    var tableName : String?
    static let identifier = "AddARowCell"

    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected( _ selected : Bool, animated : Bool )
    {
        super.setSelected( selected, animated : animated )
        // Configure the view for the selected state
    }
    
    static func dequeue( _ tableView : UITableView, indexPath : IndexPath, title : String, tableName : String, dataBuilder : CatalystDataBuilder, cellPadding : CGFloat ) -> AddRowCell
    {
        let cell = tableView.dequeueReusableCell( withIdentifier : AddRowCell.identifier, for : indexPath ) as? AddRowCell ?? AddRowCell()
        cell.tableName = tableName
        cell.dataBuilder = dataBuilder
        cell.constructCell()
        cell.button.setTitle( title, for : .normal )
        return cell
    }
    
    func setConstraints()
    {
        button.leadingAnchor.constraint( equalTo : self.contentView.leadingAnchor, constant : cellPadding ).isActive = true
        button.trailingAnchor.constraint( equalTo : self.contentView.trailingAnchor, constant : cellPadding ).isActive = true
        button.topAnchor.constraint( equalTo : self.contentView.topAnchor, constant : cellPadding ).isActive = true
        button.bottomAnchor.constraint( equalTo : self.contentView.bottomAnchor, constant : cellPadding ).isActive = true
    }
    
    func constructCell()
    {
        for subview in self.contentView.subviews
        {
            subview.removeFromSuperview()
        }
        
        self.contentView.addSubview( button )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor( .systemBlue, for : .normal )
        button.addTarget( self, action : #selector( navigate ), for : .touchUpInside )
        setConstraints()
    }
    
    @objc func navigate()
    {
        if let dataBuilder = dataBuilder, let tableName = tableName
        {
            ( getCurrentViewController() as? UINavigationController )?.pushViewController( CreateController( tableName : tableName, row : nil, dataBuilder : dataBuilder ), animated : true )
        }
    }
}
