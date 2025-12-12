# 🚀 RideFast — Plataforma de Corridas estilo Uber (API em Elixir + Phoenix)

A **RideFast API** é uma plataforma completa inspirada em aplicativos de transporte como Uber.  
Desenvolvida com **Elixir + Phoenix**, oferece um backend robusto com autenticação JWT, gerenciamento de usuários, motoristas, veículos, corridas, idiomas, avaliações e pagamentos.

---

## 🧱 Tecnologias Utilizadas

- **Elixir 1.17+**
- **Phoenix 1.7**
- **MySQL** (Ecto)
- **Guardian (JWT Auth)**
- **Bandit HTTP Server**
- **Esbuild**
- **TailwindCSS 4**
- **Phoenix Live Reload**

---

## 📌 Funcionalidades Principais

### 🔑 Autenticação
- Registro e login com JWT
- Controle de acesso por roles (`user`, `admin`, `driver`)

### 👤 Usuários
- Listagem de usuários (admin)
- Perfis individuais

### 🚗 Motoristas (Drivers)
- CRUD completo
- Perfil com idiomas
- Filtros públicos:
  - `?status=ACTIVE`
  - `?language=en`

### 🛞 Veículos
- Vínculo com o motorista
- Informações de placa, categoria e capacidade

### 🧭 Corridas (Rides)
- Criação de corrida
- Estados da corrida
- Motorista ↔ Usuário ↔ Corrida

### 💳 Pagamentos
- Métodos: `CARD`, `CASH`, `PIX`
- Status: `PENDING`, `PAID`, `FAILED`
- Um pagamento por corrida

### ⭐ Avaliações (Ratings)
- Usuário avalia motorista
- Score 1–5
- Comentários e validações

### 🌐 Idiomas
- CRUD de idiomas (admin)
- Associação entre motorista e idiomas

---

## 🗂 Estrutura do Projeto

ride_fast/
├── lib/
│ ├── ride_fast/
│ │ ├── accounts/ # Usuários, motoristas, auth
│ │ ├── rides/ # Corridas e eventos
│ │ ├── payments/ # Pagamentos
│ │ ├── languages/ # Idiomas
│ │ └── ratings/ # Avaliações
│ └── ride_fast_web/ # Controllers, Views, Router
│
├── priv/repo/migrations # Migrations MySQL
├── assets/ # Tailwind / JS
├── config/ # dev, prod, runtime
└── README.md
