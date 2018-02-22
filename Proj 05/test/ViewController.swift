//
//  ViewController.swift
//  test
//
//  Created by yu wang on 19/02/2018.
//  Copyright © 2018 yu wang. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UITableViewController {

    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                allWords = startWords.components(separatedBy: "\n")
            }
        } else {
            allWords = ["silkworm"]
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(promptForAnswer))
        startGame()
    }

    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] (action: UIAlertAction) in
            let answer = ac.textFields![0]
            self.submit(answer: answer.text!)
        }

        ac.addAction(submitAction)
        present(ac, animated: true)
    }

    func submit(answer: String) {
        let lowerWord = answer.lowercased()

        let errorTitle:String
        let errorMessage:String

        if isPossible(word: lowerWord) {
            if isOriginal(word: lowerWord) {
                if isReal(word: lowerWord) {
                    usedWords.insert(lowerWord, at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                }else {
                    errorTitle = "Word not recognized"
                    errorMessage = "You can't just make them up, you know!"
                }
            }else{
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
            }
        }else{
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from '\(title!.lowercased())'!"
        }

        let ac = UIAlertController(title: errorTitle , message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    private func startGame() {
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        title = allWords[0]
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }

    func isPossible(word: String) -> Bool {
        var tempWord = title!.lowercased()

        for letter in word {
            if let pos = tempWord.range(of: String(letter)) {
                tempWord.remove(at: pos.lowerBound)
            } else {
                return false
            }
        }
        return true
    }

    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let missSpellRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return missSpellRange.location == NSNotFound
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]

        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

