import Foundation

struct DataSource {
    let command: String
    let description: String
}

struct DataSourcesConfig {
    static let sources: [String: DataSource] = [
        "currentTime": DataSource(
            command: "date '+%H:%M:%S'",
            description: "Returns the current time in HH:MM:SS format"
        ),
        "cpuUsage": DataSource(
            command: "top -l 1 | grep \"CPU usage\" | awk '{print $3 + $5}'",
            description: "Returns the current, total CPU usage as a percentage"
        )
    ]
}
