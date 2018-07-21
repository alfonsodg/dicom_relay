#DICOM Relay


##Descripción
Scripts que permiten generar un PACS Relay o Proxy, capaz de recibir archivos DICOM, procesarlos (modificando metadata) y re-enviándolos a otro PACS.


##Por qué cambiar la metadata DICOM?
En varios casos ciertos proveedores o centros de salud construyen sus soluciones de imagenología sobre la base de códigos diversos que no permiten identificar claramente a los pacientes, en este caso es válido re-procesar estos objetos DICOM antes de centralizarlos o indexarlos.


##Cómo funciona?
Es un proceso de 2 fases:

* Activar el relay mediante el script **relay_init.sh**

    Inicializa un repositorio DICOM empleando el AETITLE (DICOMRELAY) en el puerto 11112 que guardará los objetos DICOM en /srv/dicom_repo (puede modificar el nombre)

* Activar el revisor de sistema de archivos **relay_process.sh**

    Revisa el directorio /srv/dicom_repo y procesa el contenido de este archivo por archivo enviándolos al PACS destino y eliminándolos una vez terminado.


##Manipulación de los atributos DICOM
Las líneas que permiten esto son:

    export patient_id=$(xmllint --xpath '//DicomAttribute[@keyword="EthnicGroup"]/Value/text()' /tmp/$file.xml)
    xmlstarlet ed -P -u '//DicomAttribute[@keyword="PatientID"]/Value' -v $patient_id /tmp/$file.xml > /tmp/$file-temp.xml

En este caso, la primera busca el atributo DICOM EthnicGroup (00102160) y extrae el valor

La segunda modifica el valor del atributo DICOM PatientID reemplazándolo por lo extraído de EthnicGroup


##Arquitectura
* Sistema Operativo
    * Linux Kernel 4.X o superior

* Requerimientos
    * [dcm4che-toolkit](https://github.com/dcm4che/dcm4che/blob/master/README.md)
    * [inotifywait](https://linux.die.net/man/1/inotifywait)
    * [xmllint](http://xmlsoft.org/xmllint.html)


##Instalación

###Revisar la instalación de las dependencias
Considerar que el **dcm4che-toolkit** debe instalarse como /opt/dcm4che-toolkit/

###Copiar / clonar en /srv
```
git clone https://alfonsodg@bitbucket.org/controlradiologico/dicom_relay.git
```

###Crear directorio dicom_repo
```
mkdir /srv/dicom_repo
```

###Copiar las plantillas de servicios contenidas en /srv/dicom_relay/extras
```
cp /srv/dicom_relay/extras/* /etc/systemd/system/
```

###Modificar los scripts *relay_init.sh* o *relay_process.sh* según sus requerimientos
```
/opt/dcm4che-toolkit/bin/storescu -c AETITLE@IP-ADDRESS:PORT /srv/dicom_repo/out-$file
```

###Activar los servicios
```
systemctl start relay_init
systemctl enable relay_init
systemctl start relay_process
systemctl enable relay_process
```


##Verificar PACS Relay
Empleando el mismo dmc4che-toolkit se prueba el RELAY, modificar los valores según sea el caso, considerando además que se envía todo el contenido de un DIRECTORIO_DICOM
```
/opt/dcm4che-toolkit/bin/storescu -c AETITLE@IP-ADDRESS:PORT /DIRECTORIO_DICOM


##Licencia
Este software es entregado bajo licencia GPL v3, excepto en las librerías que no sean compatibles con esta licencia.  Revisar el archivo **gplv3.md
** para los detalles y alcances del mismo
