//
//  Field.swift
//  CatalystTestApp
//
//  Created by Umashri R on 09/09/20.
//  Copyright © 2020 Umashri R. All rights reserved.
//

import UIKit

class Field : UITableViewCell
{
    let background = UIView()
    let valueLabel = UILabel()
    let label = UILabel()
    var displayLabel = String()
    var value : String?
    var cellPadding : CGFloat = 0
    static var identifier = "FieldCell"
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected( _ selected : Bool, animated : Bool )
    {
        super.setSelected( selected, animated : animated )
    }
    
    static func dequeue( _ tableView : UITableView, for indexPath : IndexPath, displayLabel : String, value : String?, cellPadding : CGFloat ) -> Field
    {
        let cell = tableView.dequeueReusableCell( withIdentifier : Field.identifier, for : indexPath ) as? Field ?? Field()
        cell.displayLabel = displayLabel
        cell.value = value
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
        
        valueLabel.trailingAnchor.constraint( equalTo : self.contentView.trailingAnchor, constant : -cellPadding ).isActive = true
        valueLabel.leadingAnchor.constraint( equalTo : background.trailingAnchor, constant : cellPadding ).isActive = true
        valueLabel.centerYAnchor.constraint( equalTo : self.contentView.centerYAnchor ).isActive = true
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
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont( ofSize : 14 )
        valueLabel.textColor = .systemGray
        valueLabel.textAlignment = .left
        self.contentView.addSubview( valueLabel )
        
        setConstraints()
    }
}
