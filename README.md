# BikeWorkoutHealthKitMac

A native macOS app that fetches bike workout data from a REST API and saves it to Apple Health with heart rate, cadence, and resistance metrics.

## Features

- 🖥️ Native macOS app (Big Sur and later)
- 🔌 REST API integration for workout data
- ❤️ Heart rate tracking and sync to Apple Health
- 🚴 Cadence (RPM) tracking
- 💪 Resistance level tracking
- 📊 Real-time workout statistics display
- 📈 Detailed metrics dashboard
- 🔐 Secure HealthKit authorization
- ✨ Modern SwiftUI interface with tabbed navigation

## Requirements

- macOS 12.0+ (Monterey or later)
- Xcode 14.0+
- Apple Health app integration

## Installation

1. Clone the repository:
```bash
git clone https://github.com/dominikjungo/BikeWorkoutHealthKitMac.git
cd BikeWorkoutHealthKitMac
```

2. Open the project in Xcode:
```bash
open BikeWorkoutHealthKitMac.xcodeproj
```

3. Build and run on macOS (12.0+):
   - Select your Mac as the target
   - Press ⌘R to run

## API Integration

The app expects a REST API endpoint that returns workout data in the following JSON format:

```json
{
  "duration": 1800,
  "distance": 15.5,
  "average_heart_rate": 145,
  "average_cadence": 95,
  "average_resistance": 0.75,
  "start_date": "2024-09-08T10:00:00Z",
  "end_date": "2024-09-08T10:30:00Z",
  "heart_rate_samples": [
    {
      "timestamp": "2024-09-08T10:00:00Z",
      "value": 140
    }
  ],
  "cadence_samples": [
    {
      "timestamp": "2024-09-08T10:00:00Z",
      "value": 90
    }
  ],
  "resistance_samples": [
    {
      "timestamp": "2024-09-08T10:00:00Z",
      "value": 0.7
    }
  ]
}
```

## Health Metrics

### Heart Rate
- Stored in Apple Health as "Heart Rate" (unit: bpm)
- Associated with the cycling workout

### Cadence
- Stored in Apple Health as "Cycling Cadence" (unit: rpm)
- Represents pedal rotations per minute

### Resistance
- Stored in Apple Health as "Cycling Functional Threshold Power" (unit: watts)
- Resistance values (0-1) are scaled to watts (0-500W) for compatibility

## Usage

1. Grant HealthKit permissions when prompted
2. Enter your REST API endpoint URL in the app
3. Click "Fetch & Sync" to fetch data and sync to Apple Health
4. View detailed metrics in the "Details" tab
5. Monitor sync status in the "Status" tab

## User Interface

The app features a clean, tabbed interface:

### Sync Tab
- API URL configuration
- Quick sync button with loading indicator
- Easy-to-use form-based layout

### Details Tab
- Comprehensive workout summary with visual stat cards
- Detailed metrics breakdown
- Sample count information
- Formatted dates and times

### Status Tab
- HealthKit authorization status
- Last sync timestamp
- Authorization request button

## Architecture

- **Views**: SwiftUI components for the user interface
- **ViewModels**: `WorkoutViewModel` handles business logic and state
- **Services**: 
  - `HealthKitManager`: Handles HealthKit authorization and data saving
  - `APIClient`: Manages REST API communication with error handling
- **Models**: Data structures for workouts and metrics

## Error Handling

The app includes comprehensive error handling for:
- HealthKit authorization failures
- Network/API errors with detailed messages
- Invalid or malformed data
- Device compatibility issues
- HTTP status code errors

## Privacy & Security

- Health data is only written to Apple Health with explicit user permission
- No health data is stored locally or transmitted outside the device (except when fetching from the configured API)
- All HealthKit operations follow Apple's privacy guidelines
- App uses secure URL sessions with proper request headers

## Keyboard Shortcuts

- ⌘, - Open Preferences

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.

## Troubleshooting

### HealthKit Authorization Not Working
- Ensure you have granted the app HealthKit permissions in System Preferences > Security & Privacy
- Try clicking "Request Authorization" in the Status tab

### API Connection Errors
- Verify the API endpoint URL is correct
- Check your network connection
- Ensure the API server is running and accessible
- Check for any firewall or proxy settings

### Data Not Syncing
- Verify the JSON format matches the expected schema
- Check the app's error message for specific issues
- Ensure all required fields are present in the API response
