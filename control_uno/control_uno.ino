#include <SoftwareSerial.h>
#include <Servo.h>
#include <Keypad.h>
#include <EEPROM.h>
#include <LiquidCrystal_I2C.h>
#include <Wire.h>

SoftwareSerial espSerial(3, 2);
String receivedString = "";

// Thiết lập cho LCD
LiquidCrystal_I2C lcd(0x27, 16, 2);

bool ESPconnectWifi = false;

bool isOpenedStored = false;  // Trạng thái cửa (mở hay đóng)
bool isLockedStored = false;  // Trạng thái khóa cửa (đã khóa hay chưa)
String passWordStored = "123456";
String tempPasswordStored = "";  // Mật khẩu tạm thời từ ESP8266

Servo myservo;
int pos = 0;

// Thiết lập cho keypad
const byte ROWS = 4;  // bốn hàng
const byte COLS = 4;  // bốn cột
char keys[ROWS][COLS] = {
  { '1', '2', '3', 'A' },
  { '4', '5', '6', 'B' },
  { '7', '8', '9', 'C' },
  { '*', '0', '#', 'D' }
};
byte rowPins[ROWS] = { 12, 11, 10, 9 };  // Chân cho các hàng
byte colPins[COLS] = { 7, 6, 5, 4 };     // Chân cho các cột
Keypad keypad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);

// Mật khẩu và trạng thái
char inputPassWord[7];
int posPassWord = 0;
bool checkPassWord = true;
bool checkStatus = false;
bool isTempPasswordMode = false;  // Cờ đánh dấu chế độ mật khẩu tạm thời

void setup() {
  Serial.begin(9600);
  espSerial.begin(4800);
  pinMode(3, INPUT);
  pinMode(2, OUTPUT);
  lcd.init();  // Khởi tạo LCD
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("PASSWORD: ");
  lcd.setCursor(0, 1);

  myservo.attach(8);  // Gắn servo vào pin 8
  myservo.write(90);  // Đặt servo ở vị trí khóa (cửa đóng)
  pinMode(13, OUTPUT);
}

void loop() {

  receiveESPdata();  // Nhận dữ liệu từ ESP8266

  char key = keypad.getKey();  // Kiểm tra phím nhấn từ bàn phím
  if (key) {
    // Kiểm tra trạng thái cửa trước khi xử lý tín hiệu từ bàn phím
    if (key == 'C') {
      if (isOpenedStored) {  // Chỉ cho phép đóng cửa khi cửa đang mở
        closeDoor();
      } else {
        Serial.println("Cửa đã đóng rồi!");
      }
    } else if (key == '*') {
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("PASSWORD: ");
      lcd.setCursor(0, 1);
      memset(inputPassWord, 0, sizeof(inputPassWord));  // Reset mật khẩu nhập
      isTempPasswordMode = false;
      posPassWord = 0;
    } else if (key == 'A') {
      // Chuyển sang chế độ mật khẩu tạm thời
      isTempPasswordMode = !isTempPasswordMode;  // Chuyển đổi chế độ
      if (isTempPasswordMode) {
        Serial.println("Chế độ mật khẩu tạm thời đã kích hoạt. Nhập mật khẩu tạm thời mới.");
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print("TEMP PASSWORD: ");
        lcd.setCursor(0, 1);
      } else {
        Serial.println("Chế độ mật khẩu tạm thời đã tắt.");
      }
    } else if (key == '#') {
      // Xử lý phím # để xác nhận mật khẩu (tùy vào chế độ)
      if (isTempPasswordMode) {
        processTempPassword();  // Xử lý xác nhận mật khẩu tạm thời
      } else {
        processPassword();  // Xử lý mật khẩu thường
      }
    } else {
      if (isLockedStored == false && isOpenedStored == false) {
        if (isTempPasswordMode) {
          handleTempPasswordInput(key);  // Xử lý nhập mật khẩu tạm thời
        } else {
          handleKeyInput(key);  // Xử lý nhập mật khẩu thường
        }
      }
    }
  }
}

// Các hàm xử lý khác
void processPassword() {
  String storedPassword = readPasswordFromEEPROM();  // Đọc từ EEPROM
  checkPassWord = true;

  if (storedPassword.length() != posPassWord) {
    checkPassWord = false;
  } else {
    for (int i = 0; i < posPassWord; i++) {
      if (storedPassword[i] != inputPassWord[i]) {
        checkPassWord = false;
        break;
      }
    }
  }

  if (checkPassWord && !checkStatus) {
    openDoor();
  } else {
    Serial.println("Mật khẩu sai!");  // In ra thông báo mật khẩu sai
    displayWrongPassword();
  }
}
void displayWrongPassword() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("WRONG PASSWORD!");
  delay(2000);
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("PASSWORD: ");
  lcd.setCursor(0, 1);
  memset(inputPassWord, 0, sizeof(inputPassWord));  // Reset input
  posPassWord = 0;
}

void handleKeyInput(char key) {
  if (posPassWord < sizeof(inputPassWord) - 1) {  // Đảm bảo không vượt quá kích thước mảng
    inputPassWord[posPassWord] = key;
    posPassWord++;
    lcd.setCursor(posPassWord - 1, 1);  // Set cursor to the next position
    lcd.print('*');                     // Display the entered key
  }
}

void handleTempPasswordInput(char key) {
  if (posPassWord < sizeof(inputPassWord) - 1) {  // Đảm bảo không vượt quá kích thước mảng
    inputPassWord[posPassWord] = key;             // Nhập mật khẩu tạm thời
    posPassWord++;
    lcd.setCursor(posPassWord - 1, 1);  // Set cursor to the next position
    lcd.print('*');                     // Display the entered key
  }
}

void processTempPassword() {
  if (tempPasswordStored == String(inputPassWord)) {  // So sánh với mật khẩu tạm thời
    Serial.println("Mật khẩu tạm thời chính xác. Mở cửa...");
    openDoor();  // Mở cửa nếu mật khẩu tạm thời đúng
  } else {
    displayWrongPassword();
    Serial.println("Mật khẩu tạm thời sai.");
  }

  // Reset mật khẩu nhập và thoát chế độ mật khẩu tạm thời
  memset(inputPassWord, 0, sizeof(inputPassWord));
  posPassWord = 0;
  isTempPasswordMode = false;
}

void receiveESPdata() {
  while (espSerial.available() > 0) {
    char receivedChar = espSerial.read();
    if (receivedChar == '\n') {  // Nhận được ký tự kết thúc
      receivedString.trim();
      processReceivedData(receivedString);  // Xử lý dữ liệu nhận được
      Serial.print("Nhận được: ");
      Serial.println(receivedString);  // In ra chuỗi nhận được
      receivedString = "";             // Xóa chuỗi để chuẩn bị nhận chuỗi mới
    } else {
      receivedString += receivedChar;  // Thêm ký tự vào chuỗi
    }
  }
}

// Hàm xử lý chuỗi nhận được từ ESP8266
void processReceivedData(String data) {
  if (data == "o") {
    if (!isOpenedStored) {  // Chỉ mở cửa nếu cửa chưa mở
      openDoor();
    } else {
      Serial.println("Cửa đã mở rồi!");
    }
  } else if (data == "c") {
    if (isOpenedStored) {  // Chỉ đóng cửa nếu cửa đang mở
      closeDoor();
    } else {
      Serial.println("Cửa đã đóng rồi!");
    }
  } else if (data == "l") {
    if (!isLockedStored) {  // Chỉ khóa cửa nếu cửa chưa bị khóa
      isLockedStored = true;
      lookDoor();
    } else {
      Serial.println("Cửa đã bị khóa rồi!");
    }
  } else if (data == "u") {
    if (isLockedStored) {  // Chỉ mở khóa cửa nếu cửa đang bị khóa
      isLockedStored = false;
      unlockDoor();
    } else {
      Serial.println("Cửa đã mở khóa rồi!");
    }
  } else if (data.startsWith("p")) {  // Cập nhật mật khẩu từ ESP
    String newPassword = data.substring(1);

    savePasswordToEEPROM(newPassword);  // Lưu vào EEPROM
    Serial.print("Mật khẩu đã được cập nhật: ");
    Serial.println(newPassword);


  } else if (data.startsWith("t")) {         // Kiểm tra tín hiệu bắt đầu với 't'
    tempPasswordStored = data.substring(1);  // Lấy chuỗi sau 't' làm tempPasswordStored
    Serial.print("Mật khẩu tạm thời được cập nhật: ");
    Serial.println(tempPasswordStored);
  } else if (data == "yw") {
    ESPconnectWifi = true;
    Serial.println("Thằng esp đang kết nối internet");
  } else if (data == "nw") {
    ESPconnectWifi = false;
    Serial.println("Thằng esp đang ko kết nối internet");
  } else {
    Serial.println("Dữ liệu nhận không hợp lệ.");
  }
}

void savePasswordToEEPROM(String password) {
  for (int i = 0; i < password.length(); i++) {
    EEPROM.write(i, password[i]);  // Lưu từng ký tự vào EEPROM
  }
  EEPROM.write(password.length(), '\0');  // Đánh dấu kết thúc chuỗi
  Serial.println("Mật khẩu đã lưu vào EEPROM.");
}

String readPasswordFromEEPROM() {
  String password = "";
  char ch;
  for (int i = 0; i < EEPROM.length(); i++) {
    ch = EEPROM.read(i);
    if (ch == '\0') break;  // Kết thúc chuỗi
    password += ch;
  }
  return password;
}

void openDoor() {
  if (isLockedStored) {  // Kiểm tra xem cửa có bị khóa không
    Serial.println("Cửa đã bị khóa! Vui lòng mở khóa trước khi mở.");
  } else {
    Serial.println("Cửa đã được mở");
    myservo.write(180);  // Mở cửa
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Opened");
    espSerial.println('o');
    isOpenedStored = true;  // Đánh dấu cửa đã mở

    // Xoá mật khẩu nhập sau khi mở cửa
    memset(inputPassWord, 0, sizeof(inputPassWord));  // Reset mật khẩu nhập
    posPassWord = 0;                                  // Reset vị trí mật khẩu
  }
}

void closeDoor() {
  Serial.println("Cửa đã đóng");
  myservo.write(90);  // Đóng cửa
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("CLOSED");
  delay(1000);
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("PASSWORD: ");
  lcd.setCursor(0, 1);
  espSerial.println('c');
  isOpenedStored = false;  // Đánh dấu cửa đã đóng
}

void lookDoor() {
  Serial.println("Cửa đã bị khóa");
  isLockedStored = true;
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("LOCKED");
}

void unlockDoor() {
  Serial.println("Cửa đã mở khóa");
  isLockedStored = false;
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("UNLOCKED");
  delay(1000);
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("PASSWORD: ");
  lcd.setCursor(0, 1);
}