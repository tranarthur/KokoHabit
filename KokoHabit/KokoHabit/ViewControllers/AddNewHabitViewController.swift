//
//  AddNewHabitViewController.swift
//  KokoHabit
//
//  Created by 葛青 on 3/19/19.
//  Copyright © 2019 koko. All rights reserved.
//

import UIKit

class AddNewHabitViewController: UIViewController {

    @IBOutlet var habitName: UITextField!
    @IBOutlet var habitPoint: UITextField!
    
    
    @IBAction func createHabit(sender:UIButton) {
        let mainDelegate = UIApplication.shared.delegate as! AppDelegate
        let dao = DAO()
        
        print(dao.addHabit(email: mainDelegate.user.getEmail() as NSString, pointValue: Int32(habitPoint.text!)!, name: habitName.text! as NSString))
        
        dismiss(animated: true, completion: nil)
        
        //Alert incase not inserted or error.. or alert to send them to the login page
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
