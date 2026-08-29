<div align="center">
  <h1>🌍 Surplus Share</h1>
  <p><strong>A platform bridging the gap between food surplus and those in need.</strong></p>
  <p>
    <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" /></a>
    <a href="https://nodejs.org"><img src="https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white" /></a>
    <a href="https://expressjs.com"><img src="https://img.shields.io/badge/Express.js-404D59?style=for-the-badge" /></a>
    <a href="https://www.mongodb.com/"><img src="https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white" /></a>
    <a href="https://firebase.google.com/"><img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=white" /></a>
  </p>
</div>

<br/>

## 📖 Overview

**Surplus Share** is a robust mobile application and backend service built to minimize food waste by seamlessly connecting food suppliers (restaurants, supermarkets, caterers) with Non-Governmental Organizations (NGOs) and charities. 

## ✨ Key Features

- **🍔 Food Donation Flow**: Easy-to-use interface for businesses to list their surplus food.
- **🗺️ Interactive Maps**: Built-in mapping utilizing `flutter_map` and OSM for locating nearby donations and NGOs.
- **🔐 Secure Authentication**: Multi-layered authentication leveraging Firebase Auth, Google Sign-In, and a custom JWT-backed Node.js implementation.
- **☁️ Cloud Storage**: Seamless integration with Firebase Storage and local Multer configurations for image handling.
- **📧 Notifications**: Automated email notifications using Nodemailer for donation status updates.
- **📱 Beautiful UI**: Fluid animations with `flutter_animate`, modern typography via Google Fonts, and crisp icons from Lucide.

---

## 🛠️ Tech Stack

### Frontend (Mobile App)
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Maps & Location**: `flutter_map`, `latlong2`
- **Backend-as-a-Service**: Firebase Core, Auth, Storage, Cloud Firestore
- **Networking**: `http`

### Backend (REST API)
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB (via Mongoose)
- **Authentication**: JWT (JSON Web Tokens), bcryptjs
- **File Uploads**: Multer
- **Mailing**: Nodemailer

---

## 🚀 Getting Started (Local Development Setup)

To get a local copy up and running, follow these simple steps.

### Prerequisites

Ensure you have the following installed on your local machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0 or higher)
- [Node.js](https://nodejs.org/) (v16.x or higher)
- [MongoDB](https://www.mongodb.com/try/download/community) (Local or Atlas URI)
- A Firebase Project (for Client-side configuration)

### 1. Clone the repository

```bash
git clone https://github.com/Somil450/NGO_Helper.git
cd NGO_Helper
```

---

### 2. Backend Setup

The backend serves as the core REST API for the application.

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install NPM dependencies:
   ```bash
   npm install
   ```
3. **Environment Configuration**: Create a `.env` file in the `backend/` directory and configure the following variables:
   ```env
   # Database Configuration
   MONGO_URI=your_mongodb_connection_string
   
   # Server Configuration
   PORT=5000
   
   # JWT & Auth
   JWT_SECRET=your_super_secret_jwt_key
   
   # Email Service (Nodemailer)
   EMAIL_USER=your_email@gmail.com
   EMAIL_PASS=your_email_app_password
   ```
4. Start the backend development server:
   ```bash
   npm run dev
   # Server should now be running on http://localhost:5000
   ```

---

### 3. Frontend Setup

1. Open a new terminal and navigate to the project root:
   ```bash
   cd NGO_Helper
   ```
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. **Firebase Setup**: 
   - Make sure you have added your `google-services.json` inside `android/app/`.
   - For iOS, place your `GoogleService-Info.plist` inside `ios/Runner/`.
   - Ensure your Firebase project is properly set up with Authentication and Storage enabled.
4. Run the application:
   ```bash
   flutter run
   ```

---

## 🔒 Security & Privacy

This project emphasizes security best practices:
- Passwords are encrypted utilizing `bcryptjs`.
- Session management is handled securely via JWT.
- API keys, service accounts, and environment variables are explicitly excluded from version control using `.gitignore` to prevent secret leaks.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! 
Feel free to check the [issues page](https://github.com/Somil450/NGO_Helper/issues).

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.
