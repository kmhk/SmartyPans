//
//  PanPairVC.swift
//  SmartyPans
//
//  Created by Lucky on 2018/8/1.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import Pulsator

class PanPairVC: UIViewController {
    @IBOutlet weak var imgLogo: UIImageView!
    //var halo : PulsingHaloLayer!
    
    let pulsator = Pulsator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imgLogo.layer.superlayer?.insertSublayer(pulsator, below: imgLogo.layer)
        setupInitialValues()
        pulsator.start()
    }

    private func setupInitialValues() {
        pulsator.numPulse = 5
        pulsator.radius = 200
        pulsator.animationDuration = 5
        pulsator.backgroundColor = UIColor.white.cgColor
        pulsator.position = imgLogo.layer.position
        
    }
    override func viewDidLayoutSubviews() {
        //
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClose(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onFound(_ sender: Any) {
        performSegue(withIdentifier: "segueFound", sender: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
