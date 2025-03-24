//
//  RadioButton.swift
//  Hurricane
//
//  Created by Swati Verma on 11/07/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation

@objc protocol RadioButtonDelegate: NSObjectProtocol {
    func radioButtonSelected(_ index: Int, groupId: String)
}

class RadioButton: UIView {

    var groupId: String = ""
    var index: Int = 0
    var button =  UIButton()
    var delegate: RadioButtonDelegate?

    static var rb_instances: [AnyObject]?
    static var rb_observers: [AnyHashable: Any]?

    // MARK: Observer
    class func addObserverForGroupId(_ groupId: String, observer: AnyObject?) {
        if rb_observers == nil {
            rb_observers = [AnyHashable: Any]()
        }
        if groupId.count > 0 && observer != nil {
            rb_observers![groupId] = observer
        }
    }

    // MARK: Manage Instances
    class func registerInstance(_ radioButton: RadioButton) {
        if rb_instances == nil {
            rb_instances = [AnyObject]()
        }
        rb_instances!.append(radioButton)
    }

    // MARK: Class level handler
    class func buttonSelected(_ radioButton: RadioButton) {
        // Notify observers
        if rb_observers != nil {
            let observer: RadioButtonDelegate? = (rb_observers![radioButton.groupId] as! RadioButtonDelegate?)
            if observer != nil {
                observer!.radioButtonSelected(radioButton.index, groupId: radioButton.groupId)
            }
        }
        // Unselect the other radio buttons
        if AppDefaults.checkInternetConnection() { // HAPP-549
        if rb_instances != nil {
            for i in 0 ..< rb_instances!.count {
                let button: RadioButton = rb_instances![i] as! RadioButton
                if !button.isEqual(radioButton) && (button.groupId == radioButton.groupId) {
                    button.otherButtonSelected(radioButton)
                }
            }
        }
        }
    }

    // MARK: Object Lifecycle
    init(groupId: String, index: Int) {
        self.groupId = groupId
        self.index = index
        super.init(frame: CGRect(x: 0, y: 0, width: (IS_IPAD ? 80 : 40), height: (IS_IPAD ? 80 : 40)))
        self.defaultInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Tap handling
    @objc func handleButtonTap(_ sender: AnyObject) {
        if AppDefaults.checkInternetConnection() { // HAPP-549
            button.isSelected = true
        }
        RadioButton.buttonSelected(self)
    }

    func otherButtonSelected(_ sender: AnyObject) {
        // Called when other radio button instance got selected
        if button.isSelected {
            button.isSelected = false
        }
    }

    // MARK: RadioButton init    
    func defaultInit() {
        // Setup container view
        self.frame = CGRect(x: 0, y: 0, width: (IS_IPAD ? 80 : 40), height: (IS_IPAD ? 80 : 40))
        // Customize UIButton
        self.button = UIButton(type: .custom)
        self.button.frame = CGRect(x: 0, y: 0, width: (IS_IPAD ? 80 : 40), height: (IS_IPAD ? 80 : 40))
        self.button.adjustsImageWhenHighlighted = false
        button.setImage(UIImage(named: "OFFStateImage.png")!, for: UIControl.State())
        button.setImage(UIImage(named: "ONStateImage.png")!, for: .selected)
        button.addTarget(self, action: #selector(self.handleButtonTap), for: .touchUpInside)
        self.addSubview(button)
        RadioButton.registerInstance(self)
    }
}
