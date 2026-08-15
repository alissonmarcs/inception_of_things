## Como rodar ?

Necessário ter instalado os seguintes comandos: docker, k3d, argocd, kubect e helm

```bash
./setup_gitlab.sh
```

Não é necessário rodar o `setup_garage.sh`, pois o `setup_gitlab.sh` já o executa.

Para deletar tudo e testar novamente:

```bash
k3d cluster delete
./setup_gitlab.sh
```
