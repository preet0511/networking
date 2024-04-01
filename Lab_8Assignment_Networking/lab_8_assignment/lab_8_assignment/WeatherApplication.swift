

import UIKit
import Foundation

class ViewController: UIViewController, Error {

    var weather = ["Rain","Clear", "Clouds"]
    var keyID = ""
    let country = "ca"
    let city = "Waterloo"
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var wind: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var weatherType: UILabel!
    @IBOutlet weak var location: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyID = Bundle.main.object(forInfoDictionaryKey: "KeyID") as! String
        startLoad()
    }
    
    // Structs of Structs
    // MARK: - Everything
    struct Everything: Codable {
        let coord: Coord
        let weather: [Weather]
        let base: String
        let main: Main
        let visibility: Int
        let wind: Wind
        let clouds: Clouds
        let dt: Int
        let sys: Sys
        let timezone, id: Int
        let name: String
        let cod: Int
    }
    
    // MARK: - Clouds
    struct Clouds: Codable {
        let all: Int
    }

    // MARK: - Coord
    struct Coord: Codable {
        let lon, lat: Double
    }

    // MARK: - Main
    struct Main: Codable {
        let temp, feels_like, temp_min, temp_max: Double
        let pressure, humidity: Int
    }
    // MARK: - Sys
    struct Sys: Codable {
        let type, id: Int
        let country: String
        let sunrise, sunset: Int
    }

    // MARK: - Weather
    struct Weather: Codable {
        let id: Int
        let main, description, icon: String
    }
    
    // MARK: - Wind
    struct Wind: Codable {
        let speed: Double
        let deg: Int
    }
    // calling api
    func startLoad() {
        let str_url = String(format:"https://api.openweathermap.org/data/2.5/weather?q=%@,%@&appid=%@&units=metric", city, country, keyID)
        let urlSession = URLSession(configuration:.default)
        let url = URL(string: str_url)!
        let task = urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Client failed to send request", error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                print("Failed Response from Server", error ?? 500)
                return
            }
            if let data = data {
            let jsonDecoder = JSONDecoder()
            do {
                let weatherData = try jsonDecoder.decode(Everything.self, from: data)
                DispatchQueue.main.async {
                    self.weatherType.text = weatherData.weather[0].main
                    self.location.text = weatherData.name
                    self.temperature.text = String(format: "%.1f °", weatherData.main.temp)
                    self.humidity.text = String(weatherData.main.humidity) + " %"
                    self.wind.text = String(format: "%.2f km/h", weatherData.wind.speed * 3.6)
                    if let index = self.weather.firstIndex(of: weatherData.weather[0].main) {
                        self.weatherIcon.image = UIImage(named: self.weather[index])
                    }
                }
            }
            catch {
                print ("Issue While decoding Weather data", error)
            }
        }
           
        }
        task.resume()
    }
  
}
