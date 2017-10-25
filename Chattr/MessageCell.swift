//
//  MessageCell.swift
//  Chattr
//
//  Created by Neo Ighodaro on 25/10/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit
import SlackTextViewController


struct Message {
    var id: Int!
    var username: String!
    var text: String!
}


class MessageCell: UITableViewCell {
    
    static let kMessageTableViewCellMinimumHeight: CGFloat = 50.0;
    static let kMessageTableViewCellAvatarHeight: CGFloat = 30.0;
    
    static let MessengerCellIdentifier: String = "MessengerCell";
    static let AutoCompletionCellIdentifier: String = "AutoCompletionCell";
    
    var _titleLabel: UILabel?
    var _bodyLabel: UILabel?
    var _thumbnailView: UIImageView?
    
    var indexPath: IndexPath?
    var usedForMessage: Bool?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = UIColor.white
        
        configureSubviews()
    }
    
    func configureSubviews() {
        contentView.addSubview(thumbnailView())
        contentView.addSubview(titleLabel())
        contentView.addSubview(bodyLabel())
        
        let views: [String:Any] = [
            "thumbnailView": thumbnailView(),
            "titleLabel": titleLabel(),
            "bodyLabel": bodyLabel()
        ]
        
        let metrics = [
            "tumbSize": MessageCell.kMessageTableViewCellAvatarHeight,
            "padding": 15,
            "right": 10,
            "left": 5
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-left-[thumbnailView(tumbSize)]-right-[titleLabel(>=0)]-right-|",
            options: [],
            metrics: metrics,
            views: views
        ))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-left-[thumbnailView(tumbSize)]-right-[bodyLabel(>=0)]-right-|",
            options: [],
            metrics: metrics,
            views: views
        ))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-right-[thumbnailView(tumbSize)]-(>=0)-|",
            options: [],
            metrics: metrics,
            views: views
        ))
        
        if (reuseIdentifier == MessageCell.MessengerCellIdentifier) {
            contentView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-right-[titleLabel(20)]-left-[bodyLabel(>=0@999)]-left-|",
                options: [],
                metrics: metrics,
                views: views
            ))
        }
        else {
            contentView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[titleLabel]|",
                options: [],
                metrics: metrics,
                views: views
            ))
        }
    }
    
    // MARK: Getters
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        selectionStyle = .none
        
        let pointSize: CGFloat = MessageCell.defaultFontSize()
        
        titleLabel().font = UIFont.boldSystemFont(ofSize: pointSize)
        bodyLabel().font = UIFont.systemFont(ofSize: pointSize)
        titleLabel().text = ""
        bodyLabel().text = ""
    }
    
    func titleLabel() -> UILabel {
        if _titleLabel == nil {
            _titleLabel = UILabel()
            _titleLabel?.translatesAutoresizingMaskIntoConstraints = false
            _titleLabel?.backgroundColor = UIColor.clear
            _titleLabel?.isUserInteractionEnabled = false
            _titleLabel?.numberOfLines = 0
            _titleLabel?.textColor = UIColor.gray
            _titleLabel?.font = UIFont.boldSystemFont(ofSize: MessageCell.defaultFontSize())
        }
        
        return _titleLabel!
    }
    
    func bodyLabel() -> UILabel {
        if _bodyLabel == nil {
            _bodyLabel = UILabel()
            _bodyLabel?.translatesAutoresizingMaskIntoConstraints = false
            _bodyLabel?.backgroundColor = UIColor.clear
            _bodyLabel?.isUserInteractionEnabled = false
            _bodyLabel?.numberOfLines = 0
            _bodyLabel?.textColor = UIColor.darkGray
            _bodyLabel?.font = UIFont.systemFont(ofSize: MessageCell.defaultFontSize())
        }
        
        return _bodyLabel!
    }
    
    func thumbnailView() -> UIImageView {
        if _thumbnailView == nil {
            _thumbnailView = UIImageView()
            _thumbnailView?.translatesAutoresizingMaskIntoConstraints = false
            _thumbnailView?.isUserInteractionEnabled = false
            _thumbnailView?.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            _thumbnailView?.layer.cornerRadius = MessageCell.kMessageTableViewCellAvatarHeight / 2.0
            _thumbnailView?.layer.masksToBounds = true
        }
        
        return _thumbnailView!
    }
    
    class func defaultFontSize() -> CGFloat {
        var pointSize: CGFloat = 16.0
        
        let contentSizeCategory: String = String(describing: UIApplication.shared.preferredContentSizeCategory)
        pointSize += SLKPointSizeDifferenceForCategory(contentSizeCategory)
        
        return pointSize
    }
}
