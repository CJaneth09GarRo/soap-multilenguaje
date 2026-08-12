import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.net.URI;
import java.util.Map;

public class NumeroLetrasWeb {

    public static void main(String[] args) throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress(8080), 0);

        server.createContext("/convertir", exchange -> {
            Map<String, String> params = parseQuery(exchange.getRequestURI());
            String numeroParam = params.get("numero");

            String respuesta;
            int codigoEstado;

            if (numeroParam == null || !numeroParam.matches("-?\\d+")) {
                respuesta = "{\"error\":\"Proporciona un numero valido, ej: /convertir?numero=123\"}";
                codigoEstado = 400;
            } else {
                int numero = Integer.parseInt(numeroParam);
                String letras = convertir(numero);
                respuesta = "{\"numero\":" + numero + ",\"letras\":\"" + letras + "\"}";
                codigoEstado = 200;
            }

            exchange.getResponseHeaders().add("Content-Type", "application/json; charset=utf-8");
            byte[] bytes = respuesta.getBytes("UTF-8");
            exchange.sendResponseHeaders(codigoEstado, bytes.length);
            try (OutputStream os = exchange.getResponseBody()) {
                os.write(bytes);
            }
        });

        server.start();
        System.out.println("Servidor escuchando en http://localhost:8080");
        System.out.println("Prueba: http://localhost:8080/convertir?numero=123");
    }

    static Map<String, String> parseQuery(URI uri) {
        Map<String, String> params = new java.util.HashMap<>();
        String query = uri.getQuery();
        if (query == null) return params;

        for (String par : query.split("&")) {
            String[] partes = par.split("=");
            if (partes.length == 2) {
                params.put(partes[0], partes[1]);
            }
        }
        return params;
    }

    static final String[] UNIDADES = {
        "cero", "uno", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve",
        "diez", "once", "doce", "trece", "catorce", "quince", "dieciseis", "diecisiete",
        "dieciocho", "diecinueve", "veinte"
    };

    static final String[] DECENAS = {
        "", "", "veinte", "treinta", "cuarenta", "cincuenta", "sesenta", "setenta", "ochenta", "noventa"
    };

    static final String[] CENTENAS = {
        "", "ciento", "doscientos", "trescientos", "cuatrocientos", "quinientos",
        "seiscientos", "setecientos", "ochocientos", "novecientos"
    };

    static String convertir(int numero) {
        if (numero == 0) return "cero";
        if (numero < 0) return "menos " + convertir(-numero);
        if (numero > 999999) return String.valueOf(numero);

        if (numero >= 1000) {
            int miles = numero / 1000;
            int resto = numero % 1000;
            String prefijoMiles = miles == 1 ? "mil" : convertir(miles) + " mil";
            return resto == 0 ? prefijoMiles : prefijoMiles + " " + convertir(resto);
        }

        if (numero >= 100) {
            int centena = numero / 100;
            int resto = numero % 100;
            if (numero == 100) return "cien";
            String prefijoCentena = CENTENAS[centena];
            return resto == 0 ? prefijoCentena : prefijoCentena + " " + convertir(resto);
        }

        if (numero <= 20) return UNIDADES[numero];

        int decena = numero / 10;
        int unidad = numero % 10;
        if (unidad == 0) return DECENAS[decena];
        if (decena == 2) return "veinti" + UNIDADES[unidad];
        return DECENAS[decena] + " y " + UNIDADES[unidad];
    }
}
