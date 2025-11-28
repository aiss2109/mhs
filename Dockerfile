FROM debian
ARG NGROK_TOKEN
ARG REGION=eu
ENV DEBIAN_FRONTEND=noninteractive

# Installa systemd, ngrok e altri pacchetti necessari
RUN apt update && apt upgrade -y && apt install -y \
    systemd dbus ssh wget unzip vim curl python3

# Sposta ngrok in /usr/local/bin per essere nel PATH
RUN wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip -O /ngrok-stable-linux-amd64.zip \
    && cd / && unzip /ngrok-stable-linux-amd64.zip \
    && chmod +x ngrok && mv ngrok /usr/local/bin/ngrok

# Imposta variabile ambiente
#ENV container docker

# Crea script di avvio
RUN mkdir -p /run/sshd \
    && echo "/usr/local/bin/ngrok tcp --authtoken ${NGROK_TOKEN} --region ${REGION} 22 &" >>/openssh.sh \
    && echo "sleep 10" >> /openssh.sh \
    && echo "bash /get_ngrok_info.sh" >> /openssh.sh \
    && echo '/usr/sbin/sshd -D' >>/openssh.sh \
    && echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config  \
    && echo root:craxid | chpasswd \
    && chmod 755 /openssh.sh

# Espone le porte
EXPOSE 80 443 3306 4040 5432 5700 5701 5010 6800 6900 8080 8888 9000

# Comando di avvio
CMD ["/sbin/init"]
CMD ["/openssh.sh"]
