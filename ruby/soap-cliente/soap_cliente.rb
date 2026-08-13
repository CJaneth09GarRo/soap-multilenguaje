require 'net/http'
require 'uri'
require 'resolv'

def numero_a_letras_ingles(numero)
  url = URI("https://www.dataaccess.com/webservicesserver/NumberConversion.wso")

  # Forzamos resolucion IPv4 para evitar timeout por IPv6
  ipv4 = Resolv.getaddresses(url.host).find { |ip| ip =~ Resolv::IPv4::Regex }

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

if ARGV.empty?
  puts "Uso: ruby soap_cliente.rb <numero>"
  exit
end

numero = ARGV[0].to_i
letras_ingles = numero_a_letras_ingles(numero)
puts "Numero: #{numero}"
puts "En letras (ingles): #{letras_ingles}"