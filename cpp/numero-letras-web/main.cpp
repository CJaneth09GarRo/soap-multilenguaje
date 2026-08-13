#include <winsock2.h>
#include <ws2tcpip.h>
#include <iostream>
#include <string>
#include <sstream>

#pragma comment(lib, "ws2_32.lib")

std::string unidades(int n) {
    static const std::string U[] = {"cero","uno","dos","tres","cuatro","cinco","seis","siete","ocho","nueve","diez","once","doce","trece","catorce","quince","dieciseis","diecisiete","dieciocho","diecinueve","veinte"};
    return U[n];
}
std::string decenas(int n) {
    static const std::string D[] = {"", "", "veinte", "treinta", "cuarenta", "cincuenta", "sesenta", "setenta", "ochenta", "noventa"};
    return D[n];
}
std::string centenas(int n) {
    static const std::string C[] = {"", "ciento", "doscientos", "trescientos", "cuatrocientos", "quinientos", "seiscientos", "setecientos", "ochocientos", "novecientos"};
    return C[n];
}

std::string convertir(int numero) {
    if (numero == 0) return "cero";
    if (numero < 0) return "menos " + convertir(-numero);
    if (numero > 999999) return std::to_string(numero);

    if (numero >= 1000) {
        int miles = numero / 1000;
        int resto = numero % 1000;
        std::string prefijo = (miles == 1) ? "mil" : convertir(miles) + " mil";
        return (resto == 0) ? prefijo : prefijo + " " + convertir(resto);
    }
    if (numero >= 100) {
        if (numero == 100) return "cien";
        int centena = numero / 100;
        int resto = numero % 100;
        std::string prefijo = centenas(centena);
        return (resto == 0) ? prefijo : prefijo + " " + convertir(resto);
    }
    if (numero <= 20) return unidades(numero);

    int decena = numero / 10;
    int unidad = numero % 10;
    if (unidad == 0) return decenas(decena);
    if (decena == 2) return "veinti" + unidades(unidad);
    return decenas(decena) + " y " + unidades(unidad);
}

std::string extraerNumeroDeQuery(const std::string& request) {
    size_t pos = request.find("numero=");
    if (pos == std::string::npos) return "";
    pos += 7;
    size_t fin = request.find_first_of(" &", pos);
    return request.substr(pos, fin - pos);
}

int main() {
    WSADATA wsaData;
    WSAStartup(MAKEWORD(2, 2), &wsaData);

    SOCKET listenSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    sockaddr_in serverAddr;
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_addr.s_addr = INADDR_ANY;
    serverAddr.sin_port = htons(8085);

    bind(listenSocket, (sockaddr*)&serverAddr, sizeof(serverAddr));
    listen(listenSocket, 5);

    std::cout << "Servidor escuchando en http://localhost:8085" << std::endl;
    std::cout << "Prueba: http://localhost:8085/convertir?numero=123" << std::endl;

    while (true) {
        SOCKET clientSocket = accept(listenSocket, NULL, NULL);
        if (clientSocket == INVALID_SOCKET) continue;

        char buffer[4096] = {0};
        recv(clientSocket, buffer, sizeof(buffer) - 1, 0);
        std::string request(buffer);

        std::string numeroStr = extraerNumeroDeQuery(request);
        std::string body, status;
        bool esValido = !numeroStr.empty();
        for (char c : numeroStr) if (!isdigit((unsigned char)c) && c != '-') esValido = false;

        if (!esValido) {
            status = "400 Bad Request";
            body = "{\"error\":\"Proporciona un numero valido, ej: /convertir?numero=123\"}";
        } else {
            int numero = std::stoi(numeroStr);
            std::string letras = convertir(numero);
            status = "200 OK";
            body = "{\"numero\":" + std::to_string(numero) + ",\"letras\":\"" + letras + "\"}";
        }

        std::ostringstream response;
        response << "HTTP/1.1 " << status << "\r\n"
                 << "Content-Type: application/json; charset=utf-8\r\n"
                 << "Content-Length: " << body.size() << "\r\n"
                 << "Connection: close\r\n\r\n" << body;

        std::string responseStr = response.str();
        send(clientSocket, responseStr.c_str(), responseStr.size(), 0);
        closesocket(clientSocket);
    }
    WSACleanup();
    return 0;
}