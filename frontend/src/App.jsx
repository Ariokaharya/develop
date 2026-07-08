import { useEffect, useState } from "react";

export default function App() {
  const [message, setMessage] = useState("Loading...");
  const [timestamp, setTimestamp] = useState("");

  useEffect(() => {
    fetch("/api/message")
      .then((res) => {
        if (!res.ok) {
          throw new Error(`HTTP error: ${res.status}`);
        }
        return res.json();
      })
      .then((data) => {
        setMessage(data.message);
        setTimestamp(data.timestamp);
      })
      .catch((error) => {
        setMessage(`API request failed: ${error.message}`);
      });
  }, []);

  return (
    <main style={{ fontFamily: "sans-serif", padding: "24px" }}>
      <h1>Codespaces FE / BE Test</h1>

      <section>
        <h2>Backend API Response</h2>
        <p>{message}</p>
        {timestamp && <p>timestamp: {timestamp}</p>}
      </section>
    </main>
  );
}