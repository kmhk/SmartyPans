//
//  RecipeCollectionAlertController.swift
//  SmartyPans
//
//  Created by com on 6/21/2019.
//  Copyright © KMHK. All rights reserved.
//

import UIKit

class RecipeCollectionAlertController: UIAlertController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    static func collectionAlert(title: String, okBtnTitle: String, noBtnTitle: String,
                            okHandler: ((UIAlertAction) -> Void)?,
                            noHandler: ((UIAlertAction) -> Void)?) -> RecipeSheetVC {
        let alert = RecipeSheetVC(title: title, message: "", preferredStyle: .alert)
        //actionSheet.view.subviews.last!.subviews.last!.backgroundColor = UIColor.white
        
        alert.addTextField { (textfield) in
            <#code#>
        }
        
//        let okBtn = UIAlertAction(title: okBtnTitle, style: .default, handler: okHandler)
//        okBtn.setValue(UIImage(named: "close-icon")?.withRenderingMode(.alwaysOriginal), forKey: "image")
//        actionSheet.addAction(okBtn)
//
//        let noBtn = UIAlertAction(title: noBtnTitle, style: .default, handler: noHandler)
//        noBtn.setValue(UIImage(named: "close-icon")?.withRenderingMode(.alwaysOriginal), forKey: "image")
//        actionSheet.addAction(noBtn)
        
        return actionSheet
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
