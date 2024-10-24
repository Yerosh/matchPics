//
//  ViewController.swift
//  matchPics
//
//  Created by Yernur Adilbek on 10/24/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var movesLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    
    var images = ["1", "2", "3", "4", "5", "6", "7", "8", "1", "2", "3", "4", "5", "6", "7", "8"]
    
    var state = [Int](repeating: 0, count: 16)
    
    var winstate = [[0,8], [1,9], [2,10], [3,11], [4,12], [5,13], [6,14], [7,15]]

    var isActive = false
    
    var timer = Timer()
    var isTimeRunning = false
    var time = 0
    
    var moves = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        shuffleImages()
    }
    

    @IBAction func game(_ sender: UIButton) {
        
        if !isTimeRunning {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countTime), userInfo: nil, repeats: true)
            isTimeRunning = true
        }
        
        if state[sender.tag - 1] != 0 || isActive{
            return
        }
        
        moves += 1
        movesLabel.text = "Moves: \(moves)"
        
        sender.setBackgroundImage(UIImage(named: images[sender.tag - 1]), for: .normal)
        
        state[sender.tag - 1] = 1
        
        var count = 0
        
        
        for item in state {
            if item == 1 {
                count += 1
            }
        }
        
        if count == 2 {
            isActive = true
            for winArray in winstate {
                if state[winArray[0]] == state[winArray[1]] && state[winArray[1]] == 1 {
                    state[winArray[0]] = 2
                    state[winArray[1]] = 2
                    isActive = false
                }
            }
            if isActive {
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector (clear), userInfo: nil, repeats: false)
            }
        }
        
        if isGameFinished() {
            let currentRecord = Record(moves: moves, time: time)
            
            do {
                if let savedData = UserDefaults.standard.data(forKey: "records") {
                    var oldRecord = try JSONDecoder().decode(Record.self, from: savedData)
                    if oldRecord.time > time || (oldRecord.time == time && oldRecord.moves > moves) {
                        oldRecord.time = time
                        oldRecord.moves = moves
                    }
                    let encoded = try JSONEncoder().encode(oldRecord)
                    UserDefaults.standard.set(encoded, forKey: "records")
                } else {
                    let encoded = try JSONEncoder().encode(currentRecord)
                    UserDefaults.standard.set(encoded, forKey: "records")
                }
                
            } catch {
                print("Unable to store the record. \(error)")
            }
            
            timer.invalidate()
            
            var message = ""
            
            do {
                if let savedData = UserDefaults.standard.data(forKey: "records") {
                    let record = try JSONDecoder().decode(Record.self, from: savedData)
                    message = "You did \(moves) moves in \(timeString(from: time))\n\nBest: \(record.moves) moves in \(timeString(from: record.time))"
                }
            } catch {
                print(error)
            }
            let alert = UIAlertController(title: "You Won", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
                self.restartGame()
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func countTime() {
        time += 1
        timeLabel.text = timeString(from: time)
    }
    
    func timeString(from time: Int) -> String {
        let minutes = time / 60 % 60
        let seconds = time % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    @objc func clear(){
        for i in 0...15 {
            if state[i] == 1 {
                state[i] = 0
                let button = view.viewWithTag(i + 1) as! UIButton
                button.setBackgroundImage(nil, for: .normal)
            }
        }
        isActive = false
    }
    
    func isGameFinished() -> Bool {
        for i in 0...15 {
            if state[i] == 0 || state[i] == 1{
                return false
            }
        }
        return true
    }
    
    func restartGame() {
        time = 0
        timeLabel.text = "00:00"
        moves = 0
        movesLabel.text = "Moves: 0"
        isActive = false
        isTimeRunning = false
        state = [Int](repeating: 0, count: 16)
        for i in 0...15 {
            let button = view.viewWithTag(i + 1) as! UIButton
            button.setBackgroundImage(nil, for: .normal)
        }
        shuffleImages()
    }

    
    func shuffleImages() {
        var indices = Array(0..<images.count)
        indices.shuffle()
        images = indices.map { images[$0] }
        winstate = winstate.map { [$0[0], $0[1]].map { indices.firstIndex(of: $0)! } }
    }
    
}
