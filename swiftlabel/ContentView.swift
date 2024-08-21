import SwiftUI
import MapKit

// Function to load color from plist
func loadColor(from plist: String, key: String) -> Color {
    guard let path = Bundle.main.path(forResource: plist, ofType: "plist"),
          let xml = FileManager.default.contents(atPath: path),
          let plist = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil) as? [String: Any],
          let hexString = plist[key] as? String else {
        return Color.blue // Default color if loading fails
    }
    return Color(hex: hexString) ?? Color.blue
}

// Function to load configuration data from plist
func loadConfig(from plist: String = "Config") -> (hotelName: String, description: String, amenities: [String], country: String, city: String) {
    guard let path = Bundle.main.path(forResource: plist, ofType: "plist"),
          let xml = FileManager.default.contents(atPath: path),
          let plist = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil) as? [String: Any],
          let hotelName = plist["hotelName"] as? String,
          let description = plist["hotelDescription"] as? String,
          let amenities = plist["amenities"] as? [String],
          let country = plist["hotelCountry"] as? String,
          let city = plist["hotelCity"] as? String else {
        return ("Default Hotel", "", [], "Unknown Country", "Unknown City") // Default values if loading fails
    }
    return (hotelName, description, amenities, country, city)
}

// Extension to create Color from hex string
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

import SwiftUI
import MapKit

struct InfoCardView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showLocationView = false

    var hotelName: String
    var description: String
    var amenities: [String]
    var city: String
    var country: String
    var rating: Double = 4.92
    var reviews: Int = 179
    var backgroundColor: Color = loadColor(from: "Config", key: "backgroundColor")

    init() {
        let config = loadConfig()
        self.hotelName = config.hotelName
        self.description = config.description
        self.amenities = config.amenities
        self.city = config.city
        self.country = config.country
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Top section
                VStack(alignment: .leading) {
                    Image("header")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipped()
                        .mask(RoundedCorners(tl: 0, tr: 0, bl: 30, br: 30))
                        .edgesIgnoringSafeArea(.top)
                        .padding(.top, -60)
                    
                    Text(hotelName)
                        .font(.largeTitle)
                        .foregroundColor(.black) // Ensure text is visible
                        .padding(.bottom, 2)
                        .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.black)
                        Button(action: {
                            showLocationView = true // Trigger the presentation of LocationView
                        }) {
                            Text("\(city), \(country)") // Use the loaded hotel city and country here
                                .font(.subheadline)
                                .foregroundColor(.blue) // Make it look like a link
                        }
                    }
                    .padding(.bottom, 1)
                    .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                        Text(String(format: "%.2f", rating))
                            .font(.subheadline)
                            .foregroundColor(.black) // Ensure text is visible
                        Text("(\(reviews) reviews)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                
                // Amenities section
                Text("Amenities")
                    .font(.headline)
                    .foregroundColor(.black) // Ensure text is visible
                    .padding(.bottom, 5)
                    .padding(.horizontal)
                
                FlowLayout(items: amenities)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .foregroundColor(.black) // Ensure text in amenities is dark
                
                Divider()
                
                // Description section
                Text("Description")
                    .font(.headline)
                    .foregroundColor(.black) // Ensure text is visible
                    .padding(.bottom, 5)
                    .padding(.horizontal)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.black) // Ensure text is visible
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                
                Spacer()
                
                // Dismiss button
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Dismiss")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(backgroundColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding(.bottom, 150)
            .background(Color.white) // Set background color to white
        }
        .fullScreenCover(isPresented: $showLocationView) {
            LocationView()
        }
    }
}


struct HomeView: View {
    @State private var showInfoCard = false
    @State private var showLocationView = false
    @State private var hotelName: String = ""
    @State private var hotelCity: String = ""
    @State private var hotelCountry: String = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color from plist
                loadColor(from: "Config", key: "backgroundColor")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Image("header")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height / 1.7)
                        .clipped()
                        .edgesIgnoringSafeArea(.top)
                        .mask(
                            RoundedCorners(tl: 0, tr: 0, bl: 30, br: 30)
                        )
                    
                    // Middle third with text
                    VStack {
                        Spacer()
                        Text(hotelName) // Use the loaded hotel name here
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(10)
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.white)
                            Button(action: {
                                showLocationView = true // Show the LocationView when tapped
                            }) {
                                Text("\(hotelCity), \(hotelCountry)") // Use the loaded hotel city and country here
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                        }
                        Spacer()
                    }
                    .frame(height: geometry.size.height / 7)
                    
                    // Bottom third with button
                    VStack {
                        Spacer()
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            showInfoCard = true
                        }) {
                            Text("More Info")
                                .font(.system(size: 14))
                                .fontWeight(.medium)
                                .padding(10)
                                .frame(width: geometry.size.width * 0.3)
                                .foregroundColor(.white)  // Set text color to white
                                .background(Color.clear)  // Set background to clear to remove any fill
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white, lineWidth: 2)  // White outline with 2px thickness
                                )
                                .cornerRadius(25)
                        }
                        .fullScreenCover(isPresented: $showInfoCard) {
                            InfoCardView()
                        }
                        Spacer() // to center the button in the bottom third
                    }
                    .frame(height: geometry.size.height / 3)
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            let config = loadConfig()
            hotelName = config.hotelName // Load the hotel name when the view appears
            hotelCity = config.city // Load the hotel city when the view appears
            hotelCountry = config.country // Load the hotel country when the view appears
        }
        .fullScreenCover(isPresented: $showLocationView) {
            LocationView()
        }
    }
}

// Custom shape for rounded corners
struct RoundedCorners: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.size.width
        let height = rect.size.height

        // Top left corner
        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addQuadCurve(to: CGPoint(x: tl, y: 0), control: CGPoint(x: 0, y: 0))

        // Top right corner
        path.addLine(to: CGPoint(x: width - tr, y: 0))
        path.addQuadCurve(to: CGPoint(x: width, y: tr), control: CGPoint(x: width, y: 0))

        // Bottom right corner
        path.addLine(to: CGPoint(x: width, y: height - br))
        path.addQuadCurve(to: CGPoint(x: width - br, y: height), control: CGPoint(x: width, y: height))

        // Bottom left corner
        path.addLine(to: CGPoint(x: bl, y: height))
        path.addQuadCurve(to: CGPoint(x: 0, y: height - bl), control: CGPoint(x: 0, y: height))

        return path
    }
}

struct FlowLayout: View {
    let items: [String]
    let spacing: CGFloat = 5
    var pillColor: Color = loadColor(from: "Config", key: "pillColor")
    var pillTextColor: Color = loadColor(from: "Config", key: "pillTextColor")

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(self.rows(), id: \.self) { rowItems in
                HStack(spacing: spacing) {
                    ForEach(rowItems, id: \.self) { item in
                        Text(item)
                            .font(.system(size: 12))
                            .foregroundColor(pillTextColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(pillColor)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }

    private func rows() -> [[String]] {
        var rows: [[String]] = [[]]
        var currentWidth: CGFloat = 0
        let screenWidth = UIScreen.main.bounds.width

        for item in items {
            let itemWidth = item.size(withAttributes: [.font: UIFont.systemFont(ofSize: 12)]).width + 16 + 8 // Text width + padding

            if currentWidth + itemWidth + spacing > screenWidth {
                rows.append([item])
                currentWidth = itemWidth
            } else {
                rows[rows.count - 1].append(item)
                currentWidth += itemWidth + spacing
            }
        }

        return rows
    }
}

struct LocationView: View {
    @Environment(\.presentationMode) var presentationMode

    struct LocationData: Codable {
        let latitude: Double
        let longitude: Double
        let hotelName: String?
    }

    static func loadLocationData() -> LocationData {
        if let url = Bundle.main.url(forResource: "Config", withExtension: "plist") {
            print("Found Config.plist")
            if let data = try? Data(contentsOf: url) {
                print("Loaded data from Config.plist")

                do {
                    let decoder = PropertyListDecoder()
                    let locationData = try decoder.decode(LocationData.self, from: data)
                    print("Decoded LocationData: \(locationData)")
                    return locationData
                } catch {
                    print("Failed to decode LocationData: \(error.localizedDescription)")
                }
            } else {
                print("Failed to load data from Config.plist")
            }
        } else {
            print("Config.plist not found")
        }
        // Fallback data if plist data is not available
        return LocationData(latitude: 47.51504562696981, longitude: 19.077860508882107, hotelName: "Fallback Location")
    }

    let locationData: LocationData = LocationView.loadLocationData()

    var body: some View {
        ZStack(alignment: .topLeading) {
            Map(initialPosition: .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locationData.latitude, longitude: locationData.longitude), span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)))) {
                Marker(locationData.hotelName ?? "Default Marker", systemImage: "building", coordinate: CLLocationCoordinate2D(latitude: locationData.latitude, longitude: locationData.longitude))
            }
            .mapStyle(.hybrid)
            .edgesIgnoringSafeArea(.all)

            // Back button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(1.0))
                    .clipShape(Circle())
            }
            .padding([.top, .leading], 16)
        }
    }
}

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
}

