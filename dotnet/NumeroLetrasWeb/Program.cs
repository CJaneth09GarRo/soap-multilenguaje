var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

// Ejemplo de uso: http://localhost:5000/convertir?numero=123
app.MapGet("/convertir", (string? numero) =>
{
    if (string.IsNullOrEmpty(numero) || !int.TryParse(numero, out int valor))
    {
        return Results.BadRequest(new { error = "Proporciona un numero valido, ej: /convertir?numero=123" });
    }

    string letras = NumeroALetras.Convertir(valor);

    return Results.Ok(new { numero = valor, letras });
});

app.Run();

static class NumeroALetras
{
    static readonly string[] Unidades =
    {
        "cero", "uno", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve",
        "diez", "once", "doce", "trece", "catorce", "quince", "dieciseis", "diecisiete",
        "dieciocho", "diecinueve", "veinte"
    };

    static readonly string[] Decenas =
    {
        "", "", "veinte", "treinta", "cuarenta", "cincuenta", "sesenta", "setenta", "ochenta", "noventa"
    };

    static readonly string[] Centenas =
    {
        "", "ciento", "doscientos", "trescientos", "cuatrocientos", "quinientos",
        "seiscientos", "setecientos", "ochocientos", "novecientos"
    };

    public static string Convertir(int numero)
    {
        if (numero == 0) return "cero";
        if (numero < 0) return "menos " + Convertir(-numero);
        if (numero > 999999) return numero.ToString();

        if (numero >= 1000)
        {
            int miles = numero / 1000;
            int resto = numero % 1000;
            string prefijoMiles = miles == 1 ? "mil" : $"{Convertir(miles)} mil";
            return resto == 0 ? prefijoMiles : $"{prefijoMiles} {Convertir(resto)}";
        }

        if (numero >= 100)
        {
            int centena = numero / 100;
            int resto = numero % 100;
            if (numero == 100) return "cien";
            string prefijoCentena = Centenas[centena];
            return resto == 0 ? prefijoCentena : $"{prefijoCentena} {Convertir(resto)}";
        }

        if (numero <= 20) return Unidades[numero];

        int decena = numero / 10;
        int unidad = numero % 10;
        if (unidad == 0) return Decenas[decena];
        if (decena == 2) return $"veinti{Unidades[unidad]}";
        return $"{Decenas[decena]} y {Unidades[unidad]}";
    }
}