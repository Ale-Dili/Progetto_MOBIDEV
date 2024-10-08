//
//  ViewModelGatheringIphone.swift
//  Gathering
//
//  Created by Alessandro  on 27/09/24.
//

import Foundation
import CoreMotion
import CoreML
import SwiftUI


class VM: ObservableObject {
    @Published var isRecording = false
    
    @Published var predictedLabel = "Not yet predicted"
    
    @Published var predictedColor = Color.white
    
    private let motionManager = MotionManager()
    
    private let model: BoulderPredictor?
    
    private let scaler: StandardScaler
    
    static let viewModel = VM()
    
    private let extractor : Extractor
    
    private init() {
        
        scaler = StandardScaler()
        extractor = Extractor()
        
        do {
            let config = MLModelConfiguration()
            self.model = try BoulderPredictor(configuration: config)
            
        } catch {
            print("Model loading failed: \(error.localizedDescription)")
            self.model = nil

        }    }
    


    func startRecording() {
        isRecording = true
        motionManager.startRecording()
    }

    func stopRecording() {
        isRecording = false
        motionManager.stopRecording()
        
        let (accelerometerData , gyroData) = motionManager.getCollectedData()
        
        var signal = Signal()
        
        for (accelData, gyroData) in zip(accelerometerData, gyroData) {
            signal.addSample(s: Sample(accelData.acceleration.x,
                                       accelData.acceleration.y,
                                       accelData.acceleration.z,
                                       gyroData.rotationRate.x,
                                       gyroData.rotationRate.y,
                                       gyroData.rotationRate.z))
        }
        
        predict(signal: signal)
        
        
        
    }
    
    private func predict(signal: Signal){
        
        let featExt = extractor.extractFeatures(signal: signal)
        
        var inputScaled = [Double]()
        
        for (i, f) in featExt.enumerated() {
            inputScaled.append(scaler.scalePredict(value: f, i: i))
        }
        
        do{
            
            let input = BoulderPredictorInput(
                acc_x_mean: inputScaled[0],
                acc_y_mean: inputScaled[1],
                acc_z_mean: inputScaled[2],
                gyro_x_mean: inputScaled[3],
                gyro_y_mean: inputScaled[4],
                gyro_z_mean: inputScaled[5],
                acc_x_sd: inputScaled[6],
                acc_y_sd: inputScaled[7],
                acc_z_sd: inputScaled[8],
                gyro_x_sd: inputScaled[9],
                gyro_y_sd: inputScaled[10],
                gyro_z_sd: inputScaled[11],
                acc_x_aad: inputScaled[12],
                acc_y_aad: inputScaled[13],
                acc_z_aad: inputScaled[14],
                gyro_x_aad: inputScaled[15],
                gyro_y_aad: inputScaled[16],
                gyro_z_aad: inputScaled[17],
                acc_x_min: inputScaled[18],
                acc_y_min: inputScaled[19],
                acc_z_min: inputScaled[20],
                gyro_x_min: inputScaled[21],
                gyro_y_min: inputScaled[22],
                gyro_z_min: inputScaled[23],
                acc_x_max: inputScaled[24],
                acc_y_max: inputScaled[25],
                acc_z_max: inputScaled[26],
                gyro_x_max: inputScaled[27],
                gyro_y_max: inputScaled[28],
                gyro_z_max: inputScaled[29],
                acc_x_delta: inputScaled[30],
                acc_y_delta: inputScaled[31],
                acc_z_delta: inputScaled[32],
                gyro_x_delta: inputScaled[33],
                gyro_y_delta: inputScaled[34],
                gyro_z_delta: inputScaled[35],
                acc_x_median: inputScaled[36],
                acc_y_median: inputScaled[37],
                acc_z_median: inputScaled[38],
                gyro_x_median: inputScaled[39],
                gyro_y_median: inputScaled[40],
                gyro_z_median: inputScaled[41],
                acc_x_mad: inputScaled[42],
                acc_y_mad: inputScaled[43],
                acc_z_mad: inputScaled[44],
                gyro_x_mad: inputScaled[45],
                gyro_y_mad: inputScaled[46],
                gyro_z_mad: inputScaled[47],
                acc_x_interq_range: inputScaled[48],
                acc_y_interq_range: inputScaled[49],
                acc_z_interq_range: inputScaled[50],
                gyro_x_interq_range: inputScaled[51],
                gyro_y_interq_range: inputScaled[52],
                gyro_z_interq_range: inputScaled[53],
                acc_x_neg: inputScaled[54],
                acc_y_neg: inputScaled[55],
                acc_z_neg: inputScaled[56],
                gyro_x_neg: inputScaled[57],
                gyro_y_neg: inputScaled[58],
                gyro_z_neg: inputScaled[59],
                acc_x_pos: inputScaled[60],
                acc_y_pos: inputScaled[61],
                acc_z_pos: inputScaled[62],
                gyro_x_pos: inputScaled[63],
                gyro_y_pos: inputScaled[64],
                gyro_z_pos: inputScaled[65],
                acc_x_above_mean: inputScaled[66],
                acc_y_above_mean: inputScaled[67],
                acc_z_above_mean: inputScaled[68],
                gyro_x_above_mean: inputScaled[69],
                gyro_y_above_mean: inputScaled[70],
                gyro_z_above_mean: inputScaled[71],
                acc_x_peaks: inputScaled[72],
                acc_y_peaks: inputScaled[73],
                acc_z_peaks: inputScaled[74],
                gyro_x_peaks: inputScaled[75],
                gyro_y_peaks: inputScaled[76],
                gyro_z_peaks: inputScaled[77],
                acc_x_skewness: inputScaled[78],
                acc_y_skewness: inputScaled[79],
                acc_z_skewness: inputScaled[80],
                gyro_x_skewness: inputScaled[81],
                gyro_y_skewness: inputScaled[82],
                gyro_z_skewness: inputScaled[83],
                acc_x_kurtosis: inputScaled[84],
                acc_y_kurtosis: inputScaled[85],
                acc_z_kurtosis: inputScaled[86],
                gyro_x_kurtosis: inputScaled[87],
                gyro_y_kurtosis: inputScaled[88],
                gyro_z_kurtosis: inputScaled[89],
                acc_x_energy: inputScaled[90],
                acc_y_energy: inputScaled[91],
                acc_z_energy: inputScaled[92],
                gyro_x_energy: inputScaled[93],
                gyro_y_energy: inputScaled[94],
                gyro_z_energy: inputScaled[95],
                acc_x_mean_fft: inputScaled[96],
                acc_y_mean_fft: inputScaled[97],
                acc_z_mean_fft: inputScaled[98],
                gyro_x_mean_fft: inputScaled[99],
                gyro_y_mean_fft: inputScaled[100],
                gyro_z_mean_fft: inputScaled[101],
                acc_x_sd_fft: inputScaled[102],
                acc_y_sd_fft: inputScaled[103],
                acc_z_sd_fft: inputScaled[104],
                gyro_x_sd_fft: inputScaled[105],
                gyro_y_sd_fft: inputScaled[106],
                gyro_z_sd_fft: inputScaled[107],
                acc_x_aad_ftt: inputScaled[108],
                acc_y_aad_ftt: inputScaled[109],
                acc_z_aad_ftt: inputScaled[110],
                gyro_x_aad_ftt: inputScaled[111],
                gyro_y_aad_ftt: inputScaled[112],
                gyro_z_aad_ftt: inputScaled[113],
                acc_x_min_fft: inputScaled[114],
                acc_y_min_fft: inputScaled[115],
                acc_z_min_fft: inputScaled[116],
                gyro_x_min_fft: inputScaled[117],
                gyro_y_min_fft: inputScaled[118],
                gyro_z_min_fft: inputScaled[119],
                acc_x_max_fft: inputScaled[120],
                acc_y_max_fft: inputScaled[121],
                acc_z_max_fft: inputScaled[122],
                gyro_x_max_fft: inputScaled[123],
                gyro_y_max_fft: inputScaled[124],
                gyro_z_max_fft: inputScaled[125],
                acc_x_delta_fft: inputScaled[126],
                acc_y_delta_fft: inputScaled[127],
                acc_z_delta_fft: inputScaled[128],
                gyro_x_delta_fft: inputScaled[129],
                gyro_y_delta_fft: inputScaled[130],
                gyro_z_delta_fft: inputScaled[131],
                acc_x_median_fft: inputScaled[132],
                acc_y_median_fft: inputScaled[133],
                acc_z_median_fft: inputScaled[134],
                gyro_x_median_fft: inputScaled[135],
                gyro_y_median_fft: inputScaled[136],
                gyro_z_median_fft: inputScaled[137],
                acc_x_mad_fft: inputScaled[138],
                acc_y_mad_fft: inputScaled[139],
                acc_z_mad_fft: inputScaled[140],
                gyro_x_mad_fft: inputScaled[141],
                gyro_y_mad_fft: inputScaled[142],
                gyro_z_mad_fft: inputScaled[143],
                acc_x_interq_range_fft: inputScaled[144],
                acc_y_interq_range_fft: inputScaled[145],
                acc_z_interq_range_fft: inputScaled[146],
                gyro_x_interq_range_fft: inputScaled[147],
                gyro_y_interq_range_fft: inputScaled[148],
                gyro_z_interq_range_fft: inputScaled[149],
                acc_x_neg_fft: inputScaled[150],
                acc_y_neg_fft: inputScaled[151],
                acc_z_neg_fft: inputScaled[152],
                gyro_x_neg_fft: inputScaled[153],
                gyro_y_neg_fft: inputScaled[154],
                gyro_z_neg_fft: inputScaled[155],
                acc_x_pos_fft: inputScaled[156],
                acc_y_pos_fft: inputScaled[157],
                acc_z_pos_fft: inputScaled[158],
                gyro_x_pos_fft: inputScaled[159],
                gyro_y_pos_fft: inputScaled[160],
                gyro_z_pos_fft: inputScaled[161],
                acc_x_above_mean_fft: inputScaled[162],
                acc_y_above_mean_fft: inputScaled[163],
                acc_z_above_mean_fft: inputScaled[164],
                gyro_x_above_mean_fft: inputScaled[165],
                gyro_y_above_mean_fft: inputScaled[166],
                gyro_z_above_mean_fft: inputScaled[167],
                acc_x_peaks_fft: inputScaled[168],
                acc_y_peaks_fft: inputScaled[169],
                acc_z_peaks_fft: inputScaled[170],
                gyro_x_peaks_fft: inputScaled[171],
                gyro_y_peaks_fft: inputScaled[172],
                gyro_z_peaks_fft: inputScaled[173],
                acc_x_skewness_fft: inputScaled[174],
                acc_y_skewness_fft: inputScaled[175],
                acc_z_skewness_fft: inputScaled[176],
                gyro_x_skewness_fft: inputScaled[177],
                gyro_y_skewness_fft: inputScaled[178],
                gyro_z_skewness_fft: inputScaled[179],
                acc_x_kurtosis_fft: inputScaled[180],
                acc_y_kurtosis_fft: inputScaled[181],
                acc_z_kurtosis_fft: inputScaled[182],
                gyro_x_kurtosis_fft: inputScaled[183],
                gyro_y_kurtosis_fft: inputScaled[184],
                gyro_z_kurtosis_fft: inputScaled[185],
                acc_x_energy_fft: inputScaled[186],
                acc_y_energy_fft: inputScaled[187],
                acc_z_energy_fft: inputScaled[188],
                gyro_x_energy_fft: inputScaled[189],
                gyro_y_energy_fft: inputScaled[190],
                gyro_z_energy_fft: inputScaled[191],
                ara_acc: inputScaled[192],
                ara_gyro: inputScaled[193],
                ara_ftt_acc: inputScaled[194],
                ara_ftt_gyro: inputScaled[195],
                sma_acc: inputScaled[196],
                sma_gyro: inputScaled[197],
                sma_ftt_acc: inputScaled[198],
                sma_ftt_gyro: inputScaled[199]
            )
            
            let prediction = try model?.prediction(input: input)
            
            print(prediction?.labelProbability as Any)
            
            if let probabilities = prediction?.labelProbability {
                // Trova l'etichetta con la probabilità più alta
                if let (label, _) = probabilities.max(by: { $0.value < $1.value }) {
                    
                    switch String(label){
                    case "1":
                        predictedLabel = "Blue"
                        predictedColor = Color.blue
                        
                    case "2":
                        predictedLabel = "Green"
                        predictedColor = Color.green
                        
                    case "3":
                        predictedLabel = "Red"
                        predictedColor = Color.red
                     
                    default:
                        predictedLabel = ":("
                        predictedColor = Color.white
                        
                    }
                    
                } else {
                    predictedLabel = "Nessuna etichetta trovata"
                }
                
    
                
            } else {
                predictedLabel = "Errore: Nessuna predizione disponibile"
            }        }catch{
            
        }
        
    }
}
