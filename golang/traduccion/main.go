package main

import (
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"regexp"
	"strconv"
	"strings"
)

func numeroALetrasIngles(numero int) (string, error) {
	urlServicio := "https://www.dataaccess.com/webservicesserver/NumberConversion.wso"

	soapEnvelope := fmt.Sprintf(`<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xmlns:xsd="http://www.w3.org/2001/XMLSchema"
               xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <NumberToWords xmlns="http://www.dataaccess.com/webservicesserver/">
      <ubiNum>%d</ubiNum>
    </NumberToWords>
  </soap:Body>
</soap:Envelope>`, numero)

	req, err := http.NewRequest("POST", urlServicio, strings.NewReader(soapEnvelope))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "text/xml; charset=utf-8")
	req.Header.Set("SOAPAction", "http://www.dataaccess.com/webservicesserver/NumberToWords")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	re := regexp.MustCompile(`<m:NumberToWordsResult>(.*?)</m:NumberToWordsResult>`)
	match := re.FindStringSubmatch(string(body))
	if len(match) < 2 {
		return "", fmt.Errorf("no se pudo obtener el resultado")
	}

	return match[1], nil
}

func traducirAEspanol(texto string) (string, error) {
	textoCodificado := url.QueryEscape(texto)
	urlTraduccion := "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=es&dt=t&q=" + textoCodificado

	resp, err := http.Get(urlTraduccion)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	re := regexp.MustCompile(`\[\[\["(.*?)"`)
	match := re.FindStringSubmatch(string(body))
	if len(match) < 2 {
		return "", fmt.Errorf("no se pudo traducir")
	}

	return match[1], nil
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Uso: go run main.go <numero>")
		return
	}

	numero, err := strconv.Atoi(os.Args[1])
	if err != nil {
		fmt.Println("El argumento debe ser un numero")
		return
	}

	letrasIngles, err := numeroALetrasIngles(numero)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	letrasEspanol, err := traducirAEspanol(letrasIngles)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	fmt.Printf("Numero: %d\n", numero)
	fmt.Printf("En letras (ingles): %s\n", letrasIngles)
	fmt.Printf("En letras (espanol): %s\n", letrasEspanol)
}