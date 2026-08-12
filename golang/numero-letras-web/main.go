package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
)

var unidades = []string{"cero", "uno", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve", "diez", "once", "doce", "trece", "catorce", "quince", "dieciseis", "diecisiete", "dieciocho", "diecinueve", "veinte"}
var decenas = []string{"", "", "veinte", "treinta", "cuarenta", "cincuenta", "sesenta", "setenta", "ochenta", "noventa"}
var centenas = []string{"", "ciento", "doscientos", "trescientos", "cuatrocientos", "quinientos", "seiscientos", "setecientos", "ochocientos", "novecientos"}

func convertir(numero int) string {
	if numero == 0 {
		return "cero"
	}
	if numero < 0 {
		return "menos " + convertir(-numero)
	}
	if numero > 999999 {
		return strconv.Itoa(numero)
	}
	if numero >= 1000 {
		miles := numero / 1000
		resto := numero % 1000
		prefijo := "mil"
		if miles != 1 {
			prefijo = convertir(miles) + " mil"
		}
		if resto == 0 {
			return prefijo
		}
		return prefijo + " " + convertir(resto)
	}
	if numero >= 100 {
		if numero == 100 {
			return "cien"
		}
		centena := numero / 100
		resto := numero % 100
		if resto == 0 {
			return centenas[centena]
		}
		return centenas[centena] + " " + convertir(resto)
	}
	if numero <= 20 {
		return unidades[numero]
	}
	decena := numero / 10
	unidad := numero % 10
	if unidad == 0 {
		return decenas[decena]
	}
	if decena == 2 {
		return "veinti" + unidades[unidad]
	}
	return decenas[decena] + " y " + unidades[unidad]
}

func main() {
	http.HandleFunc("/convertir", func(w http.ResponseWriter, r *http.Request) {
		numeroParam := r.URL.Query().Get("numero")
		numero, err := strconv.Atoi(numeroParam)
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		if numeroParam == "" || err != nil {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(map[string]string{"error": "Proporciona un numero valido, ej: /convertir?numero=123"})
			return
		}
		letras := convertir(numero)
		json.NewEncoder(w).Encode(map[string]interface{}{"numero": numero, "letras": letras})
	})
	fmt.Println("Servidor escuchando en http://localhost:8081")
	fmt.Println("Prueba: http://localhost:8081/convertir?numero=123")
	http.ListenAndServe(":8081", nil)
}