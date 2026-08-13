use strict;
use warnings;
use HTTP::Daemon;
use HTTP::Status;
use URI;
use JSON::PP;

my @UNIDADES = qw(cero uno dos tres cuatro cinco seis siete ocho nueve diez once doce trece catorce quince dieciseis diecisiete dieciocho diecinueve veinte);
my @DECENAS  = ("", "", "veinte", "treinta", "cuarenta", "cincuenta", "sesenta", "setenta", "ochenta", "noventa");
my @CENTENAS = ("", "ciento", "doscientos", "trescientos", "cuatrocientos", "quinientos", "seiscientos", "setecientos", "ochocientos", "novecientos");

sub convertir {
    my ($numero) = @_;
    return "cero" if $numero == 0;
    return "menos " . convertir(-$numero) if $numero < 0;
    return "$numero" if $numero > 999999;

    if ($numero >= 1000) {
        my $miles = int($numero / 1000);
        my $resto = $numero % 1000;
        my $prefijo = $miles == 1 ? "mil" : convertir($miles) . " mil";
        return $resto == 0 ? $prefijo : "$prefijo " . convertir($resto);
    }

    if ($numero >= 100) {
        return "cien" if $numero == 100;
        my $centena = int($numero / 100);
        my $resto = $numero % 100;
        my $prefijo = $CENTENAS[$centena];
        return $resto == 0 ? $prefijo : "$prefijo " . convertir($resto);
    }

    return $UNIDADES[$numero] if $numero <= 20;

    my $decena = int($numero / 10);
    my $unidad = $numero % 10;
    return $DECENAS[$decena] if $unidad == 0;
    return "veinti$UNIDADES[$unidad]" if $decena == 2;
    return "$DECENAS[$decena] y $UNIDADES[$unidad]";
}

my $daemon = HTTP::Daemon->new(LocalPort => 8083) || die "No se pudo iniciar el servidor";
print "Servidor escuchando en ", $daemon->url, "\n";
print "Prueba: ", $daemon->url, "convertir?numero=123\n";

while (my $conexion = $daemon->accept) {
    while (my $peticion = $conexion->get_request) {
        if ($peticion->method eq 'GET' and $peticion->uri->path eq '/convertir') {
            my $uri = URI->new($peticion->uri);
            my %params = $uri->query_form;
            my $numero_param = $params{numero};

            my $respuesta = HTTP::Response->new(200);
            $respuesta->header('Content-Type' => 'application/json; charset=utf-8');

            if (!defined $numero_param || $numero_param !~ /^-?\d+$/) {
                $respuesta->code(400);
                $respuesta->content(encode_json({ error => "Proporciona un numero valido, ej: /convertir?numero=123" }));
            } else {
                my $numero = int($numero_param);
                my $letras = convertir($numero);
                $respuesta->content(encode_json({ numero => $numero, letras => $letras }));
            }

            $conexion->send_response($respuesta);
        } else {
            $conexion->send_error(404);
        }
    }
    $conexion->close;
    undef($conexion);
}