//
//  SalahCollectionViewController.swift
//  NimazApp
//
//  Created by apple on 18/10/2021.
//  Copyright © 2021 apple. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation
import UserNotifications
import MaterialActivityIndicator

class SalahCollectionViewController:UIViewController, CLLocationManagerDelegate {
    let indicator = MaterialActivityIndicatorView()
    private let itemsPerRow: CGFloat = 2
    @IBOutlet weak var Clock: UILabel!
    @IBOutlet weak var nextNimaz: UILabel!
    @IBOutlet weak var timeLeft: UILabel!
    @IBOutlet weak var viewCon: UIView!
    @IBOutlet var salahCV: UICollectionView!
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var releaseDate: NSDate?
    var countdownTimer = Timer()
    var timer = Timer()
    var c = 0
    var FiveNimaz : [Nimaz] = []
    var NimazTime : [String] = []
    var TimeDiff : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicatorView()
       // var collectionView: UICollectionView?
       
        //let i = Materialact
//        screenSize = UIScreen.main.bounds
//        screenWidth = screenSize.width
//        screenHeight = screenSize.height
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
//        layout.itemSize = CGSize(width: screenWidth/2, height: screenWidth/2.5)
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 3
//        salahCV!.collectionViewLayout = layout
        
        //bg img
      //  UIGraphicsBeginImageContext(self.view.frame.size)
      //  UIImage(named: "masjid")?.draw(in: self.view.bounds)
       // let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
       // UIGraphicsEndImageContext()
       // self.viewCon.backgroundColor = UIColor(patternImage: image)
        //time
        timer = Timer.scheduledTimer(timeInterval: 1.0,
            target: self,
            selector: #selector(tick),
            userInfo: nil,
            repeats: true)
        //apiCall
        indicator.startAnimating()
        ApiCall()
        
        self.salahCV.reloadData()
        
        
        
    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        indicator.startAnimating()
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        indicator.stopAnimating()
//    }
    @objc func tick() {
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "hh:mm:ss a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        let result = dateFormatter.string(from: date)
        Clock.text = result
    }
    func notifi()
    {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
        }

        let content = UNMutableNotificationContent()
        content.title = "Hi!"
        content.body = "Notification!"

        let date = Date().addingTimeInterval(5)

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let uuidString = UUID().uuidString

        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

        center.add(request) { (error) in
            print("Error")
        }
    }
    func startTimer() {
        let dateAsString = FiveNimaz[c].Nimaz_Time
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // fixes nil if device time in 24 hour format
        let date = dateFormatter.date(from: dateAsString)
        dateFormatter.dateFormat = "HH:mm"
        let date24 = dateFormatter.string(from: date!)
        
        let datee = Date()
        let dateFormatterr = DateFormatter()
        
        dateFormatterr.dateFormat = "yyyy-MM-dd"
        
        let result = dateFormatterr.string(from: datee)
        
        let releaseDateString = result + " " + date24 + ":00"
        print(releaseDateString)
        let releaseDateFormatter = DateFormatter()
        releaseDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        releaseDateFormatter.amSymbol = "AM"
        releaseDateFormatter.pmSymbol = "PM"
        releaseDate = releaseDateFormatter.date(from: releaseDateString)! as NSDate
        
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Forground notifications.
        completionHandler([.alert, .sound])
    }
    @objc func updateTime() {
        
        let currentDate = Date()
        let calendar = Calendar.current
        let diffDateComponents = calendar.dateComponents([.day, .hour, .minute, .second], from: currentDate , to: releaseDate! as Date)
        
        let countdown = "\(diffDateComponents.hour ?? 0) : \(diffDateComponents.minute ?? 0) : \(diffDateComponents.second ?? 0)"
        timeLeft.text = countdown
    }
    fileprivate func ApiCall() {
        Alamofire.request("http://api.aladhan.com/v1/timingsByCity?city=Rawalpindi&country=Pakistan&method=8").responseJSON{
            response in
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonAll = jsonResponse["data"]
                
                let jsonTime = jsonAll["timings"]
                print("ALL",jsonTime)
                //  print("Fajr",jsonTime["Fajr"].stringValue)
                self.FiveNimaz.append(Nimaz(Nimaz_Name:"Fajr",Nimaz_Time:(self.Hours(a: jsonTime["Fajr"].stringValue))))
                self.NimazTime.append(self.Hours(a: jsonTime["Fajr"].stringValue))
                //
                self.FiveNimaz.append(Nimaz(Nimaz_Name:"Dhuhr",Nimaz_Time:(self.Hours(a: jsonTime["Dhuhr"].stringValue))))
                self.NimazTime.append(self.Hours(a: jsonTime["Dhuhr"].stringValue))
                self.FiveNimaz.append(Nimaz(Nimaz_Name:"Asr",Nimaz_Time:(self.Hours(a: jsonTime["Asr"].stringValue))))
                self.NimazTime.append(self.Hours(a: jsonTime["Asr"].stringValue))
                self.FiveNimaz.append(Nimaz(Nimaz_Name:"Maghrib",Nimaz_Time:(self.Hours(a: jsonTime["Maghrib"].stringValue))))
                self.NimazTime.append(self.Hours(a: jsonTime["Maghrib"].stringValue))
                self.FiveNimaz.append(Nimaz(Nimaz_Name:"Isha",Nimaz_Time:(self.Hours(a: jsonTime["Isha"].stringValue))))
                self.NimazTime.append(self.Hours(a: jsonTime["Isha"].stringValue))
                
                //                    print("up",self.FiveNimaz.count)
                //                    print(self.FiveNimaz)
            }
            self.salahCV.reloadData()
            self.indicator.stopAnimating()
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            let currentTime = formatter.string(from: Date())
            
          //  let formatter = DateFormatter()
            for i in 0..<self.NimazTime.count
            {
                formatter.dateFormat = "h:mma"
                
                let date1 = formatter.date(from: currentTime)!
                let date2 = formatter.date(from: self.NimazTime[i])!
                
                let elapsedTime = date2.timeIntervalSince(date1)
                
                // convert from seconds to hours, rounding down to the nearest hour
                let hours = floor(elapsedTime / 60 / 60)
                
                // we have to subtract the number of seconds in hours from minutes to get
                // the remaining minutes, rounding down to the nearest minute (in case you
                // want to get seconds down the road)
                let minutes = floor((elapsedTime - (hours * 60 * 60)) / 60)
                self.TimeDiff.append("\(Int(hours)):\(Int(minutes))")
            }
            for i in 0..<self.TimeDiff.count
            {
                
                let splits = self.TimeDiff[i].components(separatedBy: ":")
                if(Int(splits[0])! >= 0)
                {
                    self.c = i
                    break
                }
            }
            print("Next=",self.c)
           // let next = self.TimeDiff[self.c]
          //  let spl = next.components(separatedBy: ":")
            self.nextNimaz.text = self.FiveNimaz[self.c].self.Nimaz_Name
          //  self.timeLeft.text = ("\(spl[0]) H : \(spl[1]) M")
            self.startTimer()
            self.notifi()
//            let indicator = MaterialActivityIndicatorView()
//
//            indicator.startAnimating()
        }
    }
    public func Hours(a: String)->String
    {
        let dateAsString = a
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let date = dateFormatter.date(from: dateAsString)
        dateFormatter.dateFormat = "h:mm a"
        let Date12 = dateFormatter.string(from: date!)
        return Date12
       // print("12 hour formatted Date:",Date12)
    }
    func setupActivityIndicatorView() {
        view.addSubview(indicator)
        setupActivityIndicatorViewConstraints()
    }
    
    func setupActivityIndicatorViewConstraints() {
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
}
extension SalahCollectionViewController: UICollectionViewDelegate,UICollectionViewDataSource{
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FiveNimaz.count
        
    }
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if let NimazCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? SalahCollectionViewCell{
            NimazCell.configure(with: FiveNimaz[indexPath.row])
            cell = NimazCell
        }
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.row == 0
        {
            return CGSize(width: screenWidth, height: screenWidth/2)
        }
        return CGSize(width: screenWidth/2, height: screenWidth/2);
        
    }
}
extension String{
    func date(format:String) -> Date?
    {
        let formatter = DateFormatter()
       // formatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00") as! TimeZone
        formatter.dateFormat = format
        //formatter.timeZone = NSTimeZone.local
        return formatter .date(from: self)
    }}
