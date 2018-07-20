#!/bin/bash

inotifywait -r -m /srv/dicom_repo -e move --exclude \.part |
    while read a b file; do
                echo $file
                cp /srv/dicom_repo/$file /srv/dicom_repo/out-$file
                /opt/dcm4che-toolkit/bin/dcm2xml /srv/dicom_repo/$file > /tmp/$file.xml
                export patient_id=$(xmllint --xpath '//DicomAttribute[@keyword="EthnicGroup"]/Value/text()' /tmp/$file.xml)
                xmlstarlet ed -P -u '//DicomAttribute[@keyword="PatientID"]/Value' -v $patient_id /tmp/$file.xml > /tmp/$file-temp.xml
                /opt/dcm4che-toolkit/bin/xml2dcm -x /tmp/$file-temp.xml -o /srv/dicom_repo/out-$file
                /opt/dcm4che-toolkit/bin/storescu -c AETITLE@IP-ADDRESS:PORT /srv/dicom_repo/out-$file
                echo "Process:$file" >> /srv/dicom_repo.log
                rm -f /srv/dicom_repo/$file
                rm -f /srv/dicom_repo/out-$file
    done
~          
