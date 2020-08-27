//
//  ProfileViewController.swift
//  Messanger
//
//  Created by Nima on 8/12/20.
//  Copyright © 2020 Nima. All rights reserved.
//

import UIKit
import FirebaseAuth
import SDWebImage



enum profileViewModelType {
    case info, logout
}
struct profileViewModel {
    let ViewModelType: profileViewModelType
    let title: String
    let handler: (() -> Void)?
}
final class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var data = [profileViewModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(profileTableViewCell.self, forCellReuseIdentifier: profileTableViewCell.identifier)
        
        data.append(profileViewModel(ViewModelType: .info, title: "Name: \(UserDefaults.standard.value(forKey: "name") as? String ?? "No Name")", handler: nil))
        
        data.append(profileViewModel(ViewModelType: .info, title: "Email: \(UserDefaults.standard.value(forKey: "email") as? String ?? "No Email")", handler: nil))
        
        data.append(profileViewModel(ViewModelType: .logout, title: "Log out", handler: { [weak self] in
            
            guard let strongSelf = self else{
                return
            }
            
            let actionSheet = UIAlertController(title: "",
                                                message: "",
                                                preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Log Out",
                                                style: .destructive,
                                                
                                                handler: { [weak self] _ in
                                                    guard let strongSelf = self else{
                                                        return
                                                    }
                                                    
                                                    UserDefaults.standard.setValue(nil, forKey: "email")
                                                    UserDefaults.standard.setValue(nil, forKey: "name")
                                                    
                                                    do {
                                                        try FirebaseAuth.Auth.auth().signOut()
                                                        
                                                        let vc = LoginViewController()
                                                        let nav = UINavigationController(rootViewController: vc)
                                                        nav.modalPresentationStyle = .fullScreen
                                                        strongSelf.present(nav, animated: true)
                                                        
                                                    }
                                                    catch {
                                                        print("failed to log out")
                                                    }
                                                    
                                                    
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Canlel",
                                                style: .cancel,
                                                handler: nil))
            
            
            strongSelf.present(actionSheet, animated: true)
            
        }))
        
        tableView.register(UITableViewCell.self ,
                           forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = creatTableHeader()
    }
    func creatTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        
        let path = "images/"+fileName
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
        
        headerView.backgroundColor = .link
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-150) / 2, y: 75, width: 150, height: 150) )
        
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        headerView.addSubview(imageView)
        
        StorageManeger.shared.downloadURL(for: path, completion: { result in
            switch result {
            case .success(let url):
                imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Faliled to get downloaded url: \(error)")
            }
        })
        
        return headerView
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: profileTableViewCell.identifier,
                                                 for: indexPath) as! profileTableViewCell
        cell.setup(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    }
}


class profileTableViewCell: UITableViewCell {
    
    static let identifier = "profileTableViewCell"
    
    public func setup(with viewModel: profileViewModel){
        
        self.textLabel?.text =  viewModel.title
        
        switch viewModel.ViewModelType {
        case .info:
            textLabel?.textAlignment = .left
            selectionStyle = .none
        case .logout:
            textLabel?.textColor = .red
            textLabel?.textAlignment = .center
        }
    }
}


