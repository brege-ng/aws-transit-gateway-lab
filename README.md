# AWS Transit Gateway Lab – 3 VPCs

Ce laboratoire Terraform construit une architecture Hub & Spoke dans laquelle trois VPC communiquent à travers un AWS Transit Gateway.

## Architecture

| VPC | CIDR | Subnet EC2 / TGW |
|---|---|---|
| VPC 1 | `10.5.0.0/16` | `10.5.1.0/24` |
| VPC 2 | `10.6.0.0/16` | `10.6.1.0/24` |
| VPC 3 | `10.7.0.0/16` | `10.7.1.0/24` |

Chaque VPC contient une EC2 Amazon Linux 2023 dans un subnet privé, sans adresse IP publique.

## Organisation des fichiers

- Le **root module** (`main.tf`, `variables.tf`, `terraform.tfvars`, `outputs.tf`) orchestre le déploiement.
- `modules/vpc` est appelé trois fois pour créer les trois VPC.
- `modules/transit-gateway` crée le TGW, sa table de routage, les trois attachments, leurs associations et les routes statiques du TGW.
- Le root module crée les routes dans chaque table de routage VPC pour envoyer les CIDR distants vers le TGW.

### Pourquoi les routes VPC sont-elles dans le root ?

Le module TGW a besoin des IDs des VPC et de leurs subnets pour créer les attachments. Les VPC ont ensuite besoin de l'ID du TGW pour créer leurs routes. Pour éviter une dépendance circulaire entre les modules, les modules VPC créent d'abord les VPC/subnets/route tables, le module TGW crée les attachments, puis le root crée les routes VPC vers le TGW.

## Routage attendu

### Tables de routage des VPC

| Table | Destination | Target |
|---|---|---|
| VPC 1 | `10.5.0.0/16` | local |
| VPC 1 | `10.6.0.0/16` | TGW |
| VPC 1 | `10.7.0.0/16` | TGW |
| VPC 2 | `10.6.0.0/16` | local |
| VPC 2 | `10.5.0.0/16` | TGW |
| VPC 2 | `10.7.0.0/16` | TGW |
| VPC 3 | `10.7.0.0/16` | local |
| VPC 3 | `10.5.0.0/16` | TGW |
| VPC 3 | `10.6.0.0/16` | TGW |

### Transit Gateway Route Table

| Destination | Target |
|---|---|
| `10.5.0.0/16` | Attachment VPC 1 |
| `10.6.0.0/16` | Attachment VPC 2 |
| `10.7.0.0/16` | Attachment VPC 3 |

Les associations des trois attachments à la TGW Route Table sont explicites. La propagation automatique et l'association à la table par défaut du TGW sont désactivées ; les routes statiques sont créées par Terraform.

## Prérequis

- Terraform >= 1.5
- AWS CLI configuré
- Identifiants AWS disposant des permissions nécessaires pour créer VPC, EC2, Security Groups et Transit Gateway
- Une région AWS prenant en charge le Transit Gateway

Le laboratoire utilise `us-east-1` et `us-east-1a` par défaut.

## Déploiement

Depuis la racine du projet :

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Pour afficher les informations créées :

```bash
terraform output
terraform output ec2_private_ips
```

Pour supprimer les ressources :

```bash
terraform destroy
```

## Sécurité et test de connectivité

Les EC2 sont privées et n'ont ni IP publique ni accès SSH entrant. Le Security Group autorise ICMP depuis les CIDR des deux VPC distants, afin de permettre un test `ping` une fois qu'un accès d'administration privé est mis en place.

Ce projet ne déploie volontairement ni bastion, ni VPN, ni SSM Session Manager. Pour administrer les EC2, ajoute ensuite une solution d'accès privé (par exemple SSM avec rôle IAM et les endpoints nécessaires, ou un bastion/VPN).

Les routes et le Transit Gateway fournissent le chemin réseau, mais ne configurent pas à eux seuls un moyen de se connecter aux instances.

## Points importants

- Les CIDR des VPC doivent être non chevauchants.
- Chaque attachment VPC utilise un subnet dans `us-east-1a`. Pour une architecture multi-AZ résiliente, ajoute un subnet d'attachment dans chaque AZ utilisée.
- Le TGW est régional ; les trois VPC sont créés dans la même région.
- Les coûts AWS s'appliquent aux ressources déployées, notamment aux heures d'utilisation du Transit Gateway, aux attachments, au trafic traité et aux instances EC2. Vérifie les tarifs de ta région avant `terraform apply`.
- `terraform.tfvars` contient les paramètres locaux du laboratoire et est ignoré par Git. Ne publie jamais de secrets dans ce fichier.
