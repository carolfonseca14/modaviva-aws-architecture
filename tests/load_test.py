import concurrent.futures
import urllib.request
import time

URL = "http://modaviva-alb-528199344.us-east-1.elb.amazonaws.com/load-test"
WORKERS = 20
DURATION = 300

def request(_):
    try:
        with urllib.request.urlopen(URL, timeout=120) as response:
            return response.status
    except Exception as e:
        return f"ERRO: {e}"

print(f"Iniciando teste por {DURATION} segundos com {WORKERS} workers...", flush=True)

end_time = time.time() + DURATION
total = 0
success = 0

with concurrent.futures.ThreadPoolExecutor(max_workers=WORKERS) as executor:
    while time.time() < end_time:
        batch = list(executor.map(request, range(WORKERS)))
        total += len(batch)
        success += sum(r == 200 for r in batch)
        print(f"{time.strftime('%H:%M:%S')} | requisicoes: {total} | sucesso: {success}", flush=True)

print(f"Teste finalizado. Total: {total} | Sucesso: {success}", flush=True)
