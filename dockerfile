FROM kasmweb/ubuntu-noble-dind-rootless:1.16.1
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

# Upgrade software
RUN apt update
RUN apt upgrade -y

# Add Zorin OS theme and install XFCE plugins whiskermenu and clipman
WORKDIR "/tmp"
RUN git clone https://github.com/ZorinOS/zorin-desktop-themes && mv zorin-desktop-themes/Zorin* /usr/share/themes/
RUN git clone https://github.com/ZorinOS/zorin-icon-themes && mv zorin-icon-themes/Zorin* /usr/share/icons/
RUN apt install fonts-cantarell xfce4-whiskermenu-plugin xfce4-clipman-plugin -y
WORKDIR $HOME

# Install IntelliJ
RUN add-apt-repository ppa:mmk2410/intellij-idea
RUN apt update
RUN apt install intellij-idea-community -y

# Install bruno
RUN mkdir -p /etc/apt/keyrings && mkdir /home/kasm-default-profile/.gnupg
RUN gpg --no-default-keyring --keyring /etc/apt/keyrings/bruno.gpg --keyserver keyserver.ubuntu.com --recv-keys 9FA6017ECABE0266
RUN /bin/bash -c "echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/bruno.gpg] http://debian.usebruno.com/ bruno stable' | sudo tee /etc/apt/sources.list.d/bruno.list"
RUN apt update
RUN apt install bruno -y

# Install Liberica JDK
RUN /bin/bash -c "wget -q -O - https://download.bell-sw.com/pki/GPG-KEY-bellsoft | apt-key add -"
RUN /bin/bash -c "echo 'deb [arch=amd64] https://apt.bell-sw.com/ stable main' | tee /etc/apt/sources.list.d/bellsoft.list"
RUN apt update
RUN apt install bellsoft-java23-full

# Install Nextcloud client
RUN apt install nextcloud-desktop -y

# Install KeePassXC
RUN apt install keepassxc -y

# Install Mailpit
RUN /bin/bash -c "bash < <(curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh)"

# Install TeX Live
# RUN apt install texlive-full -y

# Install KWallet
RUN apt install kwalletmanager -y

# Install XFCE plugin docklike
RUN add-apt-repository ppa:xubuntu-dev/extras
RUN apt update
RUN apt install xfce4-docklike-plugin -y

# Set XFCE settings
RUN rm /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
COPY ./xfce4/ /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
