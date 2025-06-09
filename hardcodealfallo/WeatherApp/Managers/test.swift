

import Foundation
import CoreLocation

// MARK: - WeatherManager Principal
class WeatherManager2: ObservableObject {
    @Published var forecastData: ForecastResponseBody?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ForecastResponseBody {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast/daily?lat=\(latitude)&lon=\(longitude)&cnt=16&appid=2d11b37d22afc79490c1f9ef5a896161") else {
            fatalError("Missing URL")
        }
        
        let urlRequest = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            fatalError("Error while fetching data")
        }
        
        let decodedData = try JSONDecoder().decode(ForecastResponseBody.self, from: data)
        
        DispatchQueue.main.async {
            self.forecastData = decodedData
        }
        
        return decodedData
    }
    
    func loadWeatherData(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        Task {
            isLoading = true
            do {
                let forecast = try await getCurrentWeather(latitude: latitude, longitude: longitude)
                DispatchQueue.main.async {
                    self.forecastData = forecast
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    
    private func kelvinToCelsius(_ kelvin: Double) -> String {
        let celsius = kelvin - 273.15
        return String(format: "%.1f", celsius)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}

// MARK: - Modelos de datos
struct ForecastResponseBody: Decodable {
    var city: CityResponse
    var cod: String
    var message: Double
    var cnt: Int
    var list: [DailyForecast]
}

struct CityResponse: Decodable {
    var id: Int
    var name: String
    var coord: Coordinates
    var country: String
    var population: Int
    var timezone: Int
}

struct Coordinates: Decodable {
    var lon: Double
    var lat: Double
}

struct DailyForecast: Decodable {
    var dt: Int
    var sunrise: Int
    var sunset: Int
    var temp: TemperatureData
    var feels_like: FeelsLikeData
    var pressure: Int
    var humidity: Int
    var weather: [WeatherCondition]
    var speed: Double
    var deg: Int
    var gust: Double
    var clouds: Int
    var pop: Double
    var rain: Double?
}

struct TemperatureData: Decodable {
    var day: Double
    var min: Double
    var max: Double
    var night: Double
    var eve: Double
    var morn: Double
}

struct FeelsLikeData: Decodable {
    var day: Double
    var night: Double
    var eve: Double
    var morn: Double
}

struct WeatherCondition: Decodable {
    var id: Int
    var main: String
    var description: String
    var icon: String
}
