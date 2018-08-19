//
//  AddIngredientViewController.swift
//  Smartypans
//
//  Created by Rahul Baxi on 1/15/18.
//  Copyright © 2018 SmartyPans Inc. All rights reserved.
//

import UIKit

import Speech
import SVProgressHUD
import Firebase
import FirebaseDatabase
import CoreBluetooth
import MBCircularProgressBar
import LGButton

@available(iOS 10.0, *)
class AddIngredientViewController : UIViewController, SFSpeechRecognizerDelegate, URLSessionDelegate, AddIngredientViewControllerDelegate, CBPeripheralManagerDelegate{
    
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral!
    private var consoleAsciiText:NSAttributedString? = NSAttributedString(string: "")
    
    
    private var startTime: CLong = 0
    private var endTime: CLong = 0
    private var temperatureData: Double = 0.0
    private var bleBuffer:String = ""
    
    //Calibration Factors
    private var lastKnownSupportOffset:Double = 0.0
    private var  currentSupportOffset: Double = 0.0
    private var  lastKnownHandleOffset:Double = 0.0
    private var  currentHandleOffset:Double = 0.0
    private var  lastKnownSupportCalibrationFactor:Double = 0.0
    private var  lastKnownHandleCalibrationFactor:Double = 0.0
    private var  currentSupportCalibrationFactor:Double = 0.0
    private var  currentHandleCalibrationFactor:Double = 0.0
    private var  supportCalibrationFactor:Double = 0.0
    private var  handleCalibrationFactor:Double = 0.0
    
    private var  baseSupportOffset:Double  = 0.0
    private var  baseHandleOffset:Double = 0.0
    
    private var supportWeightList:Array<Double> = []
    private var handleWeightList:Array<Double> = []
    private var supportSum:Double = 0
    private var handleSum:Double = 0
    private var isSet:Bool = false
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
    }
    
    
    @IBOutlet weak var weightLabel: UILabel!
    var controllerDelegate: AddIngredientViewControllerDelegate?
    
    var imageUrl = ""
    var ingredientName = ""
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var inputNode:AVAudioInputNode?
    var steps = [RecipeStep]()
    var currentStepNumber = 1
    var currentStep: RecipeStep?
    var recipeId = ""
    var databaseReference: DatabaseReference!
    
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    //@IBOutlet weak var nav_View: UIView!
    @IBOutlet weak var bg_View: UIView!
    @IBOutlet var add_Btn: LGButton!
    
    @IBOutlet weak var ingredientImage: UIImageView!
    @IBOutlet weak var labelIngredientName: UILabel!
    
    //BLE Data
    
    private var currentWeight = 0.0
    private var lastKnownWeight = 0.0
    private var isWeighing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseReference = Database.database().reference()
        recipeId = databaseReference.child("recipes").childByAutoId().key
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        weightLabel.sizeToFit()
        setRound(toView: ingredientImage, radius: ingredientImage.bounds.height/2)
        //updateIncomingData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configSpeechRecognizer()
        configureGradientNavbar()
        ingredientName = ""
        
        //labelIngredientName.text = ingredientName.uppercased()
//        ingredientImage.sd_setImage(with: URL(string: imageUrl))
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    override func viewDidDisappear(_ animated: Bool) {
        // peripheralManager?.stopAdvertising()
        // self.peripheralManager = nil
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        steps[steps.count-1].weight = self.lastKnownWeight
        steps[steps.count-1].endTime = Double(NSTimeIntervalSince1970*1000)
        steps[steps.count-1].weight = 4.2
        print("Step Number: \(self.steps[self.steps.count-1].stepNumber), step ingredient: \(self.steps[self.steps.count-1].ingredient)")
        self.saveSteps()
        //let saveRecipeController: SaveRecipeViewController = segue.destination as! SaveRecipeViewController
        //saveRecipeController.recipeId = self.recipeId
    }
    
    // MARK: - IBActions
    
    @IBAction func done(_ sender: Any) {
        steps[steps.count-1].endTime = NSTimeIntervalSince1970*1000
        steps[steps.count-1].weight = 4.2
        print("Step Number: \(self.steps[self.steps.count-1].stepNumber), step ingredient: \(self.steps[self.steps.count-1].ingredient)")
        self.saveSteps()
        //self.performSegue(withIdentifier: "saveRecipeSegue", sender: self)
        //let saveRecipeController = storyboard?.instantiateViewController(withIdentifier: "SaveRecipeVC") as? SaveRecipeViewController
        //saveRecipeController?.recipeId = self.recipeId
        //self.navigationController?.pushViewController(saveRecipeController!, animated: true)
    }
    
    @IBAction func addAnother(_ sender: Any) {
        isWeighing = false
        if(steps.count != 0){
            steps[steps.count-1].weight = self.lastKnownWeight
            steps[steps.count-1].endTime = Double(NSTimeIntervalSince1970*1000)
            currentStepNumber += 1
        }
        self.resetCalibration()
        self.resetWeightAnimation()
        self.startRecording()
    }
    
    private func resetCalibration(){
        //let uartModule: UartModuleViewController = UartModuleViewController()
        //uartModule.writeValue(data: "r")
        isSet = false
        lastKnownHandleOffset = currentHandleOffset
        currentHandleOffset = 0.0
        lastKnownSupportOffset = currentSupportOffset
        currentSupportOffset = 0.0
        lastKnownSupportCalibrationFactor = currentSupportCalibrationFactor
        lastKnownHandleCalibrationFactor = currentHandleCalibrationFactor
        currentSupportCalibrationFactor = 0.0
        currentHandleCalibrationFactor = 0.0
        self.currentWeight = 0.0
        self.lastKnownWeight = 0.0
        supportSum = 0.0
        handleSum = 0.0 
    }
    
    
    
    
    // MARK: Init functions
    func configureGradientNavbar(){
        let gradient = CAGradientLayer()
        let topColor: UIColor? = UIColor(red: 42.0 / 255.0, green: 53.0 / 255.0, blue: 136.0 / 255.0, alpha: 1.0)
        let bottomColor: UIColor? = UIColor(red: 226.0 / 255.0, green: 35.0 / 255.0, blue: 91.0 / 255.0, alpha: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 64.0)
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.colors = [(topColor?.cgColor as? Any), (bottomColor?.cgColor as? Any)]
        //nav_View.layer.insertSublayer(gradient, at: 0)
        
//        bg_View.layer.shadowColor = UIColor.black.cgColor
//        bg_View.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
//        bg_View.layer.shadowRadius = 15.0
//        bg_View.layer.shadowOpacity = 0.4
//        bg_View.clipsToBounds = false
//        bg_View.layer.cornerRadius = 22.0
        //        CustomMethods.shared().isGradient = true
    }
    
    func configSpeechRecognizer() {
        SVProgressHUD.show(withStatus: "Configuring...")
        let isButtonEnabled = false
        add_Btn.isEnabled = isButtonEnabled
        speechRecognizer.delegate = self
        SFSpeechRecognizer.requestAuthorization({(_ authStatus: SFSpeechRecognizerAuthorizationStatus) -> Void in
            
            var isButtonEnabled = false
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            OperationQueue.main.addOperation({() -> Void in
                SVProgressHUD.dismiss()
                self.add_Btn.isEnabled = isButtonEnabled
            })
        })
    }
    
    //MARK: Action
    func startWeightAnimation(weight: CGFloat){
        UIView.animate(withDuration: 2, animations: {() -> Void in
            //self.progressBar.value = weight
        })
    }
    
    func resetWeightAnimation(){
        UIView.animate(withDuration: 2, animations: {() -> Void in
            //self.progressBar.value = 0
        })
    }
    
    // MARK: Speech Recognition
    
    func startRecording() {
        print("started recording")
        SVProgressHUD.show(withStatus: "Say Ingredient Name")
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        //        var outError: Error?
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        inputNode = audioEngine.inputNode
        if inputNode == nil {
            print("Audio engine has no input node")
        }
        if recognitionRequest == nil {
            print("Unable to created a SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest?.shouldReportPartialResults = true  //6
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!, resultHandler: { (result, error) in  //7
            var isFinal = false
            if result != nil{
                print("Ingredient Name: \(String(describing: result?.bestTranscription.formattedString))!")
                self.stopRecording();

                isFinal = (result?.isFinal)!
                if(isFinal){
                    self.ingredientName = (result?.bestTranscription.formattedString)!
                    self.labelIngredientName.text = self.ingredientName
                    SVProgressHUD.dismiss()
                    self.addNewStep(ingredientName: self.ingredientName)
                    self.callSmartyPansAPI()
                    self.isWeighing = true
                }
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                self.inputNode?.removeTap(onBus: 0 as? AVAudioNodeBus ?? AVAudioNodeBus())
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.add_Btn.isEnabled = true
            }
        })
        let recordingFormat: AVAudioFormat? = inputNode?.outputFormat(forBus: 0 as? AVAudioNodeBus ?? AVAudioNodeBus())
        inputNode?.installTap(onBus: 0 as? AVAudioNodeBus ?? AVAudioNodeBus(), bufferSize: 1024 as? AVAudioFrameCount ?? AVAudioFrameCount(), format: recordingFormat, block: {(_ buffer: AVAudioPCMBuffer, _ when: AVAudioTime) -> Void in
            self.recognitionRequest?.append(buffer)
        })
        audioEngine.prepare()
          defer {
        }
        do {
            try? audioEngine.start()
        } catch let e {
            print("audioEngine couldn't start because of an error. \(e)")
        }
        
    }
    
    func stopRecording() {
        if audioEngine.isRunning {
            print("AUDIO ENGINE IS RUNNING")
            audioEngine.stop()
            recognitionRequest?.endAudio()
            add_Btn.isEnabled = false
        }
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        add_Btn.isEnabled = available
        print("AVAILABLE: \(available ? "YES" : "NO")")
    }
    
    // MARK: - AddIngredientViewControllerDelegate
    func handleAddSuccess() {
        navigationController?.popViewController(animated: true)
    }
    
    func callSmartyPansAPI(){
        let params = ["query": ingredientName] as Dictionary<String, String>
        
        var request = URLRequest(url: URL(string: "http://api-test.smartypans.io/v1/nutrition/ingredient_picture")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        var photoUrl = ""
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                photoUrl = (json["image_hd"] as? String)!
                let url = URL(string: photoUrl)
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        self.ingredientImage.image = UIImage(data: data!)
                    }
                }
            } catch {
                print("error")
            }
        })
        task.resume()
        self.steps[steps.count-1].ingredientImage = photoUrl
    }
    
    //MARK: Steps Logic
    
    func saveSteps(){
        for step in self.steps{
            step.stepDescription = "Add \(step.weight) \(step.unit) \(step.ingredient) and cook for \(cookTime(startTime: step.startTime, endTime: step.endTime)) minutes"
            databaseReference.child("recipe-steps").child(recipeId).child(step.uid).setValue(step.toObject())
        }
        print("Steps pushed to recipe: \(recipeId)")
    }

    private func cookTime(startTime: Double, endTime: Double) -> Double{
        return Double((endTime-startTime)) * 0.0000166667;
    }
    
    private func addNewStep(ingredientName: String){
        let startTime = Double(NSTimeIntervalSince1970*1000)
        var step = RecipeStep.init()
        step.recipeId = self.recipeId
        step.ingredient = self.ingredientName
        step.stepNumber = self.currentStepNumber
        step.startTime = startTime
        step.ingredient = self.ingredientName
        step.uid = databaseReference.child("steps").childByAutoId().key
        self.steps.append(step)
    }
    
    //MARK: BLE Stuff
    /*
    func updateIncomingData () {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Notify"), object: nil , queue: nil){
            notification in
            if(self.isWeighing){
                let bleRawData = characteristicASCIIValue as String
                print("bleRawData: \(bleRawData)")
                if(bleRawData.contains("\n")){
                    self.bleBuffer += bleRawData
                    print("bleBuffer (in if): \(self.bleBuffer)")
                    let strRefined = String(self.bleBuffer.filter{ !" \r\n".contains($0) })
                    let bleData = strRefined.components(separatedBy: ",")
                    if(!self.isBaseSet()){
                        self.baseSupportOffset = Double(bleData[1])!
                        self.baseHandleOffset = Double(bleData[3])!
                    
                        if(self.isWeighing){
                           self.extractWeight(bleData: bleData)
                            self.updateWeightUI()
                        }
                        self.temperatureData = Double(bleData[4])!
                    }
                    
                }else{
                    self.bleBuffer += bleRawData
                    print("bleBuffer (in else): \(self.bleBuffer)")
                }
                
                }
            }
        }
    */
    //MARK: BLE Data Processing
    private func updateWeightUI(){
        if(currentWeight < 0){
            currentWeight = 0.0;
        }
    
        if(lastKnownWeight <= currentWeight){
            lastKnownWeight = currentWeight;
        }
        if(!isWeighing && lastKnownWeight != currentWeight){
            lastKnownWeight = currentWeight;
        }
        self.weightLabel.text = "\(self.lastKnownWeight.format(f: ".2"))"
        self.startWeightAnimation(weight: CGFloat(self.lastKnownWeight))
    }
    
    private func getCalibrationFactor(temperature: Double) -> Double{
        let result = -9.2838E-13 * pow(temperature,7) + 0.00000000266173 * pow(temperature,6) - 0.0000012723 * pow(temperature,5) + 0.000257525 * pow(temperature,4) - 0.0261703 * pow(temperature,3) + 1.36271 * pow(temperature,2) - 35.3073*temperature + 508.658;
        
        return result;
    }
    
    private func extractWeight(bleData: Array<String>){
        let supportRaw = Double(bleData[0])!
        let supportOffset = Double(bleData[1])!
        let handleRaw = Double(bleData[2])!
        let handleOffset = Double(bleData[3])!
        let temperature = Double(bleData[4])!
        if(!isSet){
            currentSupportOffset = supportOffset;
            currentHandleOffset = handleOffset;
            supportCalibrationFactor = getCalibrationFactor(temperature: temperature);
            isSet = true;
        }
        
        let supportWeight = (supportRaw - supportOffset)/supportCalibrationFactor
        let handleWeight = (handleRaw - handleOffset)/supportCalibrationFactor
        var support = supportWeight
        var handle = handleWeight
        if(temperature > 129){
            support = getMeanAverage(isSupport: true);
            handle = getMeanAverage(isSupport: false);
        }
        self.currentWeight = (support + handle)/2;
    }
    
    private func isBaseSet() -> Bool{
        return (baseSupportOffset != 0 && baseHandleOffset != 0)
    }
    
    
    private func getMeanAverage(isSupport:Bool) -> Double{
        var result:Double = 0;
    if(isSupport){
        let count:Double = Double(supportWeightList.count);
     supportSum += supportWeightList[supportWeightList.count - 1];
    result = supportSum / count;
    
    }else{
        let count:Double = Double(handleWeightList.count);
     handleSum += handleWeightList[handleWeightList.count - 1];
    result = handleSum / count;
    }
    return result;
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SaveRecipeViewController") as! SaveRecipeViewController
        //vc.recipeId = self.recipeId
        navigationController?.pushViewController(vc, animated: true)
    }
}

protocol AddIngredientViewControllerDelegate {
    func handleAddSuccess()
}
