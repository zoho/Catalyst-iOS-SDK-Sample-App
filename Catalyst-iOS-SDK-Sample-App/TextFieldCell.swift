//
//  TextFieldCell.swift
//  CatalystTestApp
//
//  Created by Umashri R on 14/09/20.
//  Copyright © 2020 Umashri R. All rights reserved.
//

import UIKit
import ZCatalyst

class TextFieldCell : UITableViewCell
{
    let background = UIView()
    let textField = UITextField()
    let label = UILabel()
    var column : ZCatalystColumn?
    var value : String?
    var cellPadding : CGFloat = 0
    var rowDataDelegate : RowDataDelegate?
    var dataBuilder : CatalystDataBuilder?
    var pickerValues = [ String ]()
    var indexPath : IndexPath?
    static var identifier = "TextFieldCell"
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected( _ selected : Bool, animated : Bool )
    {
        super.setSelected( selected, animated : animated )
    }
    
    static func dequeue( _ tableView : UITableView, for indexPath : IndexPath, column : ZCatalystColumn, value : String?, rowDataDelegate : RowDataDelegate, dataBuilder : CatalystDataBuilder, cellPadding : CGFloat ) -> TextFieldCell
    {
        let cell = tableView.dequeueReusableCell( withIdentifier : TextFieldCell.identifier, for : indexPath ) as? TextFieldCell ?? TextFieldCell()
        cell.column = column
        cell.value = value
        cell.rowDataDelegate = rowDataDelegate
        cell.dataBuilder = dataBuilder
        cell.indexPath = indexPath
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
        
        textField.trailingAnchor.constraint( equalTo : self.contentView.trailingAnchor, constant : -cellPadding ).isActive = true
        textField.leadingAnchor.constraint( equalTo : background.trailingAnchor, constant : cellPadding ).isActive = true
        textField.centerYAnchor.constraint( equalTo : self.contentView.centerYAnchor ).isActive = true
        
        if let rightView = textField.rightView, let imageView = rightView as? UIImageView
        {
            let height = self.contentView.bounds.height * 0.8
            textField.rightView?.widthAnchor.constraint( equalToConstant : height ).isActive = true
            
            imageView.topAnchor.constraint( equalTo : rightView.topAnchor ).isActive = true
            imageView.bottomAnchor.constraint( equalTo : rightView.bottomAnchor ).isActive = true
            imageView.trailingAnchor.constraint( equalTo : rightView.trailingAnchor ).isActive = true
            imageView.leadingAnchor.constraint( equalTo : rightView.leadingAnchor ).isActive = true
        }
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
        
        if let column = column
        {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = column.name
            label.font = UIFont.systemFont( ofSize : 14 )
            if column.isMandatory == true
            {
                label.textColor = .systemRed
            }
            else
            {
                label.textColor = .systemGray
            }
            label.textAlignment = .right
            background.addSubview( label )
            
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.isUserInteractionEnabled = true
            textField.delegate = self
            let value : String? = rowDataDelegate?.getRow()?[ column.name ]
            textField.text = value
            textField.font = UIFont.systemFont( ofSize : 14 )
            textField.textAlignment = .left
            textField.rightView = nil
            textField.inputView = nil
            self.contentView.addSubview( textField )
            customizeTextField()
        }
        
        setConstraints()
    }
    
    func customizeTextField()
    {
        if let column = column
        {
            switch column.dataType
            {
            case .text, .varchar :
                if column.name != "Priority"
                {
                    textField.keyboardType = .default
                }
                else
                {
                    pickerValues = [ "Low", "Medium", "High" ]
                    let arrow = UIImageView( image : UIImage( named : "DownArrow" ) )
                    arrow.contentMode = .scaleAspectFit
                    arrow.translatesAutoresizingMaskIntoConstraints = false
                    
                    textField.rightView = arrow
                    textField.rightViewMode = .always
                }
                
            case .date, .datetime :
                let arrow = UIImageView( image : UIImage( named : "DownArrow" ) )
                arrow.contentMode = .scaleAspectFit
                arrow.translatesAutoresizingMaskIntoConstraints = false
                
                textField.rightView = arrow
                textField.rightViewMode = .always
                
            case .int, .bigint :
                textField.keyboardType = .numberPad
                
            case .double :
                textField.keyboardType = .decimalPad
                
            case .foreignKey :
                let arrow = UIImageView( image : UIImage( named : "RightArrow" ) )
                arrow.contentMode = .scaleAspectFit
                arrow.translatesAutoresizingMaskIntoConstraints = false
                
                textField.rightView = arrow
                textField.rightViewMode = .always
                
            default :
                print( "Type not supported" )
            }
        }
    }
}

extension TextFieldCell : UITextFieldDelegate
{
    func getDatePickerView() -> UIDatePicker
    {
        let datePickerView = UIDatePicker()
        if column?.dataType == ZCatalystColumn.DataType.date
        {
            datePickerView.datePickerMode = .date
        }
        else
        {
            datePickerView.datePickerMode = .dateAndTime
        }
        datePickerView.calendar = .autoupdatingCurrent
        if #available( iOS 13.0, * )
        {
            datePickerView.backgroundColor = .systemBackground
        }
        else
        {
            datePickerView.backgroundColor = .white
        }
        datePickerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview( datePickerView )
        
        datePickerView.addTarget( self, action : #selector( handleDatePickerEvent( _ : ) ), for : .valueChanged )
        
        datePickerView.leadingAnchor.constraint( equalTo : self.leadingAnchor ).isActive = true
        datePickerView.trailingAnchor.constraint( equalTo : self.trailingAnchor ).isActive = true
        datePickerView.bottomAnchor.constraint( equalTo : self.bottomAnchor ).isActive = true
        datePickerView.widthAnchor.constraint( equalTo : self.widthAnchor ).isActive = true
        datePickerView.autoresizingMask = .flexibleHeight
        
        return datePickerView
    }
    
    func getPickerView() -> UIPickerView
    {
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        if #available( iOS 13.0, * )
        {
            pickerView.backgroundColor = .systemBackground
        }
        else
        {
            pickerView.backgroundColor = .white
        }
        pickerView.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview( pickerView )
        
        pickerView.leadingAnchor.constraint( equalTo : self.leadingAnchor ).isActive = true
        pickerView.trailingAnchor.constraint( equalTo : self.trailingAnchor ).isActive = true
        pickerView.bottomAnchor.constraint( equalTo : self.bottomAnchor ).isActive = true
        pickerView.widthAnchor.constraint( equalTo : self.widthAnchor ).isActive = true
        pickerView.autoresizingMask = .flexibleHeight
        
        return pickerView
    }
    
    func getToolBar() -> UIToolbar
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        if #available( iOS 13.0, * )
        {
            toolBar.backgroundColor = .tertiarySystemGroupedBackground
        }
        else
        {
            toolBar.backgroundColor = .clear
        }
        toolBar.sizeToFit()
        
        let clearButton = UIBarButtonItem( title : "Clear", style : .plain, target : self, action : #selector( clear ) )
        let spaceButton = UIBarButtonItem( barButtonSystemItem : .flexibleSpace, target : nil, action : nil )
        let doneButton = UIBarButtonItem( title : "Done", style : .done, target : self, action : #selector( done ) )
        toolBar.setItems( [ clearButton, spaceButton, doneButton ], animated : false )
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
    @objc func clear( _ sender : UIDatePicker )
    {
        if let column = column
        {
            self.textField.text = nil
            rowDataDelegate?.setRowData( for : column.name, value : nil )
        }
        
    }
    
    @objc func done( _ sender : AnyObject )
    {
        self.endEditing( true )
    }
    
    @objc func handleDatePickerEvent( _ sender : UIDatePicker )
    {
        if let column = column
        {
            if column.dataType == ZCatalystColumn.DataType.date
            {
                textField.text = sender.date.date
                rowDataDelegate?.setRowData( for : column.name, value : sender.date.iso8601 )
            }
            else if column.dataType == ZCatalystColumn.DataType.datetime
            {
                textField.text = sender.date.dateTime
                rowDataDelegate?.setRowData( for : column.name, value : sender.date.iso8601WithTimeZone )
            }
            else
            {
                print( "DateFormat did not match" )
            }
        }
    }
    
    func textFieldDidBeginEditing( _ textField : UITextField )
    {
        if let tableView = self.superview as? UITableView, let indexPath = indexPath
        {
            tableView.scrollToRow( at : indexPath, at : .middle, animated : true )
            tableView.isScrollEnabled = false
        }
        if let column = column
        {
            if column.name == "Priority"
            {
                let pickerView = getPickerView()
                pickerView.removeFromSuperview()
                textField.inputView = pickerView
                if let text = textField.text, !text.isEmpty
                {
                    for index in 0..<pickerValues.count
                    {
                        if pickerValues[ index ] == text
                        {
                            pickerView.selectRow( index, inComponent : 0, animated : true )
                        }
                    }
                }
                else
                {
                    textField.text = pickerValues[ pickerView.selectedRow( inComponent : 0 ) ]
                }
                
                let toolBar = getToolBar()
                textField.inputAccessoryView = toolBar
            }
            if column.dataType == ZCatalystColumn.DataType.foreignKey, let builder = dataBuilder
            {
                self.endEditing( true )
                let controller = ListViewController( tableName : "Projects", searchOptions : nil, dataBuilder : builder )
                controller.textField = textField
                textField.resignFirstResponder()
                controller.displayLabel = column.name
                controller.rowDataDelegate = rowDataDelegate
                textField.inputView = controller.tableView
                ( getCurrentViewController() as? UINavigationController )?.pushViewController( controller, animated : true )
            }
            else if column.dataType == ZCatalystColumn.DataType.date
            {
                let datePickerView = getDatePickerView()
                datePickerView.removeFromSuperview()
                textField.inputView = datePickerView
                if let text = textField.text, !text.isEmpty, let date = text.date
                {
                    datePickerView.setDate( date, animated : true )
                }
                else
                {
                    datePickerView.setDate( Date(), animated : true )
                    textField.text = Date().date
                }
                
                let toolBar = getToolBar()
                textField.inputAccessoryView = toolBar
            }
            else if column.dataType == ZCatalystColumn.DataType.datetime
            {
                let datePickerView = getDatePickerView()
                datePickerView.removeFromSuperview()
                textField.inputView = datePickerView
                if let text = textField.text, !text.isEmpty, let date = text.dateTime
                {
                    datePickerView.setDate( date, animated : true )
                }
                else
                {
                    datePickerView.setDate( Date(), animated : true )
                    textField.text = Date().dateTime
                }
                
                let toolBar = getToolBar()
                textField.inputAccessoryView = toolBar
            }
        }
    }
    
    func textFieldDidEndEditing( _ textField : UITextField )
    {
        self.endEditing( true )
        if let tableView = self.superview as? UITableView
        {
            tableView.contentInset = .zero
            tableView.scrollIndicatorInsets = .zero
            tableView.isScrollEnabled = true
        }
        if let column = column
        {
            if column.dataType != ZCatalystColumn.DataType.date && column.dataType != ZCatalystColumn.DataType.datetime && column.dataType != ZCatalystColumn.DataType.foreignKey
            {
                rowDataDelegate?.setRowData( for : column.name, value : textField.text )
            }
            textField.inputView = nil
        }
    }
}

extension TextFieldCell : UIPickerViewDataSource
{
    func numberOfComponents( in pickerView : UIPickerView ) -> Int
    {
        return 1
    }
    
    func pickerView( _ pickerView : UIPickerView, numberOfRowsInComponent component : Int ) -> Int
    {
        return pickerValues.count
    }
}

extension TextFieldCell : UIPickerViewDelegate
{
    func pickerView( _ pickerView : UIPickerView, titleForRow row : Int, forComponent component : Int ) -> String?
    {
        return pickerValues[ row ]
    }
    
    func pickerView( _ pickerView : UIPickerView, didSelectRow row : Int, inComponent component : Int )
    {
        if let column = column
        {
            textField.text = pickerValues[ row ]
            rowDataDelegate?.setRowData( for : column.name, value : pickerValues[ row ] )
        }
    }
}
