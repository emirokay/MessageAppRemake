
# WhatsApp Clone
A SwiftUI-based iOS application designed to replicate the core features of WhatsApp, focusing on real-time messaging, user profiles, and chat management. The project is built with modern iOS development techniques, leveraging Firebase for backend services and adopting a scalable MVVM architecture.

## Screen Recording
https://github.com/user-attachments/assets/480c84af-7cb6-4099-aeea-872ef586ffd1

## Features
- **Authentication**
  - Email & Password Login/Registration: Firebase Authentication to securely handle user login and registration.
  - Session Persistence: Automatically restores the user's session upon reopening the app.

- **Chats**
  - Inbox View: Displays all active chats for the logged-in user.
  - Individual and Group Chats: Supports private one-on-one chats and group chats.
  - Real-Time Messaging: Messages are synced instantly using Firestore's real-time updates.
  - Last Message Display: Shows the latest message and its timestamp in the Inbox view.
  - Unread Messages Counter: Displays unread message counts in the Inbox view.

- **Messaging**
  - Text Messages: Send and receive text messages with accurate timestamps.
  - Read Receipts: Indicates whether messages are read or not.
  - Media Sharing: (Planned) Upload and share images in chats using Firebase Storage.

- **Profiles**
  - User Profile: View and edit user details, including profile picture, name, and bio.
  - Custom Profile Pictures: Users can upload profile pictures to Firebase Storage.

- **Search**
  - User Search: Search for users to start a new chat.
  - Chat Search: Quickly filter chats in the Inbox view.

- **UI Design**
  - Clean, Minimalistic Design: Inspired by WhatsApp’s sleek interface, built entirely in SwiftUI.
  - Responsive Animations: Subtle animations to enhance the user experience.
  - Dynamic Chat Names: Adjusts individual chat names dynamically based on participants.

## Technologies Used
- **Frontend**
  - Language: Swift
  - Framework: SwiftUI
  - Architecture: MVVM (Model-View-ViewModel)
  - State Management: Combine

- **Backend**
  - Firebase Authentication: Secure user login and registration.
  - Firestore: Real-time database for storing chats, messages, and user data.
  - Firebase Storage: Manages profile images and other media uploads.

- **Other Tools**
  - Environment Objects: Shared data across views for seamless state management.
  - Dependency Injection: Modular design using protocol-oriented programming for testability and flexibility.
  - Error and Loading State Management: Centralized system to handle loading indicators and error alerts.

## How It Works
1. **App Launch**
Checks if the user is logged in.
If logged in, navigates to the Inbox view.
If not logged in, shows the Login/Register view.

2. **Inbox View**
Fetches all chats associated with the logged-in user.
Displays chat names dynamically (shows the other participant’s name in one-on-one chats).

3. **Messages View**
Real-time updates for new messages using Firestore listeners.
Allows users to send text messages and (future) upload images.

4. **Profile & Settings**
Allows users to update their profile.

## Contributing
Contributions are welcome! Please fork the repository and submit a pull request with your proposed changes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.

## Screenshots
![1](https://github.com/user-attachments/assets/d2049225-cff5-48cd-940e-fc62a4e7c902) 
![2](https://github.com/user-attachments/assets/848218af-8965-48b3-a0b5-bd8bec451592)
![3](https://github.com/user-attachments/assets/2540039a-28b1-4078-90f5-b1143f9902e2)
![4](https://github.com/user-attachments/assets/ccfe8276-c3bc-46ad-bed4-0b798ad01439)
![5](https://github.com/user-attachments/assets/87b6f769-f919-4bb3-9c64-82da84b22dac)
![6](https://github.com/user-attachments/assets/bd7ea99d-aeea-44c4-a34e-ef7a6feafe3f)
![7](https://github.com/user-attachments/assets/09bab929-15c9-4b61-9a20-d19282f76609)

