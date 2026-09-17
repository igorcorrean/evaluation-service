# Estágio 1: Compilação
FROM golang:1.24-alpine AS builder

# Instala o git (às vezes pacotes do Go precisam dele para baixar dependências)
RUN apk add --no-cache git

WORKDIR /app

# Copia os arquivos de dependências de módulo
COPY go.mod go.sum ./

# --- ISSO RESOLVE O SEU PROBLEMA ---
# Organiza e limpa as hashes do go.sum antes de tentar baixar
RUN go mod tidy
RUN go mod download

# Copia o resto do código fonte
COPY . .

# Compila o binário de forma estática para produção
RUN CGO_ENABLED=0 GOOS=linux go build -o evaluation-service .

# Estágio 2: Execução (Imagem final limpa)
FROM alpine:latest

WORKDIR /app

# Copia o binário compilado do estágio anterior
COPY --from=builder /app/evaluation-service .

# Expõe a porta que a sua aplicação usa
EXPOSE 8004

# Comando para rodar a aplicação
CMD ["./evaluation-service"]