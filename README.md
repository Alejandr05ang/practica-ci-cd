# Práctica de CI/CD y Kubernetes: Inventario App

Este repositorio contiene la implementación de un pipeline de integración y despliegue continuo (CI/CD) junto con la orquestación en Kubernetes para la aplicación inventario-app, como parte de la práctica de Sistemas Distribuidos.

## Arquitectura y Herramientas
* **Contenedores:** Docker (Dockerfile Multi-stage).
* **CI/CD:** GitHub Actions.
* **Registry:** GitHub Container Registry (ghcr.io).
* **Orquestación:** Kubernetes (Minikube local).
* **Estrategia de Despliegue:** Blue-Green Deployment.

---

## Componentes Adicionales de Buenas Prácticas Implementados

1. **Manejo de Secretos en Kubernetes:** Se extrajo la credencial ficticia (API_KEY) del texto plano del Deployment y se inyectó de forma segura mediante un manifiesto Secret (k8s/secret.yml) consumido como variable de entorno (secretKeyRef).
2. **Escaneo de Seguridad en CI:** Se integró Trivy en el flujo de GitHub Actions. El pipeline está configurado para fallar automáticamente (exit-code: 1) si se detectan vulnerabilidades de severidad CRITICAL en la imagen construida antes de su publicación.

---

## Guía de Reproducción (Comandos Exactos)

Para reproducir el entorno y comprobar el funcionamiento de la infraestructura, siga estos pasos:

### 1. Prerrequisitos
* Tener Docker ejecutándose en el equipo.
* Tener instalados minikube y kubectl.

### 2. Iniciar el Clúster Local
Levante el clúster de pruebas ejecutando:
```bash
minikube start
```

### 3. Despliegue Base (Versión Blue)
Para aplicar los manifiestos base, incluyendo los secretos de la aplicación y el servicio configurado para apuntar a la versión inicial:

```bash
kubectl apply -f k8s/secret.yml
kubectl apply -f k8s/deployment.yml
kubectl apply -f k8s/service.yml
```

Verifique que los pods iniciales estén en estado Running:
```bash
kubectl get pods
```

Abra la aplicación en su navegador mediante el túnel de Minikube:
```bash
minikube service inventario-service
```
*(Se abrirá la pestaña mostrando la interfaz del inventario original).*

### 4. Estrategia de Despliegue: Blue-Green

Para demostrar el corte de tráfico sin caída del servicio, primero desplegamos la nueva versión (Green) que correrá en paralelo con la antigua (Blue):

```bash
kubectl apply -f k8s/blue-green/deployment-green.yml
```

Verifique que ahora existen 4 pods en estado Running (2 Blue y 2 Green):
```bash
kubectl get pods
```

**Corte de Tráfico (Switch):**
Para redirigir todo el tráfico instantáneamente a la nueva versión, modifique el archivo k8s/service.yml, cambiando el selector version: blue (o la ausencia del mismo si usó el base inicial) por version: green:

```yaml
  selector:
    app: practica-ci-cd
    version: green
```

Aplique el cambio en el servicio:
```bash
kubectl apply -f k8s/service.yml
```

Vuelva al navegador y recargue la página web. Observará el cambio inmediato hacia la nueva versión (Green) sin haber experimentado tiempo de inactividad.
```