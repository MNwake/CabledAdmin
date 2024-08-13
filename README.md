# Cabled Admin App

Welcome to the repository for the Cabled Admin App. This mobile application is designed for our admin team to efficiently manage events, users, and real-time data during cable wakeboarding competitions. The app connects to the Python backend to facilitate changes that are then reflected in the user-facing frontend app.

## Overview

The Cabled Admin App is written in Swift and serves multiple administrative purposes:

- **User Management**: Create new users, update user photos and bios, and delete users.
- **Event Management**: Manage riders on the cable to ensure judges have accurate information.
- **Judging**: Record tricks performed by riders and assign value scores in real-time.

The app communicates with the backend via HTTPS requests and WebSockets to ensure real-time data synchronization and updates.

## Features

### User Management

- **Create Users**: Add new users to the system.
- **Update Users**: Modify user information, including photos and bios.
- **Delete Users**: Remove users from the system.

### Event Management

- **Rider Management**: Dockhands can manage riders on the cable, providing accurate information to the judges during events.
- **Real-time Updates**: Information is sent to the backend in real-time to ensure all participants and spectators have the latest data.

### Judging

- **Trick Recording**: Judges can record the tricks performed by each rider.
- **Scoring**: Assign value scores to tricks, which are then sent to the backend.

## Data Synchronization

- **HTTPS Requests**: Fetch and update data by making secure HTTPS requests to the backend API.
- **WebSockets**: Ensure real-time data updates through WebSocket connections.

## Installation

### Prerequisites

- iOS device with iOS 13.0+
- Xcode 12.0+
- Swift 5.0+

### Setup

1. **Clone the repository**:
    ```sh
    git clone https://github.com/MNwake/CabledAdmin.git
    cd CabledAdmin
    ```

2. **Open the project in Xcode**:
    - Open `CWA.xcodeproj` in Xcode.

3. **Install dependencies** (if using any dependency manager like CocoaPods or Swift Package Manager):
    - For CocoaPods:
        ```sh
        pod install
        ```
    - For Swift Package Manager, dependencies will be resolved automatically when you open the project in Xcode.

4. **Build and run the project**:
    - Select your target device or simulator.
    - Press `Command + R` to build and run the project.

## Usage

- **User Management**: Navigate to the user management section to create, update, or delete users.
- **Event Management**: Use the event management features to handle rider information during events.
- **Judging**: Record tricks and assign scores in real-time.

## Disclaimer

This admin app is part of an ongoing project to develop a comprehensive system for cable wakeboard parks. It is a work in progress and may not be fully functional. For the most current version of the Cabled app, please refer to the Apple App Store.

