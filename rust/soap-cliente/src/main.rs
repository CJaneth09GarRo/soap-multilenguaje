use regex::Regex;
use std::env;

fn numero_a_letras_ingles(numero: i64) -> Result<String, Box<dyn std::error::Error>> {
    let url = "https://www.dataaccess.com/webservicesserver/NumberConversion.wso";

    let soap_envelope = format!(
        r#"<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xmlns:xsd="http://www.w3.org/2001/XMLSchema"
               xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <NumberToWords xmlns="http://www.dataaccess.com/webservicesserver/">
      <ubiNum>{}</ubiNum>
    </NumberToWords>
  </soap:Body>
</soap:Envelope>"#,
        numero
    );

    let client = reqwest::blocking::Client::new();
    let response = client
        .post(url)
        .header("Content-Type", "text/xml; charset=utf-8")
        .header(
            "SOAPAction",
            "http://www.dataaccess.com/webservicesserver/NumberToWords",
        )
        .body(soap_envelope)
        .send()?;

    let body = response.text()?;

    let re = Regex::new(r"<m:NumberToWordsResult>(.*?)</m:NumberToWordsResult>")?;
    if let Some(caps) = re.captures(&body) {
        Ok(caps[1].to_string())
    } else {
        Ok("No se pudo obtener el resultado".to_string())
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        println!("Uso: cargo run -- <numero>");
        return;
    }

    let numero: i64 = args[1].parse().expect("El argumento debe ser un numero");

    match numero_a_letras_ingles(numero) {
        Ok(letras_ingles) => {
            println!("Numero: {}", numero);
            println!("En letras (ingles): {}", letras_ingles);
        }
        Err(e) => println!("Error: {}", e),
    }
}