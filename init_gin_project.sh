#!/bin/bash

# === 1. Nomni tekshirish ===
if [ -z "$1" ]; then
  echo "❌ Iltimos loyiha nomini kiriting:"
  echo "   misol: bash init_gin_project.sh balans-api"
  exit 1
fi

APP_NAME=$1

# === 2. Katalog tuzilmasini yaratish ===
echo "📁 $APP_NAME loyihasi yaratilmoqda..."
mkdir -p $APP_NAME/{internal/{server,handler,service,repository,model,config},pkg/utils}

# === 3. Go mod va fayllar yaratish ===
cd $APP_NAME
go mod init $APP_NAME > /dev/null 2>&1
go get github.com/gin-gonic/gin > /dev/null 2>&1

# === 4. Minimal fayllarni yozish ===

# main.go
cat <<EOF > main.go
package main

import "$APP_NAME/internal/server"

func main() {
  r := server.SetupRouter()
  r.Run(":8080")
}
EOF

# internal/server/router.go
mkdir -p internal/server
cat <<EOF > internal/server/router.go
package server

import (
  "github.com/gin-gonic/gin"
  "$APP_NAME/internal/handler"
)

func SetupRouter() *gin.Engine {
  r := gin.Default()

  userHandler := handler.NewUserHandler()
  r.GET("/users", userHandler.GetUsers)

  return r
}
EOF

# internal/handler/user_handler.go
mkdir -p internal/handler
cat <<EOF > internal/handler/user_handler.go
package handler

import (
  "net/http"
  "github.com/gin-gonic/gin"
)

type UserHandler struct{}

func NewUserHandler() *UserHandler {
  return &UserHandler{}
}

func (h *UserHandler) GetUsers(c *gin.Context) {
  users := []map[string]any{
    {"id": 1, "name": "Islombek"},
    {"id": 2, "name": "Muhriddin"},
  }
  c.JSON(http.StatusOK, gin.H{"users": users})
}
EOF

# === 5. Tayyor deylik ===
echo "✅ $APP_NAME loyihasi tayyor!"
echo "➡  Ishga tushirish: cd $APP_NAME && go run main.go"
