//
//  WeatherManager.swift
//  Clima
//
//  Created by Sadık Çoban on 18.08.2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, wm: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    var delegate: WeatherManagerDelegate?
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=30ae196843c4cbc2a62e171c5021eb6b&units=metric"
    
    func fetchWeather(cityName: String)  {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    
    func fetchWeather(latitude: Double, longtitude: Double)  {
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longtitude)"
        performRequest(with: urlString)
    }
    
    
    func performRequest(with urlString: String){
        if let url = URL(string: urlString) {
            //create session
           let session = URLSession(configuration: .default)
            //create task
            let task =  session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJson(safeData) {
                        self.delegate?.didUpdateWeather(self, wm: weather)
                    }
                }

            }
            //start task
            task.resume()
        }
    }
    
    func parseJson(_ weatherData: Data)->WeatherModel?{
        let decoder = JSONDecoder()
        do {
           let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch  {
            delegate?.didFailWithError(error: error)
            return  nil
        }
        
    }
    
    
  
}
