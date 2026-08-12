import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Traduccion {

    public static void main(String[] args) throws IOException, InterruptedException {
        if (args.length == 0) {
            System.err.println("Uso: java Traduccion <numero>");
            return;
        }

        int numero = Integer.parseInt(args[0]);
        String letrasIngles = numeroALetrasIngles(numero);
        String letrasEspanol = traducirAEspanol(letrasIngles);

        System.out.println("Numero: " + numero);
        System.out.println("En letras (ingles): " + letrasIngles);
        System.out.println("En letras (espanol): " + letrasEspanol);
    }

    static String numeroALetrasIngles(int numero) throws IOException, InterruptedException {
        String url = "https://www.dataaccess.com/webservicesserver/NumberConversion.wso";

        String soapEnvelope = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
            + "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
            + "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
            + "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
            + "<soap:Body>"
            + "<NumberToWords xmlns=\"http://www.dataaccess.com/webservicesserver/\">"
            + "<ubiNum>" + numero + "</ubiNum>"
            + "</NumberToWords>"
            + "</soap:Body>"
            + "</soap:Envelope>";

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(url))
            .header("Content-Type", "text/xml; charset=utf-8")
            .header("SOAPAction", "http://www.dataaccess.com/webservicesserver/NumberToWords")
            .POST(HttpRequest.BodyPublishers.ofString(soapEnvelope))
            .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

        Pattern pattern = Pattern.compile("<m:NumberToWordsResult>(.*?)</m:NumberToWordsResult>");
        Matcher matcher = pattern.matcher(response.body());

        if (matcher.find()) {
            return matcher.group(1);
        }
        return "No se pudo obtener el resultado";
    }

    static String traducirAEspanol(String texto) throws IOException, InterruptedException {
        String textoCodificado = URLEncoder.encode(texto, StandardCharsets.UTF_8);
        String url = "https://translate.googleapis.com/translate_a/single"
            + "?client=gtx&sl=en&tl=es&dt=t&q=" + textoCodificado;

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(url))
            .GET()
            .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

        // La respuesta es un JSON anidado tipo: [[["texto traducido","texto original",null,null,1]],null,"en"]
        // Extraemos el primer string entre comillas dentro de ese arreglo.
        Pattern pattern = Pattern.compile("\\[\\[\\[\"(.*?)\"");
        Matcher matcher = pattern.matcher(response.body());

        if (matcher.find()) {
            return matcher.group(1);
        }
        return "No se pudo traducir";
    }
}