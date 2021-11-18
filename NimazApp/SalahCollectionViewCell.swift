//
//  SalahCollectionViewCell.swift
//  NimazApp
//
//  Created by apple on 18/10/2021.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit

class SalahCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Time: UILabel!
//    func configure(with n: Nimaz){
//        Name.text = n.Nimaz_Name
//       // Time.text = n.Nimaz_Time
//    }
    func configure(with n: Nimaz){
        Name.text = n.Nimaz_Name
        Time.text = n.Nimaz_Time
    }
    override func layoutSubviews() {
        
        //rounded image
 
        
        // cell rounded section
        self.layer.cornerRadius = 15.0
        self.layer.borderWidth = 5.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
        
        // cell shadow section
        self.layer.cornerRadius = 15.0
        self.layer.borderWidth = 0.0
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 1
        self.layer.masksToBounds = false
    }
}
