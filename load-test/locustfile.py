from locust import HttpUser, task, between

class SREUser(HttpUser):
    wait_time = between(1, 2)

    @task(1)
    def index(self):
        self.client.get("/")

    @task(3)
    def work(self):
        # Trigger CPU load to test HPA
        self.client.get("/work?n=500000")

    @task(1)
    def health(self):
        self.client.get("/health")
