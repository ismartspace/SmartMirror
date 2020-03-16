//
//  MeasurementTableViewCell.swift
//  SmartMirror
//
//  Created by Jiwoo Lim on 2020-03-14.
//  Copyright © 2020 Team 2019053. All rights reserved.
//

import UIKit

class MeasurementTableViewCell : UITableViewCell {

    let nameLabel:UILabel = {
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
    }()
    
    let measurementLabel:UILabel = {
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 23)
        label.textColor = .white
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(measurementLabel)
        nameLabel.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:20).isActive = true
        measurementLabel.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        measurementLabel.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-20).isActive = true
     }
    
     required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
}
