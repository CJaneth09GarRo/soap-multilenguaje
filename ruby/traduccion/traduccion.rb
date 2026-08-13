require 'net/http'
require 'uri'
require 'json'
require 'resolv'

def resolver_ipv4(host)
  Resolv.getaddresses(host).find { |ip| ip =~ Resolv::IPv4::Regex }
end

def numero_a_letras_ingles(numero)
  url = URI("https://www.dataaccess.com/webservicesserver/NumberConversion.wso")
  ipv4 = resolver_ipv4(url.host)

  soap_envelope = <<~XML
    <?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <NumberToWords xmlns="http://www.dataaccess.com/webservicesserver/">
          <ubiNum>#{numero}</ubiNum>
        </NumberToWords>
      </soap:Body>
    </soap:Envelope>
  XML

  http = Net::HTTP.new(url.host, url.port)
  http.ipaddr = ipv4 if ipv4
  http.use_ssl = true
  http.open_timeout = 10
  http.read_timeout = 10

  request = Net::HTTP::Post.new(url)
  request['Content-Type'] = 'text/xml; charset=utf-8'
  request['SOAPAction'] = 'http://www.dataaccess.com/webservicesserver/NumberToWords'
  request.body = soap_envelope

  response = http.request(request)
  match = response.body.match(%r{<m:NumberToWordsResult>(.*?)</m:NumberToWordsResult>})
  match ? match[1] : "No se pudo obtener el resultado"
end

def traducir_a_espanol(texto)
  texto_codificado = URI.encode_www_form_component(texto)
  url = URI("https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=es&dt=t&q=#{texto_codificado}")
  ipv4 = resolver_ipv4(url.host)

  http = Net::HTTP.new(url.host, url.port)
  http.ipaddr = ipv4 if ipv4
  http.use_ssl = true
  http.open_timeout = 10
  http.read_timeout = 10

  response = http.get(url.request_uri)
  data = JSON.parse(response.body)
  data[0][0][0]
end

if ARGV.empty?
  puts "Uso: ruby traduccion.rb <numero>"
  exit
end

numero = ARGV[0].to_i
letras_ingles = numero_a_letras_ingles(numero)
letras_espanol = traducir_a_espanol(letras_ingles)
puts "Numero: #{numero}"
puts "En letras (ingles): #{letras_ingles}"
puts "En letras (espanol): #{letras_espanol}"