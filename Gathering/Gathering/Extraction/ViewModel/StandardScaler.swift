//
//  StandardScaler.swift
//  Gathering
//
//  Created by Alessandro  on 23/09/24.
//

import Foundation

//
class StandardScaler{
    
    var means: [Double]
    var stdDevs: [Double]
    
    static let scaler = StandardScaler()
    
    private init() {
        self.means = [Double]()
        self.stdDevs = [Double]()
    }

    
    private func mean(of array: [Double]) -> Double {
        return array.reduce(0, +) / Double(array.count)
    }
    
    private func standardDeviation(of array: [Double]) -> Double {
        let meanValue = mean(of: array)
        let variance = array.map { pow($0 - meanValue, 2) }.reduce(0, +) / Double(array.count)
        return sqrt(variance)
    }

    
    func scale(values: [Double]) -> [Double] {
        let mean = mean(of: values)
        let stdDev = standardDeviation(of: values)
        
        means.append(mean)
        stdDevs.append(stdDev)
        
        // Evita la divisione per zero nel caso in cui la deviazione standard sia zero
        guard stdDev != 0 else {
            return values.map { _ in 0.0 }
        }
        
        return values.map { ($0 - mean) / stdDev }
    }
    
    
    func getMeans()->[Double]{
        return means
    }
    
    func getStdDevs()->[Double]{
        return stdDevs
    }
    
    func flush(){
        means = []
        stdDevs = []
    }
}
