#include <Firebase_ESP_Client.h>
#include <ESP8266WiFi.h>
#include <SoftwareSerial.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"
#include <time.h>

SoftwareSerial arduinoSerial(D2, D3);
SoftwareSerial bluetoothSerial(D5, D6);  // Pins for Bluetooth communication

// Đối tượng Firebase
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

String userId = "";
bool userIdProcessed = false;
bool isWifiConnected = false;  // Trạng thái WiFi
bool firebaseConnected = false;
String receivedStringFromBluetooth = "";
String receivedString = "";
String tempPasswordStored = "";
bool isOpenedStored = false;
bool isLockedStored = false;
String passWordStored = "123456";

String email = "";
String accountPassword = "";

// Firebase thông tin
#define PROJECT_ID "iot-project-8a40e"
#define API_KEY "AIzaSyC5nEkTDDoHQnxU-461kKc5mYq0AfFq03M"
#define DATABASE_URL "https://iot-project-8a40e-default-rtdb.asia-southeast1.firebasedatabase.app/"  // URL Database

void setup() {
  Serial.begin(9600);
  bluetoothSerial.begin(9600);
  arduinoSerial.begin(4800);  // Arduino Serial
  // Yêu cầu nhập thông tin WiFi và User ID
  Serial.println("Nhập thông tin WiFi theo định dạng: ssid,password");
  Serial.println("Nhập User ID theo định dạng: id,UserID");
}

void loop() {

  receiveBluetoothData();  // Nhận dữ liệu WiFi và User ID
  receiveArduinodata();
  if (userIdProcessed && firebaseConnected) {
    fetchAndPrintFirebaseData();
  }
}

void setupTime() {
  configTime(7 * 3600, 0, "pool.ntp.org", "time.nist.gov");
  Serial.println("Syncing time...");
  int attempts = 0;
  while (time(nullptr) < 100000 && attempts < 10) {  // Giới hạn 10 lần thử
    delay(1000);
    Serial.print(".");
    attempts++;
  }
  if (time(nullptr) >= 100000) {
    Serial.println("\nTime synchronized!");
  } else {
    Serial.println("\nFailed to sync time.");
  }
}

// Hàm nhận dữ liệu từ Bluetooth
void receiveBluetoothData() {
  while (bluetoothSerial.available() > 0) {
    char receivedChar = bluetoothSerial.read();
    if (receivedChar == '\n') {
      receivedStringFromBluetooth.trim();
      processReceivedBluetoothData(receivedStringFromBluetooth);
      receivedStringFromBluetooth = "";
    } else {
      receivedStringFromBluetooth += receivedChar;
    }
  }
}

void processReceivedBluetoothData(String receivedData) {
  if (receivedData.startsWith("w,")) {
    // Xử lý dữ liệu Wi-Fi
    String wifiData = receivedData.substring(2);  // Bỏ "w,"
    int firstCommaIndex = wifiData.indexOf(',');
    int secondCommaIndex = wifiData.indexOf(',', firstCommaIndex + 1);
    int thirdCommaIndex = wifiData.indexOf(',', secondCommaIndex + 1);

    if (firstCommaIndex != -1 && secondCommaIndex != -1 && thirdCommaIndex != -1) {
      String wifiId = wifiData.substring(0, firstCommaIndex);
      String wifiPassword = wifiData.substring(firstCommaIndex + 1, secondCommaIndex);
      email = wifiData.substring(secondCommaIndex + 1, thirdCommaIndex);
      accountPassword = wifiData.substring(thirdCommaIndex + 1);

      Serial.println("Received Wi-Fi Data:");
      Serial.println("WiFi ID: " + wifiId);
      Serial.println("WiFi Password: " + wifiPassword);
      Serial.println("Email: " + email);
      Serial.println("Password: " + accountPassword);

      // Gọi hàm kết nối Wi-Fi
      connectToWiFi(wifiId, wifiPassword);
    } else {
      Serial.println("Invalid Wi-Fi data format.");
    }
  } else if (receivedData.startsWith("id,")) {
    // Xử lý dữ liệu UserID
    userId = receivedData.substring(3);  // Bỏ "id,"

    if (!userId.isEmpty()) {
      Serial.println("Received UserID: " + userId);
      userIdProcessed = true;

      // Có thể lưu userId hoặc thực hiện các hành động khác
    } else {
      Serial.println("Invalid UserID data format.");
    }
  } else {
    Serial.println("Unknown data format received: " + receivedData);
  }
}

void connectToWiFi(String ssid, String pass) {
  Serial.println("Attempting to connect to WiFi...");
  WiFi.begin(ssid.c_str(), pass.c_str());

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 10) {
    delay(1000);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi connected successfully!");
    isWifiConnected = true;
    setupFirebase();
    setupTime(); 
    bluetoothSerial.print('y');
  } else {
    Serial.println("\nFailed to connect to WiFi.");
    bluetoothSerial.print('n');
  }
}

void setupFirebase() {
  if (!isWifiConnected) {
    Serial.println("Chưa kết nối WiFi. Hãy nhập WiFi trước.");
    return;
  }

  Serial.println("Thiết lập Firebase...");
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  // Gán email và password trước khi bắt đầu Firebase
  if (email.isEmpty() || accountPassword.isEmpty()) {
    Serial.println("Email hoặc mật khẩu trống. Không thể thiết lập Firebase.");
    return;
  }

  auth.user.email = email.c_str();
  auth.user.password = accountPassword.c_str();

  config.token_status_callback = tokenStatusCallback;  // Theo dõi trạng thái token
  Firebase.begin(&config, &auth);                      // Bắt đầu Firebase với cấu hình và xác thực
  Firebase.reconnectWiFi(true);

  if (Firebase.ready()) {
    Serial.println("Firebase đã sẵn sàng!");
    firebaseConnected = true;
  } else {
    Serial.println("Firebase không sẵn sàng");
    firebaseConnected = false;
  }
}

void receiveArduinodata() {
  while (arduinoSerial.available() > 0) {
    char receivedChar = arduinoSerial.read();
    if (receivedChar == '\n') {
      receivedString.trim();
      Serial.println("Received from Arduino: " + receivedString);
      processReceivedArduinoData(receivedString);  // Gọi hàm xử lý dữ liệu
      receivedString = "";
    } else {
      receivedString += receivedChar;
    }
  }
}

void processReceivedArduinoData(String receivedData) {
  String currentDate = getCurrentDate();                                            // Lấy ngày hiện tại
  String actionsPath = "users/" + userId + "/history/" + currentDate + "/actions";  // Đường dẫn tới actions

  // Xác định hành động dựa trên dữ liệu nhận được
  String action = "";
  if (receivedData == "o") {
    action = "open";  // Hành động mở cửa
    if (Firebase.RTDB.setBool(&fbdo, "/" + userId + "/isopened", true)) {
      isOpenedStored = true;
      Serial.println("Logged open action to Firestore.");
    } else {
      Serial.println("Failed to log open action to Firestore.");
    }
  } else if (receivedData == "c") {
    action = "close";  // Hành động đóng cửa
    if (Firebase.RTDB.setBool(&fbdo, "/" + userId + "/isopened", false)) {
      isOpenedStored = false;
      Serial.println("Logged close action to Firestore.");
    } else {
      Serial.println("Failed to log close action to Firestore.");
    }
  } else {
    Serial.println("Unknown data received: " + receivedData);
    return;
  }

  // Tạo dữ liệu JSON để ghi vào Firestore
  FirebaseJson json;
  json.set("fields/action/stringValue", action);
  json.set("fields/timestamp/timestampValue", getCurrentTimestamp());

  // Ghi dữ liệu lên Firestore
  if (Firebase.Firestore.createDocument(&fbdo, PROJECT_ID, "", actionsPath, json.raw())) {
    Serial.println("Logged action to Firestore: " + action);
    // Cập nhật trạng thái mở/đóng dựa trên hành động
    if (action == "unlock") {
      isOpenedStored = true;  // Cập nhật trạng thái mở
    } else if (action == "lock") {
      isOpenedStored = false;  // Cập nhật trạng thái đóng
    }
  } else {
    Serial.println("Failed to log action to Firestore: " + fbdo.errorReason());
  }
  // Giải phóng FirebaseJson
  json.clear();
}

// Lấy ngày hiện tại theo định dạng YYYY-MM-DD
String getCurrentDate() {
  time_t now = time(nullptr);
  struct tm* timeInfo = localtime(&now);  // Lấy thời gian theo múi giờ đã cấu hình
  char buffer[11];
  strftime(buffer, sizeof(buffer), "%Y-%m-%d", timeInfo);  // Định dạng: YYYY-MM-DD
  return String(buffer);
}

// Lấy timestamp hiện tại theo định dạng ISO 8601
String getCurrentTimestamp() {
  time_t now = time(nullptr);
  struct tm* timeInfo = gmtime(&now);  // UTC time
  char buffer[25];
  strftime(buffer, sizeof(buffer), "%Y-%m-%dT%H:%M:%SZ", timeInfo);  // Định dạng: ISO 8601
  return String(buffer);
}


void fetchAndPrintFirebaseData() {

  // Lấy giá trị boolean "isopened" từ Firebase
  if (Firebase.RTDB.getBool(&fbdo, "/" + userId + "/isopened")) {
    bool temp = fbdo.boolData();
    if (isOpenedStored != temp) {
      isOpenedStored = temp;
      arduinoSerial.println(isOpenedStored ? 'o' : 'c');
    }
  } else {
    Serial.println("Failed to get 'isopened' from Firebase: " + fbdo.errorReason());
  }
  delay(100);

  // Lấy giá trị boolean "islocked" từ Firebase
  if (Firebase.RTDB.getBool(&fbdo, "/" + userId + "/islocked")) {
    bool temp = fbdo.boolData();
    if (isLockedStored != temp) {
      isLockedStored = temp;
      arduinoSerial.println(isLockedStored ? 'l' : 'u');
    }
  } else {
    Serial.println("Failed to get 'islocked' from Firebase: " + fbdo.errorReason());
  }
  delay(100);

  // Lấy chuỗi "passWord" từ Firebase
  if (Firebase.RTDB.getString(&fbdo, "/" + userId + "/passWord")) {
    String temp = fbdo.stringData();
    if (passWordStored != temp) {
      passWordStored = temp;
      arduinoSerial.println("p" + passWordStored);
    }
  } else {
    Serial.println("Failed to get 'passWord' from Firebase: " + fbdo.errorReason());
  }
  delay(100);

  // Lấy chuỗi "tempPassword" từ Firebase
  if (Firebase.RTDB.getString(&fbdo, "/" + userId + "/tempPassword")) {
    String temp = fbdo.stringData();
    if (tempPasswordStored != temp) {
      tempPasswordStored = temp;
      arduinoSerial.println("t" + tempPasswordStored);
    }
  } else {
    Serial.println("Failed to get 'tempPassword' from Firebase: " + fbdo.errorReason());
  }
  delay(100);

  // Lấy giá trị boolean "isOnline" từ Firebase
  if (Firebase.RTDB.getBool(&fbdo, "/" + userId + "/isOnline")) {
    bool temp = fbdo.boolData();
    if (!temp && Firebase.RTDB.setBool(&fbdo, "/" + userId + "/isOnline", true)) {
      Serial.println("Updated isOnline to true.");
    }
  } else {
    Serial.println("Failed to get 'isOnline' from Firebase: " + fbdo.errorReason());
  }
  delay(100);
}
