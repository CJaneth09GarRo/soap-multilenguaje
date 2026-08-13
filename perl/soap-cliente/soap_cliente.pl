use strict;
use warnings;
use LWP::UserAgent;

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

my $numero = $ARGV[0];
unless (defined $numero) {
    print "Uso: perl soap_cliente.pl <numero>\n";
    exit;
}

my $letras_ingles = numero_a_letras_ingles($numero);
print "Numero: $numero\n";
print "En letras (ingles): $letras_ingles\n";