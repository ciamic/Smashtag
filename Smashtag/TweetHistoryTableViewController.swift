//
//  TweetHistoryTableViewController.swift
//
//  Copyright (c) 2017 michelangelo
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

///Shows the recent twitter searches in a table view.
///Deletes data from database in case of row deletion.

class TweetHistoryTableViewController: UITableViewController {
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate and UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TweetHistory().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TweetHistoryCellIdentifier, for: indexPath)
        cell.textLabel?.text = TweetHistory().get(at: indexPath.row)
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let _ = TweetHistory().remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        default:
            break
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == Storyboard.ShowTweetsSegue {
                if let ttvc = segue.destination as? TweetTableViewController {
                    if let cell = sender as? UITableViewCell {
                        ttvc.searchText = cell.textLabel?.text
                    }
                }
            }
        }
    }
    
    override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
        //skip all the controllers and stops at the root one
        if navigationController?.viewControllers.first == self {
            return true
        }
        return false
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToRoot(_ sender: UIStoryboardSegue) {
        //unwind destination
    }

}
