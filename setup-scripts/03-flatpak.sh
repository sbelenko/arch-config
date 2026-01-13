# Smart fix: Add repo first
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || handle_warning "Failed to add flathub repo"

flatpak install -y flathub com.google.Chrome || handle_warning "Failed to install Chrome"
flatpak install -y flathub com.slack.Slack || handle_warning "Failed to install Slack"
