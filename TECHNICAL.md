# HairPredict Technical Documentation & Architecture

HairPredict is an AI-powered hair health analysis and virtual style try-on mobile application. This document outlines the technical architecture, technology stack, and backend orchestration flows built for the Qwen AI Hackathon.

---

## 🏗️ System Architecture

```mermaid
graph TD
    subgraph Mobile Frontend (Flutter & Dart)
        UI[Flutter UI / Widgets] <--> Controller[StyleTryOnController / State]
        Controller <--> Cache[Local Disk Cache / SQLite]
        Controller <--> Hardware[Camera & Image Picker]
    end

    subgraph Backend Engine (Dockerized Node.js & Express)
        API[API Gateway / Server] <--> Jobs[BullMQ / Redis Queue]
        Jobs <--> Workers[Asynchronous Workers]
    end

    subgraph AI & Processing Pipeline
        Workers <--> Qwen[Qwen AI Cloud / DashScope API]
        Workers <--> PDF[PDFKit Document Generator]
    end

    subgraph Integrations & Messaging
        Workers <--> Paystack[Paystack Payment Gateway]
        n8n[n8n Workflow Automation] <--> WAHA[WAHA WhatsApp HTTP API]
    end

    UI -->|Upload Photos / Request Analysis| API
    WAHA -->|Automated WhatsApp Coaching| UI
    n8n -->|Routinely Trigger Workflows| WAHA
```

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Mobile Frontend** | Flutter & Dart | Cross-platform high-performance iOS and Android client. |
| **State Management** | BLoC / Controller | Reactive UI state management and Clean Architecture. |
| **Backend API** | Node.js, Express, Docker | Decoupled, containerized server ecosystem. |
| **AI Models** | Qwen AI (DashScope API) | Visual analysis, spatial perception, object grounding, and image generation. |
| **Background Jobs** | BullMQ & Redis | Message-driven async queue processing for heavy AI tasks. |
| **Automation** | n8n & WAHA (WhatsApp HTTP API) | Flow orchestration and automated WhatsApp coaching. |
| **Payments** | Paystack | Secure payment processing for premium features and bookings. |
| **Reporting** | PDFKit | On-the-fly PDF dossier generation for hair health. |
| **Documentation** | Swagger / OpenAPI | Rigid backend API endpoint specification and documentation. |

---

## 📱 Mobile Architecture (Frontend)

The mobile client is built on **Flutter** utilizing **Clean Architecture** patterns:
- **Presentation Layer**: Widgets and pages (e.g. `HairCaptureScreen`) interact directly with the `StyleTryOnController` (BLoC structure) to map UI actions to system events.
- **Domain Layer**: Base Use Cases (e.g. `GenerateHair3DRender`) define pure business logic interfaces, abstracting repository implementations.
- **Data Layer**: Repositories interact with the local cache or remote REST clients.
- **Offline-First Capabilities**: Disk caching and background prefetching ensure fluid user experience under low-bandwidth network environments.

---

## 🧠 Backend & AI Pipeline

### 1. Vision & Space Modeling
The core intelligence leverages **Qwen AI's native vision-language architecture**:
- **Spatial Perception & Grounding**: Used to accurately map locs, coils, and complex African hair textures directly onto face pictures.
- **Hair Diagnostics**: Evaluates structural strand health, texture parameters, and predicts chemical routine impacts over time.

### 2. Async Queue Processing
To prevent main thread blocking during intensive AI tasks:
1. Incoming images are validated using **Zod**.
2. Tasks are dispatched as jobs into **BullMQ** backed by **Redis**.
3. Background workers retrieve jobs, call the **Qwen Cloud APIs**, and generate visual assets/PDF dossiers synchronously without degrading API Gateway response times.

---

## 🔄 Integrations & Automations

- **WhatsApp Coaching**: Connected via **n8n** workflows and **WAHA** (WhatsApp HTTP API) to automatically send daily routines and follow-up checks.
- **Localized E-commerce**: Integrated **Paystack** for booking local trichologists and purchasing recommended products.
- **Health Dossiers**: Custom PDF dossiers are compiled on-the-fly via **PDFKit** to outline diagnostics and hair timelines.

---

## ⚠️ Challenges & Resolutions

1. **Memory & Render Bottlenecks**: Rendering visual overlays of complex coily hair patterns (like coily textures and locs) on mid-range devices caused frame drops. *Resolution:* Frontend rendering overlays were optimized in Flutter, utilizing low-overhead vector rendering and path optimization.
2. **AI Payload Queues**: Concurrently processing high-resolution imagery through vision models risked API timeouts. *Resolution:* Configured rigid retry logic and rate limit thresholds inside BullMQ background queues to smoothly control concurrent requests.
