require 'webrick'
require 'json'

UNIDADES = %w[cero uno dos tres cuatro cinco seis siete ocho nueve diez once doce trece catorce quince dieciseis diecisiete dieciocho diecinueve veinte]
DECENAS = ["", "", "veinte", "treinta", "cuarenta", "cincuenta", "sesenta", "setenta", "ochenta", "noventa"]
CENTENAS = ["", "ciento", "doscientos", "trescientos", "cuatrocientos", "quinientos", "seiscientos", "setecientos", "ochocientos", "novecientos"]

def convertir(numero)
  return "cero" if numero == 0
  return "menos " + convertir(-numero) if numero < 0
  return numero.to_s if numero > 999999

  if numero >= 1000
    miles = numero / 1000
    resto = numero % 1000
    prefijo = miles == 1 ? "mil" : "#{convertir(miles)} mil"
    return resto == 0 ? prefijo : "#{prefijo} #{convertir(resto)}"
  end

  if numero >= 100
    return "cien" if numero == 100
    centena = numero / 100
    resto = numero % 100
    prefijo = CENTENAS[centena]
    return resto == 0 ? prefijo : "#{prefijo} #{convertir(resto)}"
  end

  return UNIDADES[numero] if numero <= 20

  decena = numero / 10
  unidad = numero % 10
  return DECENAS[decena] if unidad == 0
  return "veinti#{UNIDADES[unidad]}" if decena == 2
  "#{DECENAS[decena]} y #{UNIDADES[unidad]}"
end

server = WEBrick::HTTPServer.new(Port: 8082)

server.mount_proc '/convertir' do |req, res|
  numero_param = req.query['numero']
  res['Content-Type'] = 'application/json; charset=utf-8'
  if numero_param.nil? || numero_param !~ /\A-?\d+\z/
    res.status = 400
    res.body = { error: "Proporciona un numero valido, ej: /convertir?numero=123" }.to_json
  else
    numero = numero_param.to_i
    res.body = { numero: numero, letras: convertir(numero) }.to_json
  end
end

trap 'INT' do server.shutdown end
puts "Servidor escuchando en http://localhost:8082"
puts "Prueba: http://localhost:8082/convertir?numero=123"
server.start