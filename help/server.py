import http.server  
from http.server import SimpleHTTPRequestHandler  
import socketserver  
  
class CORSRequestHandler(SimpleHTTPRequestHandler):  
    def end_headers(self):  
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")  
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")  
        super().end_headers()  
  
if __name__ == "__main__":  
    PORT = 8000  
    Handler = CORSRequestHandler  
  
    with socketserver.TCPServer(("", PORT), Handler) as httpd:  
        print("Serving on port", PORT)  
        httpd.serve_forever() 