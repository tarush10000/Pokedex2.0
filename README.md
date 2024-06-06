# 🚀 Pokedex 2.0 - My First Flutter Project

Welcome to Pokedex 2.0, my very first Flutter project! 🎉 This app allows user to input any photo into the application which then generates Pokedex-like stats which are saved into the device.

## 🌟 Project Overview

Pokedex 2.0 is a Gemini API based Flutter project that takes image as an input and then provides Pokemon like stats and description for the image. The API is securely saved within the device using Flutter Secure Storage along with all the stats saved in the form of a database using SQLite. It also contains platform-specific code for implementation of Text - to - Speech across different platforms including Android (Kotlin), iOS (Swift), Windows (C++) & Linux (C++).  

## 🔧 Tech Stack

Here's a quick overview of the tech stack used in this project:

- **Flutter:** The main framework for building the app.
- **Dart:** The programming language used.
- **SQLite (via sqflite):** For local database storage.
- **Google Gemini 1.5 Pro AI:** For performing analysis over text and image prompt
- **Flutter Secure Storage:** For securely storing the Gemini API key.
- **Kotlin, Swift, C++:** For platform-specific code for Text-To-Speech Functionality

## ✨ Some Screenshots
<img src="https://github.com/tarush10000/Pokedex2.0/assets/62472697/5284c288-5517-4a02-b985-3c5075b6722d" alt="Screenshot 1" width="200px">
<img src="https://github.com/tarush10000/Pokedex2.0/assets/62472697/a262f291-91d0-493b-8dbf-a4b468a26076" alt="Screenshot 2" width="200px">
<img src="https://github.com/tarush10000/Pokedex2.0/assets/62472697/3c177f91-c3cb-475f-a6ab-3e24defcc44d" alt="Screenshot 3" width="200px">
<img src="https://github.com/tarush10000/Pokedex2.0/assets/62472697/a51a5adf-6324-4eb7-bf49-52511aed9ea9" alt="Screenshot 4" width="200px">

## 🚀 Getting Started

To get started with Pokedex 2.0, follow these steps:

1. Clone the repository: `git clone https://github.com/tarush10000/Pokedex2.0.git`
2. Navigate into the project directory.
3. Ensure Flutter is installed and properly set up.
4. Run the command: `flutter pub get` to automatically have all dependencies installed and setup.
5. Run the command: `flutter run` to launch the app on your device or emulator.
6. Get the Gemini API key from the [official website](https://aistudio.google.com/app/apikey)

## 💡 Usage

Once the app is running, follow these steps to use Pokedex 2.0:

1. If opening for the first time, insert your Gemini API key 
2. Take or select a photo within the app.
3. Wait for the app to process the image and generate Pokedex-like stats.
4. Explore the generated stats and descriptions for the image.
5. Enjoy using Pokedex 2.0!

## 📝 Note

Ensure that you have proper permissions set up for accessing the device's photo gallery, depending on your platform, to enable image input for Pokedex 2.0.

