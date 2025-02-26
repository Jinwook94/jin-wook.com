import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "./index.css";
import BootstrapApp from "@/components/BootstrapApp.tsx";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <BootstrapApp />
  </StrictMode>,
);
