import soap from "soap";

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

// El numero se recibe como argumento de linea de comandos,
// simulando el parametro que en la app web vendria en la URL.
// Ejemplo de uso: node index.js 123
const numeroArg = process.argv[2];

if (!numeroArg || isNaN(Number(numeroArg))) {
  console.error("Uso: node index.js <numero>");
  process.exit(1);
}

numeroALetrasIngles(Number(numeroArg))
  .then((letras) => {
    console.log(`Numero: ${numeroArg}`);
    console.log(`En letras (ingles): ${letras}`);
  })
  .catch((err) => {
    console.error("Error consumiendo el servicio SOAP:", err.message);
    process.exit(1);
  });