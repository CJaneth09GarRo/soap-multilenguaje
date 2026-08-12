import express from "express";
import { NumerosALetras } from "numero-a-letras";

const app = express();
const PUERTO = 3000;

// Ejemplo de uso: http://localhost:3000/convertir?numero=123
app.get("/convertir", (req, res) => {
  const numeroParam = req.query.numero;

  if (!numeroParam || isNaN(Number(numeroParam))) {
    return res
      .status(400)
      .json({ error: "Proporciona un numero valido, ej: /convertir?numero=123" });
  }

  const numero = Number(numeroParam);
  const letras = NumerosALetras(numero);

  res.json({
    numero,
    letras,
  });
});

app.listen(PUERTO, () => {
  console.log(`Servidor escuchando en http://localhost:${PUERTO}`);
  console.log(`Prueba: http://localhost:${PUERTO}/convertir?numero=123`);
});