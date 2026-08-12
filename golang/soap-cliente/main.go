package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"regexp"
	"strconv"
	"strings"
)

func numeroALetrasIngles(numero int) (string, error) {
	url := "https://www.dataaccess.com/webservicesserver/NumberConversion.wso"

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

	req, err := http.NewRequest("POST", url, strings.NewReader(soapEnvelope))
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

	fmt.Printf("Numero: %d\n", numero)
	fmt.Printf("En letras (ingles): %s\n", letrasIngles)
}
