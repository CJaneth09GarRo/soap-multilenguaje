use tiny_http::{Server, Response, Header};
use url::Url;

fn unidades(n: i64) -> &'static str {
    const U: [&str; 21] = ["cero","uno","dos","tres","cuatro","cinco","seis","siete","ocho","nueve","diez","once","doce","trece","catorce","quince","dieciseis","diecisiete","dieciocho","diecinueve","veinte"];
    U[n as usize]
}

fn decenas(n: i64) -> &'static str {
    const D: [&str; 10] = ["", "", "veinte", "treinta", "cuarenta", "cincuenta", "sesenta", "setenta", "ochenta", "noventa"];
    D[n as usize]
}

fn centenas(n: i64) -> &'static str {
    const C: [&str; 10] = ["", "ciento", "doscientos", "trescientos", "cuatrocientos", "quinientos", "seiscientos", "setecientos", "ochocientos", "novecientos"];
    C[n as usize]
}

fn convertir(numero: i64) -> String {
    if numero == 0 { return "cero".to_string(); }
    if numero < 0 { return format!("menos {}", convertir(-numero)); }
    if numero > 999999 { return numero.to_string(); }

    if numero >= 1000 {
        let miles = numero / 1000;
        let resto = numero % 1000;
        let prefijo = if miles == 1 { "mil".to_string() } else { format!("{} mil", convertir(miles)) };
        return if resto == 0 { prefijo } else { format!("{} {}", prefijo, convertir(resto)) };
    }

    if numero >= 100 {
        if numero == 100 { return "cien".to_string(); }
        let centena = numero / 100;
        let resto = numero % 100;
        let prefijo = centenas(centena);
        return if resto == 0 { prefijo.to_string() } else { format!("{} {}", prefijo, convertir(resto)) };
    }

    if numero <= 20 { return unidades(numero).to_string(); }

    let decena = numero / 10;
    let unidad = numero % 10;
    if unidad == 0 { return decenas(decena).to_string(); }
    if decena == 2 { return format!("veinti{}", unidades(unidad)); }
    format!("{} y {}", decenas(decena), unidades(unidad))
}

fn main() {
    let server = Server::http("0.0.0.0:8084").unwrap();
    println!("Servidor escuchando en http://localhost:8084");
    println!("Prueba: http://localhost:8084/convertir?numero=123");

    for request in server.incoming_requests() {
        let url_completa = format!("http://localhost{}", request.url());
        let parsed = Url::parse(&url_completa).unwrap();

        let numero_param = parsed
            .query_pairs()
            .find(|(k, _)| k == "numero")
            .map(|(_, v)| v.to_string());

        let header = Header::from_bytes(&b"Content-Type"[..], &b"application/json; charset=utf-8"[..]).unwrap();

        let (status, body) = match numero_param.and_then(|s| s.parse::<i64>().ok()) {
            Some(numero) => {
                let letras = convertir(numero);
                (200, serde_json::json!({ "numero": numero, "letras": letras }).to_string())
            }
            None => {
                (400, serde_json::json!({ "error": "Proporciona un numero valido, ej: /convertir?numero=123" }).to_string())
            }
        };

        let response = Response::from_string(body)
            .with_status_code(status)
            .with_header(header);

        let _ = request.respond(response);
    }
}