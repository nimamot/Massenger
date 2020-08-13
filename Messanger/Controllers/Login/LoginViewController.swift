//
//  LoginViewController.swift
//  Messanger
//
//  Created by Nima on 8/12/20.
//  Copyright © 2020 Nima. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Adress..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordlField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let logingButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log in"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        
        
        
        logingButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        
        emailField.delegate = self
        passwordlField.delegate = self
        //Add subview
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordlField)
        scrollView.addSubview(logingButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2, y: 50, width: size, height: size)
        emailField.frame = CGRect(x: 30, y: imageView.buttom+10, width: scrollView.width-60, height: 52)
        
        passwordlField.frame = CGRect(x: 30, y: emailField.buttom+10, width: scrollView.width-60, height: 52)
        
         logingButton.frame = CGRect(x: 30, y: passwordlField.buttom+10, width: scrollView.width-60, height: 52)
      }
       
      
      
    @objc private func loginButtonTapped(){
        
        emailField.resignFirstResponder()
        passwordlField.resignFirstResponder()
        guard let email = emailField.text, let password = passwordlField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
                alartUserLoginError()
                return
        }
       
        //firebase Log In
    }
    
    func alartUserLoginError() {
        let alert = UIAlertController(title: "Woops", message: "please enter all information", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
        
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Creat Account"
        navigationController?.pushViewController(vc, animated: true)
    
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordlField.becomeFirstResponder()
        }
        else if textField == passwordlField {
            loginButtonTapped()
        }
        return true
    }
}
