//
//  WeatherService.swift
//  Clima
//
//  Created by Marcos Almeida on 2024-09-11.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherService: WeatherService, _ weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherService {
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(_ cityName: String) {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        print(urlString)
        performRequest(with: urlString)
    }
    
    // External name with just to be more readable
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: URLRequest(url: url)) {( data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = parseJSON(weatherData: safeData) {
                        self.delegate?.didUpdateWeather(self, weather)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            return WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}
