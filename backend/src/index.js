import express from "express";
import cors from "cors";

const app = express();
const port = 8080;
const key = "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456";

app.use(cors());
app.use(express.json());

app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    service: "backend"
  });
});

app.get("/api/message", (req, res) => {
  res.json({
    message: "Hello from Backend API",
    timestamp: new Date().toISOString()
  });
});

app.listen(port, "0.0.0.0", () => {
  console.log(`Backend API listening on port ${port}`);
});