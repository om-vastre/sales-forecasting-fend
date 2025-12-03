<div align="center">

# 📊 AI-Powered Sales Forecasting System

### XGBoost-Based Predictive Analytics Platform with Real-Time Dashboard

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![XGBoost](https://img.shields.io/badge/XGBoost-FF6600?style=for-the-badge&logo=xgboost&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)

**A full-stack sales forecasting platform using XGBoost machine learning models with advanced feature engineering to predict weekly and monthly sales with interactive Flutter dashboard**

[Features](#-features) • [Architecture](#-system-architecture) • [ML Pipeline](#-machine-learning-pipeline) • [Installation](#-installation) • [API](#-api-endpoints)

</div>

---

## 📖 Overview

Accurate sales forecasting is critical for inventory management, resource allocation, and strategic business planning. This **AI-Powered Sales Forecasting System** leverages XGBoost gradient boosting models with comprehensive feature engineering to deliver precise weekly (7-day) and monthly (30-day) sales predictions.

### The Problem We Solve
- 📈 **Demand Prediction** → Forecast future sales for inventory optimization
- 🔄 **Trend Analysis** → Identify patterns using lag features and rolling statistics
- 💰 **Revenue Planning** → Project sales revenue for financial planning
- 📱 **Accessibility** → Cross-platform Flutter app for real-time insights

---

## ✨ Features

### 🤖 Advanced ML Forecasting
- **Dual XGBoost Models**: Separate optimized models for 7-day and 30-day predictions
- **29 Engineered Features**: Comprehensive feature set including temporal, lag, rolling, and price-ratio features
- **Time-Series Processing**: Lag features at [1, 7, 14, 30] days with rolling mean/std windows

### 📊 Feature Engineering Pipeline

| Category | Features |
|----------|----------|
| **Temporal** | Year, Month, Day, DayOfWeek, Quarter, WeekOfYear |
| **Business** | Units Sold, Price, Discount, Holiday/Promotion, Competitor Pricing |
| **Categorical** | Product ID, Category, Region, Weather Condition, Seasonality (Label Encoded) |
| **Lag Features** | Sales_lag_1, Sales_lag_7, Sales_lag_14, Sales_lag_30 |
| **Rolling Stats** | Rolling Mean/Std for 7, 14, 30-day windows |
| **Price Ratios** | Price_vs_Competitor, Discount_Price_Ratio, Effective_Price |

### 📱 Cross-Platform Dashboard
- **Real-Time Predictions**: Interactive line charts with FL Chart visualization
- **Sales Statistics**: Daily, weekly, and monthly aggregations
- **Product Management**: Full CRUD operations for inventory
- **Sales Entry**: Add new sales records with automatic calculations
- **Multi-Platform**: Android, iOS, Web, Windows, macOS, Linux support

### 🔐 Secure Authentication
- **Token-Based Auth**: Secure access token generation (16-char hex)
- **Session Management**: Login/logout with token validation
- **Protected Endpoints**: All API routes require valid access tokens

### 🗄️ Data Management
- **SQLite Database**: User accounts and product inventory
- **CSV Dataset**: Historical sales data with 12 feature columns
- **Dataset Export**: Download records as CSV for external analysis

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │              Flutter Cross-Platform Application                      │    │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐           │    │
│  │  │  Login    │ │ Dashboard │ │  Manage   │ │ Add Sales │           │    │
│  │  │  Screen   │ │  Screen   │ │ Products  │ │   Entry   │           │    │
│  │  └───────────┘ └───────────┘ └───────────┘ └───────────┘           │    │
│  └──────────────────────────────┬──────────────────────────────────────┘    │
└─────────────────────────────────┼───────────────────────────────────────────┘
                                  │ HTTP/REST + JSON
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              API LAYER                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      Flask REST API                                  │    │
│  │  /login  /logout  /predict_last  /getstats  /products  /add_entry   │    │
│  │  /download_dataset                                                   │    │
│  └──────────────────────────────┬──────────────────────────────────────┘    │
└─────────────────────────────────┼───────────────────────────────────────────┘
                                  │
          ┌───────────────────────┼───────────────────────┐
          ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   ML SERVICE    │    │    DATABASE     │    │   DATA STORE    │
│                 │    │                 │    │                 │
│ • XGBoost Week  │    │ • SQLite        │    │ • dataset. csv   │
│ • XGBoost Month │    │ • Users Table   │    │ • 1. 2MB Dataset │
│ • Feature Eng.   │    │ • Products (20) │    │ • 12 Columns    │
│ • Label Encoder │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## 🧠 Machine Learning Pipeline

### Data Preprocessing

```python
def preprocess_data(df):
    # 1. Convert and sort by Product ID, Date
    # 2. Extract temporal features (Year, Month, Day, etc.)
    # 3. Create lag features [1, 7, 14, 30 days]
    # 4.  Compute rolling statistics [7, 14, 30 day windows]
    # 5.  Derive price-related ratios
    # 6. Label-encode categorical columns
```

### Feature Categories

| Feature Type | Count | Description |
|--------------|-------|-------------|
| Temporal | 6 | Year, Month, Day, DayOfWeek, Quarter, WeekOfYear |
| Business | 5 | Units Sold, Price, Discount, Holiday, Competitor Price |
| Encoded Categorical | 5 | Product ID, Category, Region, Weather, Seasonality |
| Lag Features | 4 | Sales at t-1, t-7, t-14, t-30 |
| Rolling Statistics | 6 | Mean and Std for 7, 14, 30-day windows |
| Price Ratios | 3 | Price_vs_Competitor, Discount_Ratio, Effective_Price |
| **Total** | **29** | Comprehensive feature set |

### Model Configuration

| Model | Target Horizon | File | Purpose |
|-------|----------------|------|---------|
| `xgb_model_week. pkl` | 7 days | 121 KB | Short-term forecasting |
| `xgb_model_month.pkl` | 30 days | 121 KB | Long-term planning |

---

## 📁 Project Structure

```
sales-forecasting-fend/
├── lib/                              # Flutter Frontend (main branch)
│   ├── main.dart                     # App entry point & routing
│   ├── theme.dart                    # App theming & colors
│   ├── globals.dart                  # Global state (access token)
│   └── screens/
│       ├── login_screen.dart         # User authentication
│       ├── dashboard_screen. dart     # Sales charts & statistics
│       ├── options_screen.dart       # Navigation options
│       ├── manage_products_screen. dart # Product CRUD
│       └── add_sales_entry_screen.dart # New sales entry
├── android/                          # Android platform
├── ios/                              # iOS platform
├── web/                              # Web platform
├── windows/                          # Windows desktop
├── macos/                            # macOS desktop
├── linux/                            # Linux desktop
├── test/                             # Widget tests
│
└── [api branch]                      # Backend (api branch)
    ├── main.py                       # Flask API (736 lines)
    ├── db_handler.py                 # Database initialization
    ├── dataset. csv                   # Sales dataset (1.2 MB)
    ├── xgb_model_week. pkl            # Week-ahead XGBoost model
    ├── xgb_model_month.pkl           # Month-ahead XGBoost model
    ├── users. db                      # SQLite database
    ├── report_final. docx             # Project report
    └── SalesForecasting.pptx         # Presentation
```

---

## 🚀 Installation

### Prerequisites
- Flutter SDK ≥ 3.0
- Python 3. 8+
- SQLite3

### Backend Setup (api branch)

```bash
# Clone and switch to api branch
git clone https://github. com/om-vastre/sales-forecasting-fend. git
cd sales-forecasting-fend
git checkout api

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install flask flask-cors joblib pandas numpy xgboost scikit-learn

# Initialize database (if needed)
python db_handler.py

# Run Flask server
python main.py
```

### Frontend Setup (main branch)

```bash
# Switch to main branch
git checkout main

# Install Flutter dependencies
flutter pub get

# Update API URL in lib/globals.dart
# const API_URL = 'http://localhost:5000';

# Run application
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d windows   # Windows
```

---

## 📡 API Endpoints

### Authentication

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/login` | POST | Authenticate user, return access token |
| `/logout` | POST | Invalidate access token |

### Predictions

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/predict_last` | POST | Get sales predictions for last N days |
| `/getstats` | POST | Get sales statistics for date range |

### Product Management (CRUD)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/products` | GET | List all products |
| `/products` | POST | Create new product |
| `/products/<id>` | GET | Get specific product |
| `/products/<id>` | PUT | Update product |
| `/products/<id>` | DELETE | Delete product |

### Data Management

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/add_entry` | POST | Add new sales record to dataset |
| `/download_dataset` | GET | Download dataset as CSV |

### Sample Prediction Request

```bash
curl -X POST http://localhost:5000/predict_last \
  -H "Content-Type: application/json" \
  -d '{
    "model": "week",
    "n_days": 7,
    "access_token": "your_token_here"
  }'
```

### Response Format

```json
{
  "predictions": [
    {"Date": "2025-01-01", "Predicted_Sales": 1523.45},
    {"Date": "2025-01-02", "Predicted_Sales": 1678.90},
    ...
  ]
}
```

---

## 📊 Dataset Schema

The system uses a comprehensive sales dataset with the following columns:

| Column | Type | Description |
|--------|------|-------------|
| Date | Date | Transaction date |
| Product ID | String | Unique product identifier (P0001-P0020) |
| Category | String | Product category |
| Region | String | Geographic region (North/South/East/West) |
| Units Sold | Integer | Quantity sold |
| Price | Float | Unit price |
| Discount | Float | Discount percentage |
| Weather Condition | String | Sunny/Cloudy/Rainy/Snowy |
| Holiday/Promotion | Integer | 0 or 1 flag |
| Competitor Pricing | Float | Competitor's price |
| Seasonality | String | Season indicator |
| Sales | Float | Total sales value |

---

## 🔮 Future Enhancements

- 📈 **Model Comparison**: Add LSTM and Prophet models
- 🔔 **Alerts**: Low inventory and sales anomaly notifications
- 📊 **Advanced Analytics**: Trend decomposition and seasonality analysis
- 🌐 **Multi-Store**: Support for multiple store locations
- 📱 **Push Notifications**: Real-time prediction alerts
- 🤖 **AutoML**: Automated hyperparameter tuning

---

## 📚 Documentation

Detailed documentation available in the `api` branch:
- **report_final.docx**: Comprehensive project report
- **SalesForecasting.pptx**: Project presentation slides

---

## 👤 Author

**Om Vastre** - [GitHub](https://github.com/om-vastre)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

<div align="center">

⭐ **Star this repository if you find it helpful!** ⭐

*Empowering businesses with AI-driven sales intelligence*

</div>
