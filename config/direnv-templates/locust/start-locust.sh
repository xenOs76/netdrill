❯ cat start-headless-locust.sh
#!/usr/bin/env bash

locust -f locustfile.py -H https://dest.host.address
