//
//  WorkoutManager.swift
//  WongiTools WatchKit Extension
//
//  Created by Luis Almaguer on 26/06/22.
//

import Foundation
import HealthKit

protocol WorkoutManagerDelegate: AnyObject {
    func didReceiveHKHeartRate(_ heartRate: Double)
}

protocol WorkoutManagerProtocol {
    static func authorizeHealthKit()
    func startWorkout()
    func stopWorkout()
}

class WorkoutManager: NSObject, ObservableObject {
    static let shared = WorkoutManager()
    private var stopping = false
    @Published var running = false
    @Published var heartRate: Double = 0
    
    let healtStore = HKHealthStore()
    let configuration = HKWorkoutConfiguration()
    var workoutSession: HKWorkoutSession?
    var workoutBuilder: HKLiveWorkoutBuilder? // we can algo try to use the workout builder
    
    weak var delegate: WorkoutManagerDelegate?
    
    private var query: HKAnchoredObjectQuery?
    
    override init() {
        super.init()
    }
}

extension WorkoutManager {
    private func configureWorkout() {
        configuration.activityType = .running
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healtStore, configuration: configuration)
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
        } catch {
            print("Could not start workout session \(error.localizedDescription)")
            return
        }
        guard let session = workoutSession else { return }
        guard let builder = workoutBuilder else { return }
        
        let dataSource = HKLiveWorkoutDataSource(healthStore: healtStore, workoutConfiguration: configuration)
        builder.dataSource = dataSource
        
        dataSource.enableCollection(for: HKQuantityType.quantityType(forIdentifier: .heartRate)!, predicate: nil)
        
        session.delegate = self
        builder.delegate = self
    }
}

extension WorkoutManager: WorkoutManagerProtocol {
    static func authorizeHealthKit() {
        if HKHealthStore.isHealthDataAvailable() {
            let typesToShare: Set = [
                HKQuantityType.workoutType()
            ]
            
            let typesToRead: Set = [
                HKQuantityType.quantityType(forIdentifier: .heartRate)!
            ]
            
            HKHealthStore().requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
                if success {
                    print("Auhotizationed HealtKit access!")
                } else if let error = error {
                    print("Could not get authorization \(error.localizedDescription)")
                }
            }
        }
    }
    
    func startWorkout() {
        guard !self.running else { return }
        
        print("Starting workout")
        self.stopping = false
        configureWorkout()
        guard let session = workoutSession else {return}
        guard let builder = workoutBuilder else {return}
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: [])
        
        query = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) {
            (query, samples, deletedObjects, anchor, error) -> Void in
            self.onQuerySamples(samples: samples)
        }
        
        query!.updateHandler = { (query, samples, deletedObjects, anchor, error) -> Void in
            self.onQuerySamples(samples: samples)
        }
        
        healtStore.execute(query!)
        
        session.startActivity(with: Date())
        
        builder.beginCollection(withStart: Date()) { (success, error) in
            if success {
                print("WKBuilder collection started")
            } else if let error = error {
                print(error)
            }
        }
    }
    
    func stopWorkout() {
        guard !stopping else { return }
        print("Stoping workout")
        stopping = true
        workoutSession?.stopActivity(with: Date())
        workoutSession?.end()
    }
    
    private func onQuerySamples(samples: [HKSample]?) {
        guard let value = self.formatSamples(samples: samples) else { return }
        DispatchQueue.main.async {
            self.heartRate = value
        }
        self.delegate?.didReceiveHKHeartRate(value)
    }
    
    private func formatSamples(samples: [HKSample]? ) -> Double? {
        guard let samples = samples as? [HKQuantitySample] else { return nil }
        guard let quantity = samples.last?.quantity else { return nil }
        let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        
        let value = quantity.doubleValue(for: heartRateUnit)
        
        return value;
    }
    
}

extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            self.running = toState == .running
        }
        
        if toState == .ended {
            if let query = self.query {
                healtStore.stop(query)
                self.stopping = false
            }
            workoutBuilder?.endCollection(withEnd: date) { (success, error) in
                if success {
                    print("WKBuilder collection stopped")
                    self.workoutBuilder?.finishWorkout { (success, error) in
                        print("WKBuilder workout finished")
                        
                    }
                } else if let error = error {
                    print(error)
                }
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }
}

extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        // We could actually use this method.
    }
}
