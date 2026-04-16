❯ cat start-headless-locust.sh
#!/usr/bin/env bash

locust -f locustfile.py --headless -u 1 -r 1 -H https://dest.host.address
