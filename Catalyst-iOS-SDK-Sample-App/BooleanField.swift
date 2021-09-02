//
//  BooleanField.swift
//  CatalystTestApp
//
//  Created by Umashri R on 10/09/20.
//  Copyright © 2020 Umashri R. All rights reserved.
//

import UIKit

class BooleanField : UITableViewCell
{
    let background = UIView()
    let uiSwitch = UISwitch()
    let label = UILabel()
    var displayLabel = String()
    var value = false
    var cellPadding : CGFloat = 0
    var rowDataDelegate : RowDataDelegate?
    static var identifier = "BooleanCell"
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected( _ selected : Bool, animated : Bool )
    {
        super.setSelected( selected, animated : animated )
    }
    
    static func dequeue( _ tableView : UITableView, for indexPath : IndexPath, displayLabel : String, value : Bool?, rowDataDelegate : RowDataDelegate?, cellPadding : CGFloat ) -> BooleanField
    {
        let cell = tableView.dequeueReusableCell( withIdentifier : BooleanField.identifier, for : indexPath ) as? BooleanField ?? BooleanField()
        cell.displayLabel = displayLabel
        cell.value = value ?? false
        cell.rowDataDelegate = rowDataDelegate
        if let rowDataDelegate = rowDataDelegate
        {
            let val : Bool? = rowDataDelegate.getRow()?[ displayLabel ]
            cell.value = val ?? false
        }
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
        
        uiSwitch.trailingAnchor.constraint( equalTo : self.contentView.trailingAnchor, constant : -cellPadding ).isActive = true
        uiSwitch.leadingAnchor.constraint( equalTo : background.trailingAnchor, constant : cellPadding ).isActive = true
        uiSwitch.centerYAnchor.constraint( equalTo : self.contentView.centerYAnchor ).isActive = true
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
        
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        if rowDataDelegate == nil
        {
            uiSwitch.isUserInteractionEnabled = false
        }
        else
        {
            uiSwitch.isUserInteractionEnabled = true
        }
        self.contentView.addSubview( uiSwitch )
        if value
        {
            uiSwitch.setOn( true, animated : false )
        }
        else
        {
            uiSwitch.setOn( false, animated : false )
        }
        uiSwitch.addTarget( self, action : #selector( switchChanged( _ : ) ), for: .valueChanged )
        
        setConstraints()
    }
    
    @objc func switchChanged( _ sender : UISwitch )
    {
        if sender.isOn
        {
            rowDataDelegate?.setRowData( for : displayLabel, value : true )
        }
        else
        {
            rowDataDelegate?.setRowData( for : displayLabel, value : false )
        }
    }
}
