import soap from "soap";
import { translate } from "@vitalets/google-translate-api";

const WSDL_URL =
  "https://www.dataaccess.com/webservicesserver/NumberConversion.wso?WSDL";

/**
 * Consume el servicio SOAP publico NumberConversion y devuelve
 * el numero convertido a letras en ingles.
 * @param {number} numero
 * @returns {Promise<string>}
 */
async function numeroALetrasIngles(numero) {
  const client = await soap.createClientAsync(WSDL_URL);
  const [result] = await client.NumberToWordsAsync({ ubiNum: numero });
  return result.NumberToWordsResult;
}

/**
 * Traduce un texto de ingles a espanol.
 * @param {string} texto
 * @returns {Promise<string>}
 */
async function traducirAEspanol(texto) {
  const resultado = await translate(texto, { from: "en", to: "es" });
  return resultado.text;
}

// El numero se recibe como argumento de linea de comandos,
// simulando el parametro que en la app web vendria en la URL.
// Ejemplo de uso: node traduccion.js 123
const numeroArg = process.argv[2];

if (!numeroArg || isNaN(Number(numeroArg))) {
  console.error("Uso: node traduccion.js <numero>");
  process.exit(1);
}

async function main() {
  try {
    const letrasIngles = await numeroALetrasIngles(Number(numeroArg));
    const letrasEspanol = await traducirAEspanol(letrasIngles);

    console.log(`Numero: ${numeroArg}`);
    console.log(`En letras (ingles): ${letrasIngles}`);
    console.log(`En letras (espanol): ${letrasEspanol}`);
  } catch (err) {
    console.error("Error:", err.message);
    process.exit(1);
  }
}

main();