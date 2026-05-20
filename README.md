## Sobre

O propósito desse projeto é ser uma introdução as seguintes ferramentas:

- Vagrant, simplifica o gerenciamento de VMs de diferentes providers (VirtualBox, VMWare, etc) através do `Vagrantfile`
- Kubernetes, gerencia um cluster de VMs

## Como rodar

O projeto deve ser rodado dentro de uma VM do VirtualBox. Com ele instalado, faça download do aquivo abaixo e importe ele no VirtualBox (Menu File > Import Appliance). A VM foi configurada com 16GB Ram e 4 CPUS, mas vc pode mudar essas configs, e recomendo que o disco virtual dela tenha no mínimo uns 70GB.

-  [Linux Mint VirtualBox image](https://drive.google.com/file/d/1Fin0aV261Yuldtv47qqZcMvpbe69S-Lh/view?usp=drive_link)

Dicas:

- Ctrl direito + f para habilitar/desabilitar full screen
- copy/paste entre o a VM e o host deve funcionar normalmente

Após importar e iniciar a VM, clone esse repo.

O projeto é dividido em três partes. Entre na pasta da parte desejada (ex: `cd p1`) e rode:

```bash
vagrant up
```

### Comandos úteis do Vagrant

Sobe apenas uma VM especifica:

```bash
vagrant up almarcos
```

Sobe todas as VMs em paralelo:

```bash
vagrant up --parallel
```

Abrir um shell na VM:

```bash
vagrant ssh eddos-sa
```

Parar todas as VMs:

```bash
vagrant halt
```

Apagar todas as VMs sem perguntar e em paralelo:

```bash
vagrant destroy -f --parallel
```

Listar todas as VMs, removendo entradas inválidas:

```bash
vagrant global-status --prune
```

Remover box:

```bash
vagrant box remove box_name
```

Listar boxes:

```bash
vagrant box list
```


## Links úteis

- [Introdução ao Vagrant](https://developer.hashicorp.com/vagrant/tutorials/get-started)