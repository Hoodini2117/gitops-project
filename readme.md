### GitOps DevOps Platform on AWS (EKS)
_____________________________________________________________________________________________________________________________________________________________________
A production-grade GitOps-driven CI/CD platform built on AWS, implementing secure, automated, and observable deployments using Kubernetes and modern DevOps practices.


```Developer → GitHub Repo
        ↓
GitHub Actions (CI Pipeline)
        ├── Docker Build
        ├── Trivy Scan
        └── Push to ECR
                ↓
        Amazon ECR (Image Registry)
                ↓
        ArgoCD (GitOps Controller)
                ↓
        Amazon EKS Cluster
                ↓
        Kubernetes (Deployment + Service)
                ↓
        AWS Load Balancer Controller
                ↓
        Application Load Balancer (ALB)
                ↓
        Internet 🌍
```
## TERRAFORM
The infrastructure was provisioned using Terraform with a modular approach, enabling clear separation of concerns and reusability. A custom VPC with public subnets across multiple availability zones was created to support high availability. An EKS cluster with managed node groups was deployed within this network, along with IAM roles for cluster components and CI/CD access. An ECR repository was also configured with encryption and image scanning enabled. The infrastructure design emphasized security, scalability, and proper network isolation.

## GitHub Actions CI pipeline
The CI pipeline was implemented using GitHub Actions and triggered on every push to the main branch. It builds a Docker image of the application, scans it for vulnerabilities using Trivy, and pushes it to Amazon ECR. Instead of using mutable tags like latest, images are tagged using the commit SHA, ensuring immutability and traceability. Authentication to AWS is handled using OIDC, eliminating the need for storing long-lived AWS credentials and improving overall security.

## CD using ArgoCD
ArgoCD was deployed inside the Kubernetes cluster to enable GitOps-based continuous delivery. It continuously monitors the Git repository for changes in Kubernetes manifests and synchronizes them with the cluster. This ensures that deployments are declarative and self-healing, automatically correcting any drift between the actual and desired states. This approach removes the need for manual deployment steps and provides a reliable and auditable deployment mechanism.

## Kubernetes deployment
The application was deployed using Kubernetes resources such as Deployments and Services, with proper configuration of liveness and readiness probes to ensure reliability. The deployment defines replica management, resource limits, and health checks, while the service exposes the application internally within the cluster. This setup ensures that the application remains resilient and can recover from failures automatically.

## Ingress and Load Balancing
The application was deployed using Kubernetes resources such as Deployments and Services, with proper configuration of liveness and readiness probes to ensure reliability. The deployment defines replica management, resource limits, and health checks, while the service exposes the application internally within the cluster. This setup ensures that the application remains resilient and can recover from failures automatically.

## Observability
The application was exposed to the internet using Kubernetes Ingress integrated with the AWS Load Balancer Controller. This enabled automatic provisioning of an Application Load Balancer (ALB), which routes external traffic to the application pods. The setup required proper configuration of subnets, VPC settings, and IAM permissions, as the controller relies on AWS infrastructure to dynamically create and manage load balancers.

## Security Implementation
Monitoring was implemented using Prometheus and Grafana to provide visibility into both application and cluster performance. Prometheus collects metrics from Kubernetes components, while Grafana visualizes them through dashboards. This setup helps in identifying performance bottlenecks, debugging issues, and understanding system behavior under different conditions.
______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
### faced multiple challenges 
This project involved several real-world challenges across Kubernetes and AWS infrastructure. Key issues included image pull failures caused by inconsistent tagging strategies, ingress resources not provisioning due to incorrect subnet tagging and VPC configuration, and subnet auto-discovery failures within the AWS Load Balancer Controller. Additionally, resource constraints from AWS CNI pod limits led to scheduling issues, requiring optimization of workloads and scaling decisions. There were also complications with Kubernetes resource lifecycle management, such as ingress deletion hanging due to finalizers, and service-to-pod connectivity problems caused by label mismatches. Resolving these issues required deep debugging across CI/CD pipelines, Kubernetes configurations, and AWS networking, reinforcing the importance of proper configuration, observability, and system-level understanding.

______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
<img width="769" height="215" alt="gitopss2" src="https://github.com/user-attachments/assets/f6495727-2cc5-45d3-9f66-76a4ebb8750d" />
<img width="1807" height="979" alt="gitops3" src="https://github.com/user-attachments/assets/51579faa-5b8f-4339-8bee-03396b5cbd8b" />
<img width="1128" height="258" alt="gitops1" src="https://github.com/user-attachments/assets/cd8db403-8651-444a-83f0-6bbf61df5ee2" />
<img width="1802" height="964" alt="gitops4" src="https://github.com/user-attachments/assets/b35454bb-788b-4fc8-bedb-81ee2c65ea4d" />

