#!/bin/sh

# Переходим в родительскую директорию (где app_v2.py)
cd "$(dirname "$0")/.." || exit

# Запускаем сервер в фоне
python3 app_v2.py &
SERVER_PID=$!

# Ждем запуска сервера
sleep 2

# Проверяем эндпоинт /time
echo "Testing /time endpoint..."
TIME_RESPONSE=$(curl -s http://localhost:3030/time)
if ! echo "$TIME_RESPONSE" | grep -q '"time"'; then
  echo "Test failed: /time response format"
  kill $SERVER_PID
  exit 1
fi

# Проверяем счетчик метрик
INITIAL_COUNT=$(curl -s http://localhost:3030/metrics | jq -r '.count')

# Делаем запрос к /time
curl -s http://localhost:3030/time > /dev/null

# Проверяем обновление счетчика
UPDATED_COUNT=$(curl -s http://localhost:3030/metrics | jq -r '.count')

if [ "$UPDATED_COUNT" -ne $((INITIAL_COUNT + 1)) ]; then
  echo "Test failed: Counter not incremented ($INITIAL_COUNT -> $UPDATED_COUNT)"
  kill $SERVER_PID
  exit 1
fi

echo "All tests passed"
kill $SERVER_PID
