# Weather Forecaster 🌤️

Weather Forecaster is a simple web application that retrieves and displays the current weather forecast based on a provided address. Powered by OpenWeather API and Geocodio API, it provides real-time weather updates and caches results for optimized performance.

## 🖥️ Live Demo
A live version of the site is deployed on Heroku:

- https://weather-forecaster-b11670f11862.herokuapp.com/

## 🚀 Features
- **Search Weather by Address:** Enter any address (U.S. or Canada) to get the current weather details, including temperature, description, and icon
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

## 📦 Installation
1. **Install dependencies**
   ```
   bundle install
   ```
2. **Create API Keys**

   Sign up for free accounts at:
   - [Geocodio](https://www.geocod.io/)
   - [OpenWeather](https://openweathermap.org/)

   Generate API keys from each service after signing up.

3. **Set up environment variables**

   Create a .env file with the following variables:
   ```
   GEOCODIO_API_KEY=your_geocodio_api_key
   OPENWEATHER_API_KEY=your_openweather_api_key
   ```

4. **Run the server**

   ```
   rails server
   ```

5. **Access the application**

   Visit http://localhost:3000 in your browser.

## ⚙️ Usage
1. **Search for Weather:**
    - On the homepage, enter an address (e.g., `One Apple Park Way, Cupertino, CA 95014`) or a more general location (e.g., `California` or `Toronto, Canada`).
    - **Note:** The address can be either specific or broad (e.g., a street address, city, or state). However, it must be within the US or Canada, as Geocodio only supports these regions.
    - Click **Get Forecast** to view the weather details.
2. **Caching:**
    - Results are cached for 30 minutes to enhance speed and limit API requests.
    - If you search the same address within the cache period, the app will display the cached result.
3. **Error Handling:**
    - If an invalid address is entered, an error message will be displayed asking the user to try again.