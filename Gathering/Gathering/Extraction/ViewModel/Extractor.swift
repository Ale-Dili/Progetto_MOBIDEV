//
//  Extractor.swift
//  PredictorV2
//
//  Created by Alessandro  on 14/09/24.
//

import Foundation
import Accelerate

class Extractor{

    func fft(_ signal: [Double]) -> [Double] {
        let length = signal.count
        var real = [Double](signal)
        var imaginary = [Double](repeating: 0.0, count: length)
        
        // Create DSP setup object
        let log2n = vDSP_Length(log2(Float(length)))
        guard let fftSetup = vDSP_create_fftsetupD(log2n, Int32(kFFTRadix2)) else {
            fatalError("Unable to create FFT setup.")
        }
        
        // Convert the input to split complex form
        var splitComplex = DSPDoubleSplitComplex(realp: &real, imagp: &imaginary)
        
        // Perform FFT
        vDSP_fft_zipD(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
        
        // Compute magnitude
        var magnitudes = [Double](repeating: 0.0, count: length)
        vDSP_zvmagsD(&splitComplex, 1, &magnitudes, 1, vDSP_Length(length))
        
        // Take square root to get the actual magnitudes (since vDSP_zvmagsD computes squared magnitude)
        var result = [Double](repeating: 0.0, count: length)
        vvsqrt(&result, &magnitudes, [Int32(length)])
        
        // Destroy the FFT setup
        vDSP_destroy_fftsetupD(fftSetup)
        
        return result
    }

    
    
    func mean(data: [Double])->Double{
        let total = data.reduce(0.0, +)
        return total / Double(data.count)
    }
    
    func standardDeviation(data: [Double]) -> Double {
        let meanValue = mean(data: data)
        let sumOfSquaredDifferences = data.reduce(0.0) { $0 + ($1 - meanValue) * ($1 - meanValue) }
        return sqrt(sumOfSquaredDifferences / Double(data.count))
    }
    
    func averageAbsoluteDeviation(data: [Double]) -> Double {
        let meanValue = mean(data: data)
        let sumOfAbsoluteDifferences = data.reduce(0.0) { $0 + abs($1 - meanValue) }
        return sumOfAbsoluteDifferences / Double(data.count)
    }

    func minimum(data: [Double]) -> Double {
        return data.min() ?? Double.nan
    }

    func maximum(data: [Double]) -> Double {
        return data.max() ?? Double.nan
    }
    
    func delta(data: [Double]) -> Double {
        guard let minValue = data.min(), let maxValue = data.max() else { return Double.nan }
        return maxValue - minValue
    }
    
    func median(data: [Double]) -> Double {
        let sortedData = data.sorted()
        let count = sortedData.count
        if count % 2 == 0 {
            return (sortedData[count / 2 - 1] + sortedData[count / 2]) / 2
        } else {
            return sortedData[count / 2]
        }
    }
    
    
    func medianAbsoluteDeviation(data: [Double]) -> Double {
        let medianValue = median(data: data)
        let deviations = data.map { abs($0 - medianValue) }
        return median(data: deviations)
    }

    func interquartileRange(data: [Double]) -> Double {
        let sortedData = data.sorted()
        let q1 = percentile(sortedData: sortedData, percentile: 25)
        let q3 = percentile(sortedData: sortedData, percentile: 75)
        return q3 - q1
    }
    
    func percentile(sortedData: [Double], percentile: Double) -> Double {
        guard !sortedData.isEmpty, percentile >= 0 && percentile <= 100 else { return Double.nan }
        let rank = (percentile / 100) * Double(sortedData.count - 1)
        let lowerIndex = Int(rank)
        let upperIndex = min(lowerIndex + 1, sortedData.count - 1)
        let weight = rank - Double(lowerIndex)
        return (1 - weight) * sortedData[lowerIndex] + weight * sortedData[upperIndex]
    }
    
    func countNegatives(data: [Double]) -> Double {
        return Double(data.filter { $0 < 0 }.count)
    }

    func countPositives(data: [Double]) -> Double {
        return Double(data.filter { $0 > 0 }.count)
    }

    func countAboveMean(data: [Double]) -> Double {
        let meanValue = mean(data: data)
        return Double(data.filter { $0 > meanValue }.count)
    }
    
    func countPeaks(data: [Double]) -> Double {
        var peakCount = 0
        for i in 1..<data.count-1 {
            if data[i] > data[i-1] && data[i] > data[i+1] {
                peakCount += 1
            }
        }
        return Double(peakCount)
    }

    func skewness(data: [Double]) -> Double {
        let meanValue = mean(data: data)
        let n = Double(data.count)
        let m3 = data.reduce(0.0) { $0 + pow($1 - meanValue, 3) } / n
        let m2 = standardDeviation(data: data)
        return (m3 / pow(m2, 3))
    }

    func kurtosis(data: [Double]) -> Double {
        let meanValue = mean(data: data)
        let n = Double(data.count)
        let m4 = data.reduce(0.0) { $0 + pow($1 - meanValue, 4) } / n
        let m2 = standardDeviation(data: data)
        return (m4 / pow(m2, 4)) - 3
    }

    func energy(data: [Double]) -> Double {
        return data.reduce(0.0) { $0 + $1 * $1 }
    }
    
    func averageResultantAcceleration(xComponent: [Double], yComponent: [Double], zComponent: [Double]) -> Double {
        var sumOfResultants: Double = 0.0
        
        for i in 0..<xComponent.count {
            let x = xComponent[i]
            let y = yComponent[i]
            let z = zComponent[i]
            
            let resultant = sqrt(x * x + y * y + z * z)
            sumOfResultants += resultant
        }
        let averageResultant = sumOfResultants / Double(xComponent.count)
        return averageResultant
    }
    
    func sma(xComponent: [Double], yComponent: [Double], zComponent: [Double]) -> Double {
        var sumOfMagnitudes: Double = 0.0
        
        for i in 0..<xComponent.count {
            let x = xComponent[i]
            let y = yComponent[i]
            let z = zComponent[i]
            
            // Calcola la magnitudine del segnale per il punto i
            let magnitude = sqrt(x * x + y * y + z * z)
            sumOfMagnitudes += magnitude
        }
        
        return sumOfMagnitudes
    }


    
    
    func extractFeatures(signal: Signal) -> [Double] {
        var row = [Double]()
        
        // MEAN
        row.append(mean(data: signal.getColumn(name: "accelerometerX")))
        row.append(mean(data: signal.getColumn(name: "accelerometerY")))
        row.append(mean(data: signal.getColumn(name: "accelerometerZ")))
        row.append(mean(data: signal.getColumn(name: "gyroX")))
        row.append(mean(data: signal.getColumn(name: "gyroY")))
        row.append(mean(data: signal.getColumn(name: "gyroZ")))
        
        // STANDARD DEVIATION
        row.append(standardDeviation(data: signal.getColumn(name: "accelerometerX")))
        row.append(standardDeviation(data: signal.getColumn(name: "accelerometerY")))
        row.append(standardDeviation(data: signal.getColumn(name: "accelerometerZ")))
        row.append(standardDeviation(data: signal.getColumn(name: "gyroX")))
        row.append(standardDeviation(data: signal.getColumn(name: "gyroY")))
        row.append(standardDeviation(data: signal.getColumn(name: "gyroZ")))

        // AVERAGE ABSOLUTE DEVIATION
        row.append(averageAbsoluteDeviation(data: signal.getColumn(name: "accelerometerX")))
        row.append(averageAbsoluteDeviation(data: signal.getColumn(name: "accelerometerY")))
        row.append(averageAbsoluteDeviation(data: signal.getColumn(name: "accelerometerZ")))
        row.append(averageAbsoluteDeviation(data: signal.getColumn(name: "gyroX")))
        row.append(averageAbsoluteDeviation(data: signal.getColumn(name: "gyroY")))
        row.append(averageAbsoluteDeviation(data: signal.getColumn(name: "gyroZ")))

        // MINIMUM
        row.append(minimum(data: signal.getColumn(name: "accelerometerX")))
        row.append(minimum(data: signal.getColumn(name: "accelerometerY")))
        row.append(minimum(data: signal.getColumn(name: "accelerometerZ")))
        row.append(minimum(data: signal.getColumn(name: "gyroX")))
        row.append(minimum(data: signal.getColumn(name: "gyroY")))
        row.append(minimum(data: signal.getColumn(name: "gyroZ")))

        // MAXIMUM
        row.append(maximum(data: signal.getColumn(name: "accelerometerX")))
        row.append(maximum(data: signal.getColumn(name: "accelerometerY")))
        row.append(maximum(data: signal.getColumn(name: "accelerometerZ")))
        row.append(maximum(data: signal.getColumn(name: "gyroX")))
        row.append(maximum(data: signal.getColumn(name: "gyroY")))
        row.append(maximum(data: signal.getColumn(name: "gyroZ")))

        // DELTA
        row.append(delta(data: signal.getColumn(name: "accelerometerX")))
        row.append(delta(data: signal.getColumn(name: "accelerometerY")))
        row.append(delta(data: signal.getColumn(name: "accelerometerZ")))
        row.append(delta(data: signal.getColumn(name: "gyroX")))
        row.append(delta(data: signal.getColumn(name: "gyroY")))
        row.append(delta(data: signal.getColumn(name: "gyroZ")))

        // MEDIAN
        row.append(median(data: signal.getColumn(name: "accelerometerX")))
        row.append(median(data: signal.getColumn(name: "accelerometerY")))
        row.append(median(data: signal.getColumn(name: "accelerometerZ")))
        row.append(median(data: signal.getColumn(name: "gyroX")))
        row.append(median(data: signal.getColumn(name: "gyroY")))
        row.append(median(data: signal.getColumn(name: "gyroZ")))

        // MEDIAN ABSOLUTE DEVIATION
        row.append(medianAbsoluteDeviation(data: signal.getColumn(name: "accelerometerX")))
        row.append(medianAbsoluteDeviation(data: signal.getColumn(name: "accelerometerY")))
        row.append(medianAbsoluteDeviation(data: signal.getColumn(name: "accelerometerZ")))
        row.append(medianAbsoluteDeviation(data: signal.getColumn(name: "gyroX")))
        row.append(medianAbsoluteDeviation(data: signal.getColumn(name: "gyroY")))
        row.append(medianAbsoluteDeviation(data: signal.getColumn(name: "gyroZ")))

        // INTERQUARTILE RANGE
        row.append(interquartileRange(data: signal.getColumn(name: "accelerometerX")))
        row.append(interquartileRange(data: signal.getColumn(name: "accelerometerY")))
        row.append(interquartileRange(data: signal.getColumn(name: "accelerometerZ")))
        row.append(interquartileRange(data: signal.getColumn(name: "gyroX")))
        row.append(interquartileRange(data: signal.getColumn(name: "gyroY")))
        row.append(interquartileRange(data: signal.getColumn(name: "gyroZ")))

        // NUMBER OF NEGATIVE VALUES
        row.append(countNegatives(data: signal.getColumn(name: "accelerometerX")))
        row.append(countNegatives(data: signal.getColumn(name: "accelerometerY")))
        row.append(countNegatives(data: signal.getColumn(name: "accelerometerZ")))
        row.append(countNegatives(data: signal.getColumn(name: "gyroX")))
        row.append(countNegatives(data: signal.getColumn(name: "gyroY")))
        row.append(countNegatives(data: signal.getColumn(name: "gyroZ")))

        // NUMBER OF POSITIVE VALUES
        row.append(countPositives(data: signal.getColumn(name: "accelerometerX")))
        row.append(countPositives(data: signal.getColumn(name: "accelerometerY")))
        row.append(countPositives(data: signal.getColumn(name: "accelerometerZ")))
        row.append(countPositives(data: signal.getColumn(name: "gyroX")))
        row.append(countPositives(data: signal.getColumn(name: "gyroY")))
        row.append(countPositives(data: signal.getColumn(name: "gyroZ")))

        // NUMBER OF VALUES ABOVE MEAN
        row.append(countAboveMean(data: signal.getColumn(name: "accelerometerX")))
        row.append(countAboveMean(data: signal.getColumn(name: "accelerometerY")))
        row.append(countAboveMean(data: signal.getColumn(name: "accelerometerZ")))
        row.append(countAboveMean(data: signal.getColumn(name: "gyroX")))
        row.append(countAboveMean(data: signal.getColumn(name: "gyroY")))
        row.append(countAboveMean(data: signal.getColumn(name: "gyroZ")))

        // NUMBER OF PEAKS
        row.append(countPeaks(data: signal.getColumn(name: "accelerometerX")))
        row.append(countPeaks(data: signal.getColumn(name: "accelerometerY")))
        row.append(countPeaks(data: signal.getColumn(name: "accelerometerZ")))
        row.append(countPeaks(data: signal.getColumn(name: "gyroX")))
        row.append(countPeaks(data: signal.getColumn(name: "gyroY")))
        row.append(countPeaks(data: signal.getColumn(name: "gyroZ")))

        // SKEWNESS
        row.append(skewness(data: signal.getColumn(name: "accelerometerX")))
        row.append(skewness(data: signal.getColumn(name: "accelerometerY")))
        row.append(skewness(data: signal.getColumn(name: "accelerometerZ")))
        row.append(skewness(data: signal.getColumn(name: "gyroX")))
        row.append(skewness(data: signal.getColumn(name: "gyroY")))
        row.append(skewness(data: signal.getColumn(name: "gyroZ")))

        // KURTOSIS
        row.append(kurtosis(data: signal.getColumn(name: "accelerometerX")))
        row.append(kurtosis(data: signal.getColumn(name: "accelerometerY")))
        row.append(kurtosis(data: signal.getColumn(name: "accelerometerZ")))
        row.append(kurtosis(data: signal.getColumn(name: "gyroX")))
        row.append(kurtosis(data: signal.getColumn(name: "gyroY")))
        row.append(kurtosis(data: signal.getColumn(name: "gyroZ")))

        // ENERGY
        row.append(energy(data: signal.getColumn(name: "accelerometerX")))
        row.append(energy(data: signal.getColumn(name: "accelerometerY")))
        row.append(energy(data: signal.getColumn(name: "accelerometerZ")))
        row.append(energy(data: signal.getColumn(name: "gyroX")))
        row.append(energy(data: signal.getColumn(name: "gyroY")))
        row.append(energy(data: signal.getColumn(name: "gyroZ")))
        
        //!!!!!!!!!!!!!!!!!!!!!!  FFT !!!!!!!!!!!!!!!!!!!!!!!!!
        let accXFft = fft(signal.getColumn(name: "accelerometerX"))
        let accYFft = fft(signal.getColumn(name: "accelerometerY"))
        let accZFft = fft(signal.getColumn(name: "accelerometerZ"))
        let gyroXFft = fft(signal.getColumn(name: "gyroX"))
        let gyroYFft = fft(signal.getColumn(name: "gyroY"))
        let gyroZFft = fft(signal.getColumn(name: "gyroZ"))
        
        
        // MEAN FFT
        row.append(mean(data: accXFft))
        row.append(mean(data: accYFft))
        row.append(mean(data: accZFft))
        row.append(mean(data: gyroXFft))
        row.append(mean(data: gyroYFft))
        row.append(mean(data: gyroZFft))
        
        // STANDARD DEVIATION FFT
        row.append(standardDeviation(data: accXFft))
        row.append(standardDeviation(data: accYFft))
        row.append(standardDeviation(data: accZFft))
        row.append(standardDeviation(data: gyroXFft))
        row.append(standardDeviation(data: gyroYFft))
        row.append(standardDeviation(data: gyroZFft))

        // AVERAGE ABSOLUTE DEVIATION FFT
        row.append(averageAbsoluteDeviation(data: accXFft))
        row.append(averageAbsoluteDeviation(data: accYFft))
        row.append(averageAbsoluteDeviation(data: accZFft))
        row.append(averageAbsoluteDeviation(data: gyroXFft))
        row.append(averageAbsoluteDeviation(data: gyroYFft))
        row.append(averageAbsoluteDeviation(data: gyroZFft))

        // MINIMUM FFT
        row.append(minimum(data: accXFft))
        row.append(minimum(data: accYFft))
        row.append(minimum(data: accZFft))
        row.append(minimum(data: gyroXFft))
        row.append(minimum(data: gyroYFft))
        row.append(minimum(data: gyroZFft))

        // MAXIMUM FFT
        row.append(maximum(data: accXFft))
        row.append(maximum(data: accYFft))
        row.append(maximum(data: accZFft))
        row.append(maximum(data: gyroXFft))
        row.append(maximum(data: gyroYFft))
        row.append(maximum(data: gyroZFft))

        // DELTA FFT
        row.append(delta(data: accXFft))
        row.append(delta(data: accYFft))
        row.append(delta(data: accZFft))
        row.append(delta(data: gyroXFft))
        row.append(delta(data: gyroYFft))
        row.append(delta(data: gyroZFft))

        // MEDIAN FFT
        row.append(median(data: accXFft))
        row.append(median(data: accYFft))
        row.append(median(data: accZFft))
        row.append(median(data: gyroXFft))
        row.append(median(data: gyroYFft))
        row.append(median(data: gyroZFft))

        // MEDIAN ABSOLUTE DEVIATION FFT
        row.append(medianAbsoluteDeviation(data: accXFft))
        row.append(medianAbsoluteDeviation(data: accYFft))
        row.append(medianAbsoluteDeviation(data: accZFft))
        row.append(medianAbsoluteDeviation(data: gyroXFft))
        row.append(medianAbsoluteDeviation(data: gyroYFft))
        row.append(medianAbsoluteDeviation(data: gyroZFft))

        // INTERQUARTILE RANGE FFT
        row.append(interquartileRange(data: accXFft))
        row.append(interquartileRange(data: accYFft))
        row.append(interquartileRange(data: accZFft))
        row.append(interquartileRange(data: gyroXFft))
        row.append(interquartileRange(data: gyroYFft))
        row.append(interquartileRange(data: gyroZFft))

        // NUMBER OF NEGATIVE VALUES FFT
        row.append(countNegatives(data: accXFft))
        row.append(countNegatives(data: accYFft))
        row.append(countNegatives(data: accZFft))
        row.append(countNegatives(data: gyroXFft))
        row.append(countNegatives(data: gyroYFft))
        row.append(countNegatives(data: gyroZFft))

        // NUMBER OF POSITIVE VALUES FFT
        row.append(countPositives(data: accXFft))
        row.append(countPositives(data: accYFft))
        row.append(countPositives(data: accZFft))
        row.append(countPositives(data: gyroXFft))
        row.append(countPositives(data: gyroYFft))
        row.append(countPositives(data: gyroZFft))

        // NUMBER OF VALUES ABOVE MEAN FFT
        row.append(countAboveMean(data: accXFft))
        row.append(countAboveMean(data: accYFft))
        row.append(countAboveMean(data: accZFft))
        row.append(countAboveMean(data: gyroXFft))
        row.append(countAboveMean(data: gyroYFft))
        row.append(countAboveMean(data: gyroZFft))

        // NUMBER OF PEAKS FFT
        row.append(countPeaks(data: accXFft))
        row.append(countPeaks(data: accYFft))
        row.append(countPeaks(data: accZFft))
        row.append(countPeaks(data: gyroXFft))
        row.append(countPeaks(data: gyroYFft))
        row.append(countPeaks(data: gyroZFft))

        // SKEWNESS FFT
        row.append(skewness(data: accXFft))
        row.append(skewness(data: accYFft))
        row.append(skewness(data: accZFft))
        row.append(skewness(data: gyroXFft))
        row.append(skewness(data: gyroYFft))
        row.append(skewness(data: gyroZFft))

        // KURTOSIS FFT
        row.append(kurtosis(data: accXFft))
        row.append(kurtosis(data: accYFft))
        row.append(kurtosis(data: accZFft))
        row.append(kurtosis(data: gyroXFft))
        row.append(kurtosis(data: gyroYFft))
        row.append(kurtosis(data: gyroZFft))

        // ENERGY FFT
        row.append(energy(data: accXFft))
        row.append(energy(data: accYFft))
        row.append(energy(data: accZFft))
        row.append(energy(data: gyroXFft))
        row.append(energy(data: gyroYFft))
        row.append(energy(data: gyroZFft))

        //ARA
        row.append(averageResultantAcceleration(xComponent: signal.getColumn(name: "accelerometerX"), yComponent: signal.getColumn(name: "accelerometerY"), zComponent: signal.getColumn(name: "accelerometerZ")))
        row.append(averageResultantAcceleration(xComponent: signal.getColumn(name: "gyroX"), yComponent: signal.getColumn(name: "gyroY"), zComponent: signal.getColumn(name: "gyroZ")))
        
        //ARA FFT
        row.append(averageResultantAcceleration(xComponent: accXFft, yComponent: accYFft, zComponent: accZFft))
        row.append(averageResultantAcceleration(xComponent: gyroXFft, yComponent: gyroYFft, zComponent: gyroZFft))
        
        //SMA
        row.append(sma(xComponent: signal.getColumn(name: "accelerometerX"), yComponent: signal.getColumn(name: "accelerometerY"), zComponent: signal.getColumn(name: "accelerometerZ")))
        row.append(sma(xComponent: signal.getColumn(name: "gyroX"), yComponent: signal.getColumn(name: "gyroY"), zComponent: signal.getColumn(name: "gyroZ")))
        
        //SMA FFT
        row.append(sma(xComponent: accXFft, yComponent: accYFft, zComponent: accZFft))
        row.append(sma(xComponent: gyroXFft, yComponent: gyroYFft, zComponent: gyroZFft))

        return row
    }

    
    
}
