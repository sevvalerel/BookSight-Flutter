class ApiConfig {
  // Spring WSL'de çalışıyorsa: 10.0.2.2 (WSL2 port proxy üzerinden)
  // Fiziksel cihaz: bilgisayarın LAN IP'si (örn. 192.168.1.x)
  static const String baseUrl = 'http://10.0.2.2:8080';
}
