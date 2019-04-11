//
//  MyHabitsViewController.swift
//  KokoHabit
//
//  Created by Xiaoyu Liang on 2019/3/17.
//  Copyright © 2019 koko. All rights reserved.
//

import UIKit

class MyHabitsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView! 
    // Phoenix: get selected habit name&point,pass to Edit page,diplay in the placeholder
    var selectedHabitName : String!
    var selectedHabitPoint : String!
    var selectedHabitId : Int!
    
    var isSameDay : Bool!
    
    let dao = DAO()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate.habits.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitCell") as! HabitCell
        
        cell.contentView.layoutMargins.bottom = 20
        cell.layer.cornerRadius = 10
        cell.setHabit(habit: delegate.habits[indexPath.section])
        
        if (delegate.habits[indexPath.section].getCompletion()) {
            cell.setCompletedHabit()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitCell") as! HabitCell
        
        var cellFrame: CGRect = cell.frame
        let percentage = ((100 - Double(delegate.habits[indexPath.section].getHabitValue())) / 100)
        cellFrame.origin.x = 0
        cellFrame.size.width = cell.frame.size.width - (cell.frame.size.width * CGFloat(percentage))
        cell.setPercentageViewFrame(frame: cellFrame)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! HabitCell
        
        let today = Date.init()
        if delegate.habits[indexPath.section].getCompletion() {
            delegate.habits[indexPath.section].setCompletion(completion: false)
            dao.setHabitCompletetionStatus(day: today, habitId: delegate.habits[indexPath.section].getHabitId(), status: 0)
            cell.setUncompletedHabit()
        } else {
            delegate.habits[indexPath.section].setCompletion(completion: true)
            dao.setHabitCompletetionStatus(day: today, habitId: delegate.habits[indexPath.section].getHabitId(), status: 1)
            cell.setCompletedHabit()
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete", handler: {
            action, index in print("Delete button tapped")
            print(self.dao.deleteHabit(habitId: Int32(self.delegate.habits[indexPath.section].getHabitId())))
            self.delegate.habits.remove(at: indexPath.section)
            let indexSet = IndexSet(arrayLiteral: indexPath.section)
            self.tableView.deleteSections(indexSet, with: .none)
        })
        deleteAction.backgroundColor = #colorLiteral(red: 0.7764705882, green: 0.2745098039, blue: 0.2196078431, alpha: 1)
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: {
            ac, view, success in print("Edit button pressed")
            success(true)
            
            // Phoenix: get the current selected habit name and point
            let cell = tableView.cellForRow(at: indexPath) as! HabitCell
            self.selectedHabitName = cell.getHabitName()
            self.selectedHabitPoint = cell.getHabitPoint()
            print("id is: \(self.delegate.habits[indexPath.section].getHabitId())")
            self.selectedHabitId = self.delegate.habits[indexPath.section].getHabitId()
            
            self.performSegue(withIdentifier: "goToEditHabitPage", sender: self)
        })
        editAction.backgroundColor = #colorLiteral(red: 0.831372549, green: 0.8784313725, blue: 0.6078431373, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [editAction])
    }
    
    // Phoenix: pass two values to Edit habit page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditHabitPage"
        {
            let editHabitController = segue.destination as! EditHabitViewController
            editHabitController.oldName = selectedHabitName
            editHabitController.oldPoint = selectedHabitPoint
            editHabitController.habitId = selectedHabitId
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        load()
    }
    
    func load() {
        let today = Date.init()
        
        // if the current week is in the database
        if (dao.checkIfWeekExists(day: today)) {
            
            // if "today" is not in the database
            if (!dao.checkIfDayExists(day: today)){
                dao.insertDay(day: today)
                
                let pointSystem = PointSystem()
                // shuffle the habit points 
                pointSystem.randomPoints(habits: dao.getHabits(day: today))
            }
        // its a new week
        } else {
            // if the user reached their weekly point goal give them a coupon
            if (dao.checkIfUserPassedWeeklyPoints()) {
                dao.insertCoupon()
            }
            // insert new week
            dao.insertWeek(day: today)
            // insert new day
            dao.insertDay(day: today)
        }
        let pointSystem = PointSystem()
        // shuffle the habit points
        pointSystem.randomPoints(habits: dao.getHabits(day: today))
        // get all the active habits
        delegate.habits = dao.getHabits(day: today)
        tableView.reloadData()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func unWindToMyHabitVC(sender: UIStoryboardSegue) {}

}

