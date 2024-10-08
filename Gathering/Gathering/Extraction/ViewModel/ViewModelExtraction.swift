import Foundation

class ViewModelExtraction{
    static let vm =  ViewModelExtraction()
    let extractor = Extractor()
    
    let exporter = Exporter.exporter
    
    let scaler = StandardScaler.scaler
    
    var shareFile: (URL) -> Void = { _ in }
    
    private init(){}
    
    func setExporterClosure(closure: @escaping (URL) -> Void) {
        exporter.setClosure(closure: closure)
    }
    
    private func parseCSV(fileURL: URL) -> [Sample] {
        var samples = [Sample]()
        
        do {
            let data = try Data(contentsOf: fileURL)
            let content = String(decoding: data, as: UTF8.self)
            
            // Dividi il contenuto in righe
            let rows = content.split(separator: "\n")
            
            // Assumi che la prima riga sia l'intestazione e ignorala
            for row in rows.dropFirst() {
                let columns = row.split(separator: ",")
                guard columns.count == 7,
                      let accX = Double(columns[1]),
                      let accY = Double(columns[2]),
                      let accZ = Double(columns[3]),
                      let gyroX = Double(columns[4]),
                      let gyroY = Double(columns[5]),
                      let gyroZ = Double(columns[6]) else {
                    continue
                }
                
                let sample = Sample(accX, accY, accZ, gyroX, gyroY, gyroZ)
                samples.append(sample)
            }
        } catch {
            print("Error reading CSV file: \(error)")
        }
        
        return samples
    }
    
    //Crea il file di train con valori standardizzati e lo scrive su Filemanager
    func extractAndExport(csvFilesCollection: [[URL]]){
        /*
         1. Estrarre feature e creare matrice
         2. Trasporre
         3. Scalare
         4. Trasporre
         5. Creare il CSV
            5a. Aggiungere label
         6. Scrivere
         */
        
        scaler.flush() //libero da eventuali rimanenze
        
        //1.-------------
        
        var extractedFeature = [[Double]]()
        for urls in csvFilesCollection{
            for fileURL in urls{
                do {
                    let content = try String(contentsOf: fileURL, encoding: .utf8)
                    var signal = Signal()
                    let samples = parseCSV(fileURL: fileURL)
                    for sample in samples {
                        signal.addSample(s: sample)
                    }

                    extractedFeature.append(extractor.extractFeatures(signal: signal))
                    
                } catch {
                    print("Errore durante la lettura del file CSV: \(error.localizedDescription)")
                }
            }
            
            
            
        }
        print("Numero di esempi \(extractedFeature.count)")
        //2.-----------------
        let extractedFeatureT = matrixTranspose(extractedFeature)

        //3.-----------------
        
        var scaledExtractedFeatureT = [[Double]]()
        for i in 0...extractedFeatureT.count-1{
            scaledExtractedFeatureT.append(scaler.scale(values: extractedFeatureT[i]))
        }
      
        //4.-----------------
        let scaledExtractedFeature = matrixTranspose(scaledExtractedFeatureT)
     
        //5.-----------------
        var classNumber = 0
        
        var csvText = "acc_x_mean,acc_y_mean,acc_z_mean,gyro_x_mean,gyro_y_mean,gyro_z_mean,acc_x_sd,acc_y_sd,acc_z_sd,gyro_x_sd,gyro_y_sd,gyro_z_sd,acc_x_aad,acc_y_aad,acc_z_aad,gyro_x_aad,gyro_y_aad,gyro_z_aad,acc_x_min,acc_y_min,acc_z_min,gyro_x_min,gyro_y_min,gyro_z_min,acc_x_max,acc_y_max,acc_z_max,gyro_x_max,gyro_y_max,gyro_z_max,acc_x_delta,acc_y_delta,acc_z_delta,gyro_x_delta,gyro_y_delta,gyro_z_delta,acc_x_median,acc_y_median,acc_z_median,gyro_x_median,gyro_y_median,gyro_z_median,acc_x_mad,acc_y_mad,acc_z_mad,gyro_x_mad,gyro_y_mad,gyro_z_mad,acc_x_interq_range,acc_y_interq_range,acc_z_interq_range,gyro_x_interq_range,gyro_y_interq_range,gyro_z_interq_range,acc_x_neg,acc_y_neg,acc_z_neg,gyro_x_neg,gyro_y_neg,gyro_z_neg,acc_x_pos,acc_y_pos,acc_z_pos,gyro_x_pos,gyro_y_pos,gyro_z_pos,acc_x_above_mean,acc_y_above_mean,acc_z_above_mean,gyro_x_above_mean,gyro_y_above_mean,gyro_z_above_mean,acc_x_peaks,acc_y_peaks,acc_z_peaks,gyro_x_peaks,gyro_y_peaks,gyro_z_peaks,acc_x_skewness,acc_y_skewness,acc_z_skewness,gyro_x_skewness,gyro_y_skewness,gyro_z_skewness,acc_x_kurtosis,acc_y_kurtosis,acc_z_kurtosis,gyro_x_kurtosis,gyro_y_kurtosis,gyro_z_kurtosis,acc_x_energy,acc_y_energy,acc_z_energy,gyro_x_energy,gyro_y_energy,gyro_z_energy,acc_x_mean_fft,acc_y_mean_fft,acc_z_mean_fft,gyro_x_mean_fft,gyro_y_mean_fft,gyro_z_mean_fft,acc_x_sd_fft,acc_y_sd_fft,acc_z_sd_fft,gyro_x_sd_fft,gyro_y_sd_fft,gyro_z_sd_fft,acc_x_aad_ftt,acc_y_aad_ftt,acc_z_aad_ftt,gyro_x_aad_ftt,gyro_y_aad_ftt,gyro_z_aad_ftt,acc_x_min_fft,acc_y_min_fft,acc_z_min_fft,gyro_x_min_fft,gyro_y_min_fft,gyro_z_min_fft,acc_x_max_fft,acc_y_max_fft,acc_z_max_fft,gyro_x_max_fft,gyro_y_max_fft,gyro_z_max_fft,acc_x_delta_fft,acc_y_delta_fft,acc_z_delta_fft,gyro_x_delta_fft,gyro_y_delta_fft,gyro_z_delta_fft,acc_x_median_fft,acc_y_median_fft,acc_z_median_fft,gyro_x_median_fft,gyro_y_median_fft,gyro_z_median_fft,acc_x_mad_fft,acc_y_mad_fft,acc_z_mad_fft,gyro_x_mad_fft,gyro_y_mad_fft,gyro_z_mad_fft,acc_x_interq_range_fft,acc_y_interq_range_fft,acc_z_interq_range_fft,gyro_x_interq_range_fft,gyro_y_interq_range_fft,gyro_z_interq_range_fft,acc_x_neg_fft,acc_y_neg_fft,acc_z_neg_fft,gyro_x_neg_fft,gyro_y_neg_fft,gyro_z_neg_fft,acc_x_pos_fft,acc_y_pos_fft,acc_z_pos_fft,gyro_x_pos_fft,gyro_y_pos_fft,gyro_z_pos_fft,acc_x_above_mean_fft,acc_y_above_mean_fft,acc_z_above_mean_fft,gyro_x_above_mean_fft,gyro_y_above_mean_fft,gyro_z_above_mean_fft,acc_x_peaks_fft,acc_y_peaks_fft,acc_z_peaks_fft,gyro_x_peaks_fft,gyro_y_peaks_fft,gyro_z_peaks_fft,acc_x_skewness_fft,acc_y_skewness_fft,acc_z_skewness_fft,gyro_x_skewness_fft,gyro_y_skewness_fft,gyro_z_skewness_fft,acc_x_kurtosis_fft,acc_y_kurtosis_fft,acc_z_kurtosis_fft,gyro_x_kurtosis_fft,gyro_y_kurtosis_fft,gyro_z_kurtosis_fft,acc_x_energy_fft,acc_y_energy_fft,acc_z_energy_fft,gyro_x_energy_fft,gyro_y_energy_fft,gyro_z_energy_fft,ara_acc,ara_gyro,ara_ftt_acc,ara_ftt_gyro,sma_acc,sma_gyro,sma_ftt_acc,sma_ftt_gyro,label\n"
        
        var index = 0
        for urls in csvFilesCollection{
            classNumber+=1
            for _ in 0...urls.count-1{
                //aggiunge tutti i valori
                for value in scaledExtractedFeature[index]{
                    csvText+=String(value)+","
                }
                //aggiunge la label
                csvText+=String(classNumber)+"\n"
                index+=1
            }
        }
        //6.-------------------
        exporter.exportData(name: "trainSet.csv", text: csvText)
    }
    
    private func matrixTranspose<T>(_ matrix: [[T]]) -> [[T]] {
        if matrix.isEmpty {return matrix}
        var result = [[T]]()
        for index in 0..<matrix.first!.count {
            result.append(matrix.map{$0[index]})
        }
        return result
    }
    
    func exportStdDev(){
        let array = scaler.getStdDevs()
        var text = "["
        for val in array{
            text+=String(val)+","
        }
        text = String(text.dropLast())
        text+="]"
        exporter.exportData(name: "stdDev.txt", text: text)
        
    }
    
    func exportMeans(){
        let array = scaler.getMeans()
        var text = "["
        for val in array{
            text+=String(val)+","
        }
        text = String(text.dropLast())
        text+="]"
        exporter.exportData(name: "means.txt", text: text)
        
    }
    
}
