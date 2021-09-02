//
//  ForeignKeyField.swift
//  CatalystTestApp
//
//  Created by Umashri R on 10/09/20.
//  Copyright © 2020 Umashri R. All rights reserved.
//

import UIKit
import ZCatalyst

class ForeignKeyField : UITableViewCell
{
    let background = UIView()
    let button = UIButton()
    let label = UILabel()
    var displayLabel = String()
    var value : String?
    var row : ZCatalystRow?
    var cellPadding : CGFloat = 0
    var dataBuilder : CatalystDataBuilder?
    static var identifier = "ForeignKeyCell"
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected( _ selected : Bool, animated : Bool )
    {
        super.setSelected( selected, animated : animated )
    }
    
    static func dequeue( _ tableView : UITableView, for indexPath : IndexPath, displayLabel : String, value : String?, row : ZCatalystRow?, dataBuilder : CatalystDataBuilder, cellPadding : CGFloat ) -> ForeignKeyField
    {
        let cell = tableView.dequeueReusableCell( withIdentifier : BooleanField.identifier, for : indexPath ) as? ForeignKeyField ?? ForeignKeyField()
        cell.displayLabel = displayLabel
        cell.value = value
        cell.row = row
        cell.dataBuilder = dataBuilder
        cell.cellPadding = cellPadding
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
        button.setTitle( value, for : .normal )
        button.setTitleColor( .systemBlue, for : .normal )
        button.addTarget( self, action : #selector( navigate ), for : .touchUpInside )
        self.contentView.addSubview( button )
        
        setConstraints()
    }
    
    @objc func navigate()
    {
        if let id = row?.id, let builder = dataBuilder
        {
            ( getCurrentViewController() as? UINavigationController )?.view.endEditing( true )
            ( getCurrentViewController() as? UINavigationController )?.pushViewController( DetailViewController( tableName : "Projects", rowId : id, dataBuilder : builder ), animated : true )
        }
    }
}
