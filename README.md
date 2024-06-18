# Proyecto final 

## Pasos necesarios para que el proyecto funcione:

1. Borrar self-hosted runner si lo hay

2. Cambiar el token para la creación del runner. Para ello es necesario añadir un nuevo runner en GitHub Actions y copiar el token en el apartado ``custom_data`` del archivo ``main.tf``
3. Cambiar el secreto ``ACR_PASSWORD`` en GitHub Actions por la contraseña del ACR

4. Crear contenedor ``eperezbackup`` en la cuenta de almacenamiento

## Lanzamiento de workflows

1. Workflow ``terraform-plan.yml``: este workflow se lanza al hacer PR en la rama main

2. Workflow ``terraform-apply.yml``: Este workflow se lanza al hacer push en la rama main

3. Workflow ``ansible.yml``: este workflow instala mysql, crea la base de datos concierto y las tablas. Se lanza en el momento que se desee, ya que el trigger que se ha aplicado ha sido ``on:  workflow_dispatch``

4. Workflow ``pull-push-image.yml``: esfe workflow construye la imagen a partir del Dockerfile, la sube al ACR y crea los recursos necesarios en el cluster de kubernetes (AKS)

5. Workflow ``backup.yml``: hace un backup de la base de datos. Se lanza dos veces al día, por la mañana y por la tarde.

