import SwiftUI
let latitudee = 25.6866
let longitudee = -100.3161

struct TestView: View {
    @StateObject private var weatherManager = WeatherManager2()
    
    // Estado para manejar los bordes personalizados
    @State private var cellBorders: [String: Color] = [:]
    @State private var showCellSelector = false
    @State private var showDataInfo = false
    @State private var selectedDayIndex = 0
    @State private var selectedHourIndex = 0
    
    
    
    // Opciones para los pickers
    private let dayOptions = ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"]
    private let hourOptions = Array(1...24).map { "\($0):00" }
    
    // Coordenadas de ubicación
    let latitude: Double
    let longitude: Double
    
    // Configuración de rangos de temperatura (EDITABLE)
    private let temperatureRanges: [(range: ClosedRange<Double>, color: Color, name: String)] = [
        (-10...5, Color(red: 0.7, green: 0.85, blue: 1.0), "Muy Frío"),      // Azul pastel
        (5...15, Color(red: 0.8, green: 0.9, blue: 0.95), "Frío"),           // Azul claro pastel
        (15...25, Color(red: 0.9, green: 0.95, blue: 0.8), "Templado"),      // Verde pastel
        (25...30, Color(red: 1.0, green: 0.9, blue: 0.7), "Cálido"),         // Amarillo pastel
        (30...40, Color(red: 1.0, green: 0.8, blue: 0.7), "Caliente")        // Naranja pastel
    ]
    
    // FUNCIÓN PARA CAMBIAR EL COLOR DEL PERÍMETRO
    func changeCellBorderColor(fila: Int, columna: Int, color: Color) {
        let key = "\(fila)-\(columna)"
        cellBorders[key] = color
    }
    
    // FUNCIÓN PARA CAMBIAR BORDE DESDE INPUT DEL USUARIO
    func changeBorderFromInput() {
        // selectedDayIndex ya está en formato 0-6 (columna)
        // selectedHourIndex ya está en formato 0-23 (fila)
        let columna = selectedDayIndex
        let fila = selectedHourIndex
        
        changeCellBorderColor(fila: fila, columna: columna, color: .black)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header con información de ubicación
            
            
            // Estados de carga y error
            if weatherManager.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.2)
                    Text("Cargando datos del clima...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
            } else if let error = weatherManager.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("Error al cargar datos")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Reintentar") {
                        weatherManager.loadWeatherData(latitude: latitude, longitude: longitude)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            } else if let data = weatherManager.forecastData {
                // Calendario de temperaturas
                WeatherCalendarView(
                    data: data,
                    temperatureRanges: temperatureRanges,
                    cellBorders: $cellBorders,
                    changeBorderColor: changeCellBorderColor
                )
                
                // Controles para cambiar bordes
                VStack(spacing: 8) {
                    Text("Cambiar borde de celda:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 12) {
                        Button("Seleccionar Celda") {
                            showCellSelector = true
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(6)
                        
                        Button("Limpiar") {
                            cellBorders.removeAll()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                
            } else {
                // Estado inicial - cargando automáticamente
                VStack(spacing: 20) {
                    Image(systemName: "thermometer.sun")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Preparando datos del clima...")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                }
                .padding()
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        // Cargar datos automáticamente al aparecer
        .onAppear {
            if weatherManager.forecastData == nil && !weatherManager.isLoading {
                weatherManager.loadWeatherData(latitude: latitude, longitude: longitude)
            }
        }
        
        .sheet(isPresented: $showDataInfo){
            if #available(iOS 16.0, *) {
        
                
                VStack(spacing: 20) {
                    HStack {
                        Text("Detalles del día agendado")
                            .font(.title)
                            .bold()
                        Spacer()
                    }
                        
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 16) {
                        
                        // 1. Clima general
                        HStack {
                            Image(systemName: "cloud.sun") // icono placeholder
                            Text("Promedio: 30°C")
                            

                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)

                        // 2. Humedad
                        HStack {
                            Image(systemName: "humidity") // icono placeholder
                            Text("Humedad: 78%") // reemplaza con tu variable
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)

                        // 3. Temp mínima y máxima
                        HStack {
                            Image(systemName: "thermometer") // icono placeholder
                            Text("Min: 25°C / Máx: 34°C") // reemplaza con tus variables
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                        

                        // 4. Sensación térmica
                        HStack {
                            Image(systemName: "thermometer.sun") // icono placeholder
                            Text("Sensación: 32°C") // reemplaza con tu variable
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                        

                        // 5. Probabilidad de lluvia
                        HStack {
                            Image(systemName: "cloud.rain") // icono placeholder
                            Text("Lluvia: 10%") // reemplaza con tu variable
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                        
                        // 6. Velocidad del viento
                        HStack {
                            Image(systemName: "wind") // icono placeholder
                            Text("Vientos: 2.3 km/h") // reemplaza con tu variable
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                        
                        HStack {
                            Image(systemName: "carbon.dioxide.cloud") // icono placeholder
                            Text("Contaminación 858 ppb") // reemplaza con tu variable
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }
                }
                .padding()

            }
            
        }
        
        .sheet(isPresented: $showCellSelector) {
            if #available(iOS 16.0, *) {
                VStack(spacing: 20) {
                    Text("Seleccionar Celda")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)
                    
                    Text("Elige el día y la hora para cambiar el borde a negro")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 20) {
                        // Lista scrolleable de días
                        VStack(spacing: 8) {
                            Text("Día")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            ScrollView {
                                LazyVStack(spacing: 4) {
                                    ForEach(0..<dayOptions.count, id: \.self) { index in
                                        Button(action: {
                                            selectedDayIndex = index
                                        }) {
                                            HStack {
                                                Text(dayOptions[index])
                                                    .font(.system(size: 16))
                                                    .foregroundColor(selectedDayIndex == index ? .white : .primary)
                                                Spacer()
                                                if selectedDayIndex == index {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(selectedDayIndex == index ? Color.blue : Color.gray.opacity(0.1))
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                            .frame(height: 180)
                            .frame(maxWidth: 140)
                        }
                        
                        // Lista scrolleable de horas
                        VStack(spacing: 8) {
                            Text("Hora")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            ScrollView {
                                LazyVStack(spacing: 4) {
                                    ForEach(0..<hourOptions.count, id: \.self) { index in
                                        Button(action: {
                                            selectedHourIndex = index
                                        }) {
                                            HStack {
                                                Text(hourOptions[index])
                                                    .font(.system(size: 16))
                                                    .foregroundColor(selectedHourIndex == index ? .white : .primary)
                                                Spacer()
                                                if selectedHourIndex == index {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(selectedHourIndex == index ? Color.blue : Color.gray.opacity(0.1))
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                            .frame(height: 180)
                            .frame(maxWidth: 100)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Previsualización de la selección
                    Text("Seleccionado: \(dayOptions[selectedDayIndex]) a las \(hourOptions[selectedHourIndex])")
                        .font(.subheadline)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    // Botones
                    HStack(spacing: 20) {
                        Button("Cancelar") {
                            showCellSelector = false
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                        
                        Button("Guardar evento") {
                            changeBorderFromInput()
                            showCellSelector = false
                            showDataInfo = true
                            
                            
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

struct WeatherCalendarView: View {
    let data: ForecastResponseBody
    let temperatureRanges: [(range: ClosedRange<Double>, color: Color, name: String)]
    @Binding var cellBorders: [String: Color]
    let changeBorderColor: (Int, Int, Color) -> Void
    
    private let hours = Array(0...23)
    private let daysOfWeek = ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Información de la ciudad
                VStack(spacing: 4) {
                    Text(data.city.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(data.city.country)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Leyenda de colores
                ColorLegendView(temperatureRanges: temperatureRanges)
                
                // Calendario en ScrollView horizontal para mejor visualización
                ScrollView(.horizontal, showsIndicators: true) {
                    VStack(spacing: 0) {
                        // Encabezado con días de la semana
                        HStack(spacing: 0) {
                            // Espacio para las etiquetas de horas
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 50)
                            
                            // Días de la semana
                            ForEach(0..<min(7, data.list.count), id: \.self) { dayIndex in
                                VStack(spacing: 2) {
                                    Text(getDayOfWeek(for: data.list[dayIndex].dt))
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    Text(getFormattedDate(data.list[dayIndex].dt))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 60)
                            }
                        }
                        .padding(.bottom, 8)
                        
                        // Filas de horas (24 horas)
                        ForEach(hours, id: \.self) { hour in
                            HStack(spacing: 0) {
                                // Etiqueta de la hora
                                Text(String(format: "%02d:00", hour))
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .frame(width: 50, alignment: .leading)
                                
                                // Celdas de temperatura para cada día
                                ForEach(0..<min(7, data.list.count), id: \.self) { dayIndex in
                                    let forecast = data.list[dayIndex]
                                    let temperature = getTemperatureForHour(forecast: forecast, hour: hour)
                                    
                                    TemperatureCellView(
                                        temperature: temperature,
                                        temperatureRanges: temperatureRanges,
                                        hour: hour,
                                        row: hour,
                                        column: dayIndex,
                                        cellBorders: cellBorders
                                    )
                                    .onTapGesture {
                                        // Ejemplo de uso: tap para cambiar borde a naranja
                                        changeBorderColor(hour, dayIndex, .orange)
                                    }
                                }
                            }
                            .frame(height: 25)
                        }
                    }
                    .padding(.horizontal)
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                Spacer(minLength: 20)
            }
            .padding()
        }
    }
    
    // Obtener temperatura para una hora específica basada en períodos
    private func getTemperatureForHour(forecast: DailyForecast, hour: Int) -> Double {
        switch hour {
        case 4...11:  // Mañana (4 AM - 11 AM)
            return forecast.temp.morn - 273.15
        case 12...19: // Tarde (12 PM - 7 PM)
            return forecast.temp.day - 273.15
        case 20...23, 0...3: // Noche (8 PM - 3 AM)
            return forecast.temp.night - 273.15
        default:
            return forecast.temp.day - 273.15
        }
    }
    
    // Obtener día de la semana
    private func getDayOfWeek(for timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date).capitalized
    }
    
    // Obtener fecha formateada
    private func getFormattedDate(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "d/M"
        return formatter.string(from: date)
    }
}

struct TemperatureCellView: View {
    let temperature: Double
    let temperatureRanges: [(range: ClosedRange<Double>, color: Color, name: String)]
    let hour: Int
    let row: Int
    let column: Int
    let cellBorders: [String: Color]
    
    var body: some View {
        Rectangle()
            .fill(temperatureColor)
            .frame(width: 60, height: 25)
            .overlay(
                // Solo mostrar temperatura en horas específicas para no saturar
                Group {
                    if hour % 4 == 0 { // Mostrar cada 4 horas
                        Text("\(Int(temperature.rounded()))°")
                            .font(.system(size: 8))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                }
            )
            .border(borderColor, width: borderWidth)
    }
    
    // Determinar color basado en rangos de temperatura
    private var temperatureColor: Color {
        for (range, color, _) in temperatureRanges {
            if range.contains(temperature) {
                return color
            }
        }
        // Color por defecto si no coincide con ningún rango
        return Color.gray.opacity(0.3)
    }
    
    // Determinar color del borde
    private var borderColor: Color {
        let key = "\(row)-\(column)"
        return cellBorders[key] ?? Color.gray.opacity(0.2)
    }
    
    // Determinar grosor del borde
    private var borderWidth: CGFloat {
        let key = "\(row)-\(column)"
        return cellBorders[key] != nil ? 2.0 : 0.5
    }
}

struct ColorLegendView: View {
    let temperatureRanges: [(range: ClosedRange<Double>, color: Color, name: String)]
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Leyenda de Temperaturas")
                .font(.caption)
                .fontWeight(.semibold)
            
            HStack(spacing: 8) {
                ForEach(Array(temperatureRanges.enumerated()), id: \.offset) { item in
                    let (range, color, name) = item.element
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(color)
                            .frame(width: 30, height: 20)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        Text(name)
                            .font(.caption2)
                            .fontWeight(.medium)
                        
                        Text("\(Int(range.lowerBound))° a \(Int(range.upperBound))°")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Información adicional
            VStack(spacing: 2) {
                Text("Períodos del día:")
                    .font(.caption2)
                    .fontWeight(.medium)
                HStack(spacing: 12) {
                    Label("Mañana: 4:00-11:00", systemImage: "sunrise")
                    Label("Tarde: 12:00-19:00", systemImage: "sun.max")
                    Label("Noche: 20:00-3:00", systemImage: "moon")
                }
                .font(.system(size: 9))
                .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    TestView(latitude: 25.077, longitude: longitudee)
}
