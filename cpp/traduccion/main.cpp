#include <windows.h>
#include <winhttp.h>
#include <iostream>
#include <string>
#include <regex>

#pragma comment(lib, "winhttp.lib")

std::string numeroALetrasIngles(int numero) {
    std::string soapEnvelope =
        "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
        "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
        "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
        "<soap:Body>"
        "<NumberToWords xmlns=\"http://www.dataaccess.com/webservicesserver/\">"
        "<ubiNum>" + std::to_string(numero) + "</ubiNum>"
        "</NumberToWords>"
        "</soap:Body>"
        "</soap:Envelope>";

    HINTERNET hSession = WinHttpOpen(L"CppSoapCliente/1.0",
        WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
    HINTERNET hConnect = WinHttpConnect(hSession, L"www.dataaccess.com",
        INTERNET_DEFAULT_HTTPS_PORT, 0);
    HINTERNET hRequest = WinHttpOpenRequest(hConnect, L"POST",
        L"/webservicesserver/NumberConversion.wso",
        NULL, WINHTTP_NO_REFERER, WINHTTP_DEFAULT_ACCEPT_TYPES, WINHTTP_FLAG_SECURE);

    std::wstring headers =
        L"Content-Type: text/xml; charset=utf-8\r\n"
        L"SOAPAction: http://www.dataaccess.com/webservicesserver/NumberToWords\r\n";

    WinHttpSendRequest(hRequest, headers.c_str(), -1L,
        (LPVOID)soapEnvelope.c_str(), soapEnvelope.size(), soapEnvelope.size(), 0);
    WinHttpReceiveResponse(hRequest, NULL);

    std::string respuesta;
    DWORD dwSize = 0;
    do {
        DWORD dwDownloaded = 0;
        WinHttpQueryDataAvailable(hRequest, &dwSize);
        if (dwSize == 0) break;
        std::string buffer(dwSize, '\0');
        WinHttpReadData(hRequest, &buffer[0], dwSize, &dwDownloaded);
        respuesta += buffer;
    } while (dwSize > 0);

    WinHttpCloseHandle(hRequest);
    WinHttpCloseHandle(hConnect);
    WinHttpCloseHandle(hSession);

    std::smatch match;
    std::regex re("<m:NumberToWordsResult>(.*?)</m:NumberToWordsResult>");
    if (std::regex_search(respuesta, match, re)) {
        return match[1].str();
    }
    return "No se pudo obtener el resultado";
}

std::string urlEncode(const std::string& texto) {
    std::string resultado;
    for (char c : texto) {
        if (isalnum((unsigned char)c)) {
            resultado += c;
        } else {
            char buf[4];
            sprintf(buf, "%%%02X", (unsigned char)c);
            resultado += buf;
        }
    }
    return resultado;
}

std::string traducirAEspanol(const std::string& texto) {
    std::string textoCodificado = urlEncode(texto);
    std::wstring path = L"/translate_a/single?client=gtx&sl=en&tl=es&dt=t&q=" +
        std::wstring(textoCodificado.begin(), textoCodificado.end());

    HINTERNET hSession = WinHttpOpen(L"CppTraduccion/1.0",
        WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
    HINTERNET hConnect = WinHttpConnect(hSession, L"translate.googleapis.com",
        INTERNET_DEFAULT_HTTPS_PORT, 0);
    HINTERNET hRequest = WinHttpOpenRequest(hConnect, L"GET", path.c_str(),
        NULL, WINHTTP_NO_REFERER, WINHTTP_DEFAULT_ACCEPT_TYPES, WINHTTP_FLAG_SECURE);

    WinHttpSendRequest(hRequest, WINHTTP_NO_ADDITIONAL_HEADERS, 0, WINHTTP_NO_REQUEST_DATA, 0, 0, 0);
    WinHttpReceiveResponse(hRequest, NULL);

    std::string respuesta;
    DWORD dwSize = 0;
    do {
        DWORD dwDownloaded = 0;
        WinHttpQueryDataAvailable(hRequest, &dwSize);
        if (dwSize == 0) break;
        std::string buffer(dwSize, '\0');
        WinHttpReadData(hRequest, &buffer[0], dwSize, &dwDownloaded);
        respuesta += buffer;
    } while (dwSize > 0);

    WinHttpCloseHandle(hRequest);
    WinHttpCloseHandle(hConnect);
    WinHttpCloseHandle(hSession);

    std::smatch match;
    std::regex re("\\[\\[\\[\"(.*?)\"");
    if (std::regex_search(respuesta, match, re)) {
        return match[1].str();
    }
    return "No se pudo traducir";
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cout << "Uso: main.exe <numero>" << std::endl;
        return 0;
    }

    int numero = std::stoi(argv[1]);
    std::string letrasIngles = numeroALetrasIngles(numero);
    std::string letrasEspanol = traducirAEspanol(letrasIngles);

    std::cout << "Numero: " << numero << std::endl;
    std::cout << "En letras (ingles): " << letrasIngles << std::endl;
    std::cout << "En letras (espanol): " << letrasEspanol << std::endl;

    return 0;
}