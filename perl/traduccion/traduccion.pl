use strict;
use warnings;
use LWP::UserAgent;
use URI::Escape;
use JSON::PP;

sub numero_a_letras_ingles {
    my ($numero) = @_;
    my $url = "https://www.dataaccess.com/webservicesserver/NumberConversion.wso";

    my $soap_envelope = qq{<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xmlns:xsd="http://www.w3.org/2001/XMLSchema"
               xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <NumberToWords xmlns="http://www.dataaccess.com/webservicesserver/">
      <ubiNum>$numero</ubiNum>
    </NumberToWords>
  </soap:Body>
</soap:Envelope>};

    my $ua = LWP::UserAgent->new(timeout => 15);
    my $response = $ua->post(
        $url,
        'Content-Type' => 'text/xml; charset=utf-8',
        'SOAPAction'   => 'http://www.dataaccess.com/webservicesserver/NumberToWords',
        Content        => $soap_envelope
    );

    my $body = $response->decoded_content;
    if ($body =~ m{<m:NumberToWordsResult>(.*?)</m:NumberToWordsResult>}) {
        return $1;
    }
    return "No se pudo obtener el resultado";
}

sub traducir_a_espanol {
    my ($texto) = @_;
    my $texto_codificado = uri_escape($texto);
    my $url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=es&dt=t&q=$texto_codificado";

    my $ua = LWP::UserAgent->new(timeout => 15);
    my $response = $ua->get($url);
    my $data = decode_json($response->decoded_content);

    return $data->[0][0][0];
}

my $numero = $ARGV[0];
unless (defined $numero) {
    print "Uso: perl traduccion.pl <numero>\n";
    exit;
}

my $letras_ingles  = numero_a_letras_ingles($numero);
my $letras_espanol = traducir_a_espanol($letras_ingles);
print "Numero: $numero\n";
print "En letras (ingles): $letras_ingles\n";
print "En letras (espanol): $letras_espanol\n";
