using System.Text;
using System.Xml.Linq;

if (args.Length == 0 || !int.TryParse(args[0], out int numero))
{
    Console.Error.WriteLine("Uso: dotnet run <numero>");
    return;
}

string letrasIngles = await NumeroALetrasInglesAsync(numero);

Console.WriteLine($"Numero: {numero}");
Console.WriteLine($"En letras (ingles): {letrasIngles}");

static async Task<string> NumeroALetrasInglesAsync(int numero)
{
    const string url = "https://www.dataaccess.com/webservicesserver/NumberConversion.wso";

    string soapEnvelope = $@"<?xml version=""1.0"" encoding=""utf-8""?>
<soap:Envelope xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""
               xmlns:xsd=""http://www.w3.org/2001/XMLSchema""
               xmlns:soap=""http://schemas.xmlsoap.org/soap/envelope/"">
  <soap:Body>
    <NumberToWords xmlns=""http://www.dataaccess.com/webservicesserver/"">
      <ubiNum>{numero}</ubiNum>
    </NumberToWords>
  </soap:Body>
</soap:Envelope>";

    using var httpClient = new HttpClient();
    var content = new StringContent(soapEnvelope, Encoding.UTF8, "text/xml");
    content.Headers.Add("SOAPAction", "http://www.dataaccess.com/webservicesserver/NumberToWords");

    HttpResponseMessage response = await httpClient.PostAsync(url, content);
    string responseBody = await response.Content.ReadAsStringAsync();

    XDocument doc = XDocument.Parse(responseBody);
    XNamespace ns = "http://www.dataaccess.com/webservicesserver/";

    string? resultado = doc.Descendants(ns + "NumberToWordsResult").FirstOrDefault()?.Value;

    return resultado ?? "No se pudo obtener el resultado";
}