# Flutter Integration Guide for KrishiMitra Agentic Backend

## 🎯 Backend URL Configuration

The backend needs to be accessible from the Flutter app. Update the API configuration:

### For Development (localhost):
```dart
// lib/services/apiconfig.dart  
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8002/api';  // Android emulator
  // OR
  static const String baseUrl = 'http://localhost:8002/api';  // iOS simulator
  // OR
  static const String baseUrl = 'http://YOUR_LOCAL_IP:8002/api';  // Physical device
}
```

### For Production:
```dart
static const String baseUrl = 'https://your-domain.com/api';
```

## 📡 New API Endpoints to Integrate

### 1. **Fertilizer Price Comparison** (Already in app!)
**Endpoint**: `POST /fertilization/alternatives`

**Current Flutter Implementation**: `lib/services/gemini_service.dart`
**Update** to use backend instead:

```dart
Future<FertilizerAnalysisResponse> findCheaperAlternatives({
  required int nitrogen,
  required int phosphorus,
  required int potassium,
}) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/fertilization/alternatives'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'npk': {'n': nitrogen, 'p': phosphorus, 'k': potassium},
      'current_brand': 'Unknown',
      'current_price': 0,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return FertilizerAnalysisResponse.fromJson(data['alternatives']);
  }
  throw Exception('Failed to find alternatives');
}
```

### 2. **Crop Management with Auto-Agents**
**Endpoint**: `POST /crops/add`

**New Feature**: When a crop is added, ALL 6 agents activate automatically!

```dart
// lib/services/crop_service.dart (NEW)
import 'package:http/http.dart' as http;
import 'dart:convert';

class CropService {
  static Future<Map<String, dynamic>> addCropWithAgents({
    required String token,
    required String cropName,
    required String sowingDate,  // ISO format: "2026-06-15"
    required double landArea,
    String areaUnit = 'acres',
    String? cropVariety,
    String? irrigationType,
    Map<String, double>? soilNpk,
    double? soilMoisture,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/crops/add'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'crop_name': cropName,
        'sowing_date': sowingDate,
        'land_area': landArea,
        'area_unit': areaUnit,
        if (cropVariety != null) 'crop_variety': cropVariety,
        if (irrigationType != null) 'irrigation_type': irrigationType,
        if (soilNpk != null) 'soil_npk': soilNpk,
        if (soilMoisture != null) 'soil_moisture': soilMoisture,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
      // Returns:
      // {
      //   "message": "Crop added successfully! All agents activated.",
      //   "crop": { crop details },
      //   "agent_execution": {
      //     "fertilization": "success",
      //     "irrigation": "success",
      //     "harvest_prediction": "success",
      //     "price_prediction": "success"
      //   }
      // }
    }
    throw Exception('Failed to add crop');
  }

  static Future<List<Map<String, dynamic>>> getAllCrops(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/crops'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['crops']);
    }
    throw Exception('Failed to get crops');
  }
}
```

### 3. **Dashboard with All Agent Data**
**Endpoint**: `GET /dashboard`

```dart
// lib/services/dashboard_service.dart (NEW)
class DashboardService {
  static Future<Map<String, dynamic>> getDashboard(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/dashboard'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
      // Returns:
      // {
      //   "total_crops": 2,
      //   "crops": [/* all crop data with agent recommendations */],
      //   "upcoming_actions": [
      //     {"type": "irrigation", "crop": "Cotton", "date": "2026-02-01"}
      //   ],
      //   "alerts": [
      //     {"type": "disease", "severity": "High", "action_required": "..."}
      //   ]
      // }
    }
    throw Exception('Failed to get dashboard');
  }

  static Future<List<Map<String, dynamic>>> getAlerts(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/dashboard/alerts'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['alerts']);
    }
    throw Exception('Failed to get alerts');
  }
}
```

### 4. **Disease Detection**
**Endpoint**: `POST /disease/detect`

```dart
// lib/services/disease_service.dart (NEW)
class DiseaseService {
 static Future<Map<String, dynamic>> detectDisease({
    required String token,
    required int cropId,
    required String symptoms,
    String? imageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/disease/detect'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'crop_id': cropId,
        'symptoms': symptoms,
        if (imageUrl != null) 'image_url': imageUrl,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['diagnosis'];
      // Returns full diagnosis with:
      // - disease_name
      // - confidence_score
      // - severity
      // - immediate_actions
      // - chemical_treatment
      // - organic_alternatives
      // - preventive_measures
    }
    throw Exception('Failed to detect disease');
  }
}
```

### 5. **Irrigation Schedule Updates**
**Endpoint**: `POST /irrigation/update-moisture`

```dart
// lib/services/irrigation_service.dart (NEW)
class IrrigationService {
  static Future<Map<String, dynamic>> updateSoilMoisture({
    required String token,
    required int cropId,
    required double soilMoisture,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/irrigation/update-moisture'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'crop_id': cropId,
        'soil_moisture': soilMoisture,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['schedule'];
      // Agent auto-adjusts schedule based on new moisture + weather!
    }
    throw Exception('Failed to update moisture');
  }
}
```

## 🔑 Authentication Integration

The backend uses JWT. Update your auth service:

```dart
// lib/services/auth_service.dart (UPDATE)
class AuthService {
  static Future<Map<String, dynamic>> login(String mobile, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile_number': mobile,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Store token
      await SharedPreferences.getInstance().then((prefs) {
        prefs.setString('access_token', data['access_token']);
        prefs.setString('user_data', jsonEncode(data['user']));
      });
      return data;
    }
    throw Exception('Login failed');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}
```

## 📱 UI Integration Examples

### Home Screen Enhancement
Add "AI Recommendations" card:

```dart
// lib/screens/home_screen.dart (ADD)
Card(
  child: ListTile(
    leading: Icon(Icons.smart_toy, color: Colors.green),
    title: Text('AI Recommendations'),
    subtitle: Text('View all agent insights'),
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AgentDashboardScreen()),
    ),
  ),
)
```

### Agent Dashboard Screen (NEW)
```dart
// lib/screens/agent_dashboard_screen.dart (NEW FILE)
import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../services/auth_service.dart';

class AgentDashboardScreen extends StatefulWidget {
  @override
  _AgentDashboardScreenState createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen> {
  Map<String, dynamic>? dashboardData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final token = await AuthService.getToken();
    if (token != null) {
      final data = await DashboardService.getDashboard(token);
      setState(() {
        dashboardData = data;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text('🤖 Krishidnya AI Dashboard')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Total Crops Card
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Total Crops Managed', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('${dashboardData!['total_crops']}', 
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // Alerts Section
          if (dashboardData!['alerts'].isNotEmpty) ...[
            SizedBox(height: 16),
            Text('⚠️ Alerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...dashboardData!['alerts'].map<Widget>((alert) => Card(
              color: alert['priority'] == 'critical' ? Colors.red[50] : Colors.orange[50],
              child: ListTile(
                leading: Icon(Icons.warning, color: Colors.red),
                title: Text(alert['message']),
                subtitle: Text(alert['crop']),
              ),
            )).toList(),
          ],

          // Upcoming Actions
          if (dashboardData!['upcoming_actions'].isNotEmpty) ...[
            SizedBox(height: 16),
            Text('📅 Upcoming Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...dashboardData!['upcoming_actions'].map<Widget>((action) => Card(
              child: ListTile(
                leading: Icon(Icons.event),
                title: Text(action['details']),
                subtitle: Text('${action['crop']} - ${action['date']}'),
              ),
            )).toList(),
          ],

          // All Crops with Agent Data
          SizedBox(height: 16),
          Text('🌾 Your Crops', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ...dashboardData!['crops'].map<Widget>((crop) => Card(
            child: ExpansionTile(
              title: Text(crop['crop_name']),
              subtitle: Text('${crop['land_area']} ${crop['area_unit']}'),
              children: [
                if (crop['fertilization_cost'] != null)
                  ListTile(
                    leading: Icon(Icons.eco, color: Colors.green),
                    title: Text('Fertilization Cost'),
                    trailing: Text('₹${crop['fertilization_cost']}'),
                  ),
                if (crop['savings_potential'] != null)
                  ListTile(
                    leading: Icon(Icons.savings, color: Colors.amber),
                    title: Text('Potential Savings'),
                    trailing: Text('₹${crop['savings_potential']}', 
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                if (crop['harvest_date'] != null)
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Expected Harvest'),
                    trailing: Text(crop['harvest_date']),
                  ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}
```

## 🚀 Testing the Integration

1. **Start Backend**:
```bash
cd KrishiMitra-backend
source venv/bin/activate
python run.py
# Backend runs on port 8002
```

2. **Update Flutter Config**:
```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:8002/api';

// For Physical Device (get your local IP)
// Linux: ip addr show
// macOS: ifconfig | grep "inet "
// Windows: ipconfig
static const String baseUrl = 'http://192.168.X.X:8002/api';
```

3. **Run Flutter App**:
```bash
cd /home/tejasbargujepatil/Desktop/KrishiMitra
flutter run
```

## 📊 Agent Features Now Available in App

| Feature | Backend Agent | Flutter Integration |
|---------|--------------|---------------------|
| ✅ Fertilizer Price Comparison | Fertilization Agent | Already in app - update endpoint |
| 🆕 Crop Management | All 6 Agents | NEW - use CropService |
| 🆕 Disease Detection | Disease Agent | NEW - use DiseaseService |
| 🆕 Irrigation Schedule | Irrigation Agent | NEW - use IrrigationService |
| 🆕 Harvest Predictions | Harvest Agent | NEW - in DashboardService |
| 🆕 Price Predictions | Price Agent | NEW - in DashboardService |
| 🆕 AI Dashboard | All Agents | NEW - AgentDashboardScreen |

## 🎯 Next Steps

1. **Update API Config** - Change baseUrl to backend
2. **Add New Services** - Create CropService, DiseaseService, IrrigationService, DashboardService
3. **Create Agent Dashboard** - New screen showing all AI insights
4. **Update Fertilizer Screen** - Use backend endpoint instead of direct Gemini call
5. **Test Integration** - Verify all endpoints work

## 💡 Benefits of Backend Integration

- **Faster**: Backend caches Gemini responses
- **Cheaper**: Reduces direct Gemini API calls
- **Smarter**: Agents share data and make coordinated decisions
- **Scalable**: Can handle multiple users
- **Persistent**: All data saved to database
- **Automated**: Agents run automatically, no manual work

---

**Backend is ready! URL**: `http://localhost:8002`  
**Health Check**: `curl http://localhost:8002/health`

🎉 Your agentic backend is live and ready to empower farmers!
