# Weather Forecaster 🌤️

Weather Forecaster is a simple web application that retrieves and displays the current weather forecast based on a provided address. Powered by OpenWeather API and Geocodio API, it provides real-time weather updates and caches results for optimized performance.

## 🖥️ Live Demo
A live version of the site is deployed on Heroku:

- https://weather-forecaster-b11670f11862.herokuapp.com/

## 🚀 Features
- **Search Weather by Address:** Enter any address to get the current weather details, including temperature, description, and icon
- **Caching for Efficiency:** Forecast data is cached for 30 minutes based on zip codes to optimize performance
- **Error Handling:** Handles invalid addresses gracefully with user-friendly messages
- **User Interface with Bootstrap:** Clean and responsive design powered by Bootstrap for better user experience

## 🛠️ Technologies Used
- **Backend:** Ruby on Rails
- **APIs:**
    - [OpenWeather API](https://openweathermap.org/api)
    - [Geocodio API](https://www.geocod.io/docs/#introduction)
- **Frontend:** Bootstrap CSS for styling
- **Deployment:** Heroku