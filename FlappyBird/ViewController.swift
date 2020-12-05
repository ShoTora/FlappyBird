//
//  ViewController.swift
//  FlappyBird
//
//  Created by Shotaro Kawaguchi on 2020/10/05.
//  Copyright © 2020 shotaro.kawaguchi. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // SKView
        let skView = self.view as! SKView
        
        // FPS
        skView.showsFPS = true
        
        // showing count of nodes
        skView.showsNodeCount = true
        
        // create scene
        let scene = GameScene(size:skView.frame.size)
        
        // showing scene on view
        skView.presentScene(scene)
    }
    
    // delete status bar
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }


}

